import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:JIR/config.dart';

class RouteController extends GetxController {
  final Dio _dio = Dio();
  final String baseUrl = mainUrl;
  final RxList<Map<String, dynamic>> routeSteps = <Map<String, dynamic>>[].obs;
  final RxString selectedVehicle = 'motorcycle'.obs;
  final RxBool isLoading = false.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> destination = Rx<LatLng?>(null);
  final RxList<LatLng> optimizedWaypoints = <LatLng>[].obs;
  final RxList<List<LatLng>> _alternativeRoutes = RxList<List<LatLng>>([]);
  final RxDouble userHeading = 0.0.obs;
  final RxList<Map<String, dynamic>> searchSuggestions =
      <Map<String, dynamic>>[].obs;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _debounceTimer;
  DateTime _lastCheck = DateTime.now();
  LatLng? startPoint;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  void _initialize() async {
    await _getUserLocation();
    startPoint = userLocation.value;
    _startLocationUpdates();
    _startCompassUpdates();
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream().listen((position) async {
      final currentLocation = LatLng(position.latitude, position.longitude);
      userLocation(currentLocation);

      final now = DateTime.now();
      if (now.difference(_lastCheck).inSeconds.abs() > 10) {
        _checkRouteDeviation(currentLocation);
        _lastCheck = now;
      }
    });
  }

  void _checkRouteDeviation(LatLng currentLocation) async {
    if (routePoints.isEmpty || destination.value == null) return;

    startPoint ??= userLocation.value;

    final nearestPointOnRoute = _findNearestPoint(currentLocation, routePoints);
    final distanceToRoute = calculateDistance(
      currentLocation,
      nearestPointOnRoute,
    );

    final totalDistance = calculateDistance(startPoint!, destination.value!);
    final remainingDistance = calculateDistance(
      currentLocation,
      destination.value!,
    );

    if (remainingDistance < totalDistance * 0.2) return;

    if (distanceToRoute > 50) {
      await _fetchNewRoute(currentLocation, destination.value!);
    }
  }

  LatLng _findNearestPoint(LatLng point, List<LatLng> route) {
    LatLng nearest = route.first;
    double minDistance = double.maxFinite;

    for (final routePoint in route) {
      final dist = calculateDistance(point, routePoint);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = routePoint;
      }
    }
    return nearest;
  }

  void selectVehicle(String vehicleKey) {
    if (vehicleKey != 'motorcycle' && vehicleKey != 'car') return;
    selectedVehicle.value = vehicleKey;
    if (destination.value != null) {
      fetchOptimizedRoute();
    }
  }

  void editStepInstruction(int index, String newInstruction) {
    if (index < 0 || index >= routeSteps.length) return;
    final updated = Map<String, dynamic>.from(routeSteps[index]);
    updated['instruction'] = newInstruction;
    routeSteps[index] = updated;
  }

  Future<void> _fetchNewRoute(LatLng start, LatLng end) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/routing/optimized-route',
        data: {
          'start_lat': start.latitude,
          'start_lon': start.longitude,
          'end_lat': end.latitude,
          'end_lon': end.longitude,
          'vehicle': selectedVehicle.value,
        },
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        print(
            '_fetchNewRoute bad status ${response.statusCode}: ${response.data}');
        Get.snackbar('Gagal memperbarui rute',
            'Rute tidak tersedia atau server tidak merespon.');
        return;
      }

      _parseOptimizedRouteData(response.data as Map<String, dynamic>);
      Get.snackbar("Info", "Rute diperbarui",
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP);
    } on DioException catch (e) {
      print('_fetchNewRoute DioException: ${e.toString()}');
      print('Response: ${e.response?.statusCode} ${e.response?.data}');
      Get.snackbar(
          'Gagal memperbarui rute', 'Tidak dapat terhubung ke server.');
    } catch (e) {
      print('_fetchNewRoute error: $e');
      Get.snackbar('Gagal memperbarui rute', 'Terjadi kesalahan. Coba lagi.');
    }
  }

  void _startCompassUpdates() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        double heading = event.heading!;
        userHeading(heading);
      }
    });
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      userLocation(LatLng(position.latitude, position.longitude));
    } catch (e) {
      Get.snackbar(
        "Peringatan",
        "Gagal mendapatkan lokasi",
        backgroundColor: Colors.orange,
      );
    }
  }

  void updateVehicle(String vehicle) {
    selectedVehicle.value = vehicle;
    fetchOptimizedRoute();
  }

  Future<void> fetchOptimizedRoute() async {
    if (userLocation.value == null || destination.value == null) return;

    routePoints.clear();
    routeSteps.clear();
    optimizedWaypoints.clear();
    isLoading(true);

    try {       
      final response = await _dio.post(
        '$baseUrl/api/routing/optimized-route',
        data: {
          'start_lat': userLocation.value!.latitude,
          'start_lon': userLocation.value!.longitude,
          'end_lat': destination.value!.latitude,
          'end_lon': destination.value!.longitude,
          'vehicle': selectedVehicle.value,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          sendTimeout: const Duration(seconds: 30),
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        print(
            'fetchOptimizedRoute: bad status ${response.statusCode} - ${response.data}');
        Get.snackbar(
          'Gagal memuat rute',
          response.statusCode == 404
              ? 'Rute tidak ditemukan. Periksa tujuan Anda.'
              : 'Terjadi kesalahan saat memuat rute (kode ${response.statusCode}). Coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      _parseOptimizedRouteData(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('fetchOptimizedRoute DioException: ${e.toString()}');
      print('Response: ${e.response?.statusCode} ${e.response?.data}');

      Get.snackbar(
        'Gagal memuat rute',
        'Tidak dapat terhubung ke server. Periksa koneksi atau coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e, st) {
      print('fetchOptimizedRoute unknown error: $e\n$st');
      Get.snackbar(
        'Terjadi Kesalahan',
        'Terjadi kesalahan tak terduga saat memuat rute.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading(false);
    }
  }

  void _parseOptimizedRouteData(Map<String, dynamic> data) {
    try {
      final waypoints = data['waypoints'] as List? ?? [];
      optimizedWaypoints.value = waypoints.map<LatLng>((wp) {
        if (wp is List && wp.length >= 2) {
          return LatLng(
            (wp[0] as num).toDouble(),
            (wp[1] as num).toDouble(),
          );
        } else {
          throw Exception('Invalid waypoint format: $wp');
        }
      }).toList();

      final routeData = data['route'] as Map<String, dynamic>?;
      if (routeData == null) {
        throw Exception('Route data is null');
      }

      final routes = routeData['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        throw Exception('No routes found in response');
      }

      final mainRoute = routes[0] as Map<String, dynamic>;
      final geometry = mainRoute['geometry'] as Map<String, dynamic>?;
      if (geometry == null) {
        throw Exception('Geometry data is null');
      }

      final coordinates = geometry['coordinates'] as List? ?? [];
      routePoints.value = coordinates.map<LatLng>((coord) {
        if (coord is List && coord.length >= 2) {
          return LatLng(
            (coord[1] as num).toDouble(),
            (coord[0] as num).toDouble(),
          );
        } else {
          throw Exception('Invalid coordinate format: $coord');
        }
      }).toList();

      final legs = mainRoute['legs'] as List?;
      if (legs != null && legs.isNotEmpty) {
        final leg = legs[0] as Map<String, dynamic>;
        final steps = leg['steps'] as List? ?? [];

        routeSteps.value = steps.map<Map<String, dynamic>>((step) {
          final stepMap = step as Map<String, dynamic>;
          final maneuver = stepMap['maneuver'] as Map<String, dynamic>?;

          return {
            'instruction': parseManeuver(maneuver),
            'name': stepMap['name'] as String? ?? 'Jalan tanpa nama',
            'distance': (stepMap['distance'] as num?)?.toDouble() ?? 0.0,
            'type': maneuver?['type'] as String?,
            'modifier': maneuver?['modifier'] as String?,
          };
        }).toList();
      }

      final alternatives = routeData['alternatives'] as List? ?? [];
      _alternativeRoutes.value = alternatives.map<List<LatLng>>((alt) {
        final altMap = alt as Map<String, dynamic>;
        final altGeometry = altMap['geometry'] as Map<String, dynamic>?;
        final altCoordinates = altGeometry?['coordinates'] as List? ?? [];

        return altCoordinates.map<LatLng>((coord) {
          if (coord is List && coord.length >= 2) {
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          } else {
            throw Exception(
              'Invalid alternative coordinate format: $coord',
            );
          }
        }).toList();
      }).toList();
      print(
        "Optimized route found: ${routePoints.length} points, ${optimizedWaypoints.length} waypoints",
      );
    } catch (e) {
      throw Exception('Format data tidak valid: ${e.toString()}');
    }
  }

  void useAlternativeRoute(int index) {
    if (index < _alternativeRoutes.length) {
      routePoints(_alternativeRoutes[index]);
    }
  }

  Future<void> fetchSearchSuggestions(String query) async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        searchSuggestions.clear();
        return;
      }

      try {
        final params = {'query': query, 'limit': 5};

        if (userLocation.value != null) {
          params['lat'] = userLocation.value!.latitude;
          params['lon'] = userLocation.value!.longitude;
        }

        final response = await _dio.get(
          '$baseUrl/api/search',
          queryParameters: params,
          options: Options(sendTimeout: const Duration(seconds: 5)),
        );

        searchSuggestions.value =
            (response.data as List).map<Map<String, dynamic>>((item) {
          return {
            'display_name': item['display_name'] as String,
            'lat': item['lat'] as double,
            'lon': item['lon'] as double,
            'type': item['type'] as String? ?? 'unknown',
            'address': item['address'] as Map<String, dynamic>? ?? {},
            'distance': item['distance'] as double?,
          };
        }).toList();
      } on DioException catch (e) {
        final errorMsg = e.response?.data?['detail'] ?? e.message;
        Get.snackbar("Error", "Pencarian gagal: $errorMsg");
      } catch (e) {
        Get.snackbar("Error", "Pencarian gagal: ${e.toString()}");
      }
    });
  }

  static double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance(start, end);
  }

  static String parseManeuver(Map<String, dynamic>? maneuver) {
    if (maneuver == null) return 'Lanjutkan perjalanan';

    final type = maneuver['type'];
    final modifier = maneuver['modifier'];
    final exit = maneuver['keluar'];
    final roadName = maneuver['name'] ?? '';

    String exitIndonesian(int? exitNum) {
      if (exitNum == null) return '';
      switch (exitNum) {
        case 1:
          return 'pertama';
        case 2:
          return 'kedua';
        case 3:
          return 'ketiga';
        case 4:
          return 'keempat';
        default:
          return 'ke-$exitNum';
      }
    }

    switch (type) {
      case 'depart':
        return 'Mulai perjalanan dari lokasi ini';
      case 'arrive':
        return 'Anda telah tiba di tujuan';
      case 'turn':
        switch (modifier) {
          case 'left':
            return 'Belok ke kiri';
          case 'right':
            return 'Belok ke kanan';
          case 'sharp left':
            return 'Belok tajam ke kiri';
          case 'sharp right':
            return 'Belok tajam ke kanan';
          case 'slight left':
            return 'Belok pelan ke kiri';
          case 'slight right':
            return 'Belok pelan ke kanan';
          default:
            return 'Belok';
        }
      case 'new name':
        return 'Teruskan lurus menuju $roadName';
      case 'roundabout':
        return 'Masuk bundaran dan ambil keluar ${exitIndonesian(exit)}';
      case 'rotary':
        return 'Masuk lingkaran lalu keluar di keluar ${exitIndonesian(exit)}';
      case 'fork':
        return 'Ambil percabangan ${_translateModifier(modifier)}';
      case 'merge':
        return 'Bergabung ke jalur ${_translateModifier(modifier)}';
      case 'on ramp':
        return 'Masuk jalan tol ${_translateModifier(modifier)}';
      case 'off ramp':
        return 'Keluar melalui jalan tol ${_translateModifier(modifier)}';
      default:
        return 'Teruskan mengikuti jalan';
    }
  }

  static String _translateModifier(String? modifier) {
    switch (modifier) {
      case 'left':
        return 'sebelah kiri';
      case 'right':
        return 'sebelah kanan';
      case 'straight':
        return 'lurus';
      case 'slight left':
        return 'sedikit ke kiri';
      case 'slight right':
        return 'sedikit ke kanan';
      default:
        return '';
    }
  }

  static Widget getManeuverIcon(String? type, String? modifier) {
    const defaultIcon = Icon(Icons.directions, color: Colors.blue);

    switch (type) {
      case 'turn':
        switch (modifier) {
          case 'left':
            return const Icon(Icons.turn_left, color: Colors.blue);
          case 'right':
            return const Icon(Icons.turn_right, color: Colors.blue);
          case 'sharp left':
            return const Icon(Icons.u_turn_left, color: Colors.blue);
          case 'sharp right':
            return const Icon(Icons.u_turn_right, color: Colors.blue);
          default:
            return defaultIcon;
        }
      case 'roundabout':
        return const Icon(Icons.alt_route, color: Colors.orange);
      case 'depart':
        return const Icon(Icons.location_on, color: Colors.green);
      case 'arrive':
        return const Icon(Icons.flag, color: Colors.red);
      case 'fork':
        return Transform.rotate(
          angle: modifier == 'left' ? 0.3 : -0.3,
          child: const Icon(Icons.fork_left, color: Colors.blue),
        );
      default:
        return defaultIcon;
    }
  }

  static String formatDistance(num distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} meter';
    }
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  static String getLocationType(String type) {
    const typeTranslations = {
      'administrative': 'Wilayah Administratif',
      'city': 'Kota',
      'village': 'Desa',
      'road': 'Jalan',
      'shop': 'Toko',
      'amenity': 'Fasilitas Umum',
    };
    return typeTranslations[type] ?? 'Lokasi Umum';
  }

  void updateLocations(LatLng start, LatLng end) {
    userLocation(start);
    destination(end);
    fetchOptimizedRoute();
  }

  void handleSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (query.isEmpty) {
        searchSuggestions.clear();
      } else {
        fetchSearchSuggestions(query);
      }
    });
  }

  void clearRoute() {
    routePoints.clear();
    routeSteps.clear();
    optimizedWaypoints.clear();
    destination.value = null;
    searchSuggestions.clear();
    update();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _debounceTimer?.cancel();
    _compassSubscription?.cancel();
    _alternativeRoutes.close();
    super.onClose();
  }
}

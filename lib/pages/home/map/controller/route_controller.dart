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
    try {
      _positionStream = Geolocator.getPositionStream().listen((position) async {
        final currentLocation = LatLng(position.latitude, position.longitude);
        userLocation(currentLocation);

        final now = DateTime.now();
        if (now.difference(_lastCheck).inSeconds.abs() > 10) {
          _checkRouteDeviation(currentLocation);
          _lastCheck = now;
        }
      });
    } catch (e, st) {
      _logError(e, st);
    }
  }

  void _checkRouteDeviation(LatLng currentLocation) async {
    try {
      if (routePoints.isEmpty || destination.value == null) return;

      startPoint ??= userLocation.value;

      final nearestPointOnRoute =
          _findNearestPoint(currentLocation, routePoints);
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
    } catch (e, st) {
      _logError(e, st);
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
        _logError('Bad status', StackTrace.current);
        _showUserMessage(
          'Tidak dapat memperbarui rute',
          'Rute tidak tersedia saat ini. Silakan coba lagi nanti.',
        );
        return;
      }

      final data = response.data;
      _parseOptimizedRouteDataSafely(data);
      _showUserMessage('Rute diperbarui', 'Rute telah diperbarui.');
    } on DioException catch (e) {
      _logError(e, e.stackTrace);
      _showUserMessage(
        'Gagal memperbarui rute',
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Gagal memperbarui rute',
        'Terjadi kesalahan saat memperbarui rute. Silakan coba lagi.',
      );
    }
  }

  void _startCompassUpdates() {
    try {
      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (event.heading != null) {
          double heading = event.heading!;
          userHeading(heading);
        }
      });
    } catch (e, st) {
      _logError(e, st);
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showUserMessage('Lokasi tidak aktif',
            'Layanan lokasi perangkat Anda tidak aktif. Aktifkan lokasi lalu coba lagi.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showUserMessage('Izin Lokasi Ditolak',
              'Aplikasi membutuhkan izin lokasi untuk menampilkan peta di posisi Anda.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showUserMessage('Izin Lokasi Permanen Ditolak',
            'Mohon aktifkan izin lokasi di pengaturan perangkat.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      userLocation(LatLng(position.latitude, position.longitude));
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Tidak dapat mengambil lokasi',
        'Gagal mendapatkan lokasi. Periksa pengaturan lokasi dan coba lagi.',
      );
    }
  }

  void updateVehicle(String vehicle) {
    selectedVehicle.value = vehicle;
    fetchOptimizedRoute();
  }

  Future<void> fetchOptimizedRoute() async {
    if (userLocation.value == null || destination.value == null) {
      _showUserMessage(
          'Belum ada lokasi', 'Pastikan lokasi Anda dan tujuan telah dipilih.');
      return;
    }

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
        _logError('fetchOptimizedRoute bad status ${response.statusCode}',
            StackTrace.current);
        final userMsg = response.statusCode == 404
            ? 'Rute tidak ditemukan. Coba cek lokasi tujuan Anda.'
            : 'Gagal memuat rute. Silakan coba lagi.';
        _showUserMessage('Gagal memuat rute', userMsg);
        return;
      }

      final data = response.data;
      _parseOptimizedRouteDataSafely(data);
    } on DioException catch (e) {
      _logError(e, e.stackTrace);
      _showUserMessage(
        'Gagal memuat rute',
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Terjadi Kesalahan',
        'Terjadi kesalahan saat memuat rute. Silakan coba lagi.',
      );
    } finally {
      isLoading(false);
    }
  }

  void _parseOptimizedRouteDataSafely(dynamic data) {
    try {
      _parseOptimizedRouteDataInternal(data);
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Data rute tidak valid',
        'Server mengirim data rute yang tidak dapat diproses. Silakan coba lagi nanti.',
      );
    }
  }

  void _parseOptimizedRouteDataInternal(dynamic data) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    final waypoints = map['waypoints'] as List? ?? [];
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

    final routeData = map['route'] as Map<String, dynamic>?;
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
          throw Exception('Invalid alternative coordinate format: $coord');
        }
      }).toList();
    }).toList();
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
        _logError(e, e.stackTrace);
        _showUserMessage('Pencarian gagal',
            'Tidak dapat melakukan pencarian. Periksa koneksi Anda.');
      } catch (e, st) {
        _logError(e, st);
        _showUserMessage('Pencarian gagal',
            'Terjadi kesalahan saat mencari. Silakan coba lagi.');
      }
    });
  }

  static double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance(start, end);
  }

  static String parseManeuver(Map<String, dynamic>? maneuver) {
    if (maneuver == null) return 'Lanjutkan perjalanan';

    final type = (maneuver['type'] ?? '').toString();
    final modifier = (maneuver['modifier'] ?? '').toString();
    final exit = maneuver['keluar'];
    final roadName = (maneuver['name'] ?? '').toString();

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

    String modText(String? m) {
      switch (m) {
        case 'left':
          return 'kiri';
        case 'right':
          return 'kanan';
        case 'sharp left':
          return 'tajam ke kiri';
        case 'sharp right':
          return 'tajam ke kanan';
        case 'slight left':
          return 'sedikit ke kiri';
        case 'slight right':
          return 'sedikit ke kanan';
        case 'straight':
          return 'lurus';
        case 'uturn':
        case 'uturn-left':
        case 'uturn-right':
          return 'balik arah';
        default:
          return '';
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
            return 'Belok sedikit ke kiri';
          case 'slight right':
            return 'Belok sedikit ke kanan';
          case 'straight':
            return 'Lurus';
          case 'uturn':
          case 'uturn-left':
          case 'uturn-right':
            return 'Balik arah';
          default:
            return 'Belok';
        }
      case 'new name':
        if (roadName.isNotEmpty) return 'Teruskan menuju $roadName';
        return 'Teruskan mengikuti jalan';
      case 'continue':
        return 'Lanjutkan mengikuti jalan';
      case 'roundabout':
        return 'Masuk bundaran dan ambil keluar ${exitIndonesian(exit)}';
      case 'rotary':
        return 'Masuk bundaran besar lalu keluar ${exitIndonesian(exit)}';
      case 'fork':
        final t = _translateModifier(modifier);
        return t.isNotEmpty ? 'Ambil percabangan $t' : 'Ambil percabangan';
      case 'merge':
        final t = _translateModifier(modifier);
        return t.isNotEmpty ? 'Bergabung ke jalur $t' : 'Bergabung ke jalur';
      case 'on ramp':
        final t = _translateModifier(modifier);
        return t.isNotEmpty ? 'Masuk jalur (ramp) $t' : 'Masuk jalur (ramp)';
      case 'off ramp':
        final t = _translateModifier(modifier);
        return t.isNotEmpty
            ? 'Keluar dari jalur (ramp) $t'
            : 'Keluar dari jalur (ramp)';
      case 'end of road':
        final t = modText(modifier);
        return t.isNotEmpty ? 'Ujung jalan, kemudian belok $t' : 'Ujung jalan';
      case 'use lane':
        return 'Pilih jalur yang sesuai';
      case 'turn slight':
        return 'Belok sedikit';
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
    const baseColor = Color(0xff45557B);
    const departColor = Colors.green;
    const arriveColor = Colors.red;
    const roundColor = Colors.orange;
    final mod = modifier ?? '';

    switch (type) {
      case 'depart':
        return const Icon(Icons.my_location, color: departColor);
      case 'arrive':
        return const Icon(Icons.flag, color: arriveColor);
      case 'turn':
        switch (mod) {
          case 'left':
            return const Icon(Icons.turn_left, color: baseColor);
          case 'right':
            return const Icon(Icons.turn_right, color: baseColor);
          case 'sharp left':
            return const Icon(Icons.u_turn_left, color: baseColor);
          case 'sharp right':
            return const Icon(Icons.u_turn_right, color: baseColor);
          case 'slight left':
            return const Icon(Icons.turn_left, color: baseColor);
          case 'slight right':
            return const Icon(Icons.turn_right, color: baseColor);
          case 'straight':
            return const Icon(Icons.arrow_forward, color: baseColor);
          case 'uturn':
          case 'uturn-left':
            return const Icon(Icons.u_turn_left, color: baseColor);
          case 'uturn-right':
            return const Icon(Icons.u_turn_right, color: baseColor);
          default:
            return const Icon(Icons.directions, color: baseColor);
        }
      case 'new name':
        return const Icon(Icons.straight, color: baseColor);
      case 'continue':
        return const Icon(Icons.straight, color: baseColor);
      case 'roundabout':
        return const Icon(Icons.alt_route, color: roundColor);
      case 'rotary':
        return const Icon(Icons.loop, color: roundColor);
      case 'fork':
        return const Icon(Icons.call_split, color: baseColor);
      case 'merge':
        return const Icon(Icons.merge_type, color: baseColor);
      case 'on ramp':
        return const Icon(Icons.login, color: baseColor);
      case 'off ramp':
        return const Icon(Icons.exit_to_app, color: baseColor);
      case 'end of road':
        return const Icon(Icons.stop_circle, color: baseColor);
      case 'use lane':
        return const Icon(Icons.view_agenda, color: baseColor);
      default:
        return const Icon(Icons.directions, color: baseColor);
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

  void _showUserMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
    );
  }

  void _logError(Object e, StackTrace? st) {
    print('RouteController error: $e');
    if (st != null) print(st);
  }
}

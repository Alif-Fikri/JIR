import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';

class RouteController extends GetxController {
  final Dio _dio = Dio();
  final RxList<Map<String, dynamic>> routeSteps = <Map<String, dynamic>>[].obs;
  final RxString selectedVehicle = 'motorcycle'.obs;
  final RxBool isLoading = false.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> destination = Rx<LatLng?>(null);
  final RxList<List<LatLng>> _alternativeRoutes = RxList<List<LatLng>>([]);
  final RxDouble userHeading = 0.0.obs;
  final RxList<Map<String, dynamic>> searchSuggestions =
      <Map<String, dynamic>>[].obs;
  final Map<String, List<Map<String, dynamic>>> _searchCache = {};
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
    final distanceToRoute =
        calculateDistance(currentLocation, nearestPointOnRoute);

    final totalDistance = calculateDistance(startPoint!, destination.value!);
    final remainingDistance =
        calculateDistance(currentLocation, destination.value!);

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

  Future<void> _fetchNewRoute(LatLng start, LatLng end) async {
    try {
      final profile = selectedVehicle.value == 'motorcycle' ? 'bike' : 'car';
      final url = "http://router.project-osrm.org/route/v1/$profile/"
          "${start.longitude},${start.latitude};"
          "${end.longitude},${end.latitude}"
          "?overview=full&steps=true&geometries=geojson";

      final response = await _dio.get(url);
      _parseRouteData(response.data);

      Get.snackbar("Info", "Rute diperbarui",
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui rute");
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

  void _handleRotation(double dx, double dy) {
    final angle = atan2(dy, dx);
    userHeading(angle * (180 / pi));
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
      Get.snackbar("Peringatan", "Gagal mendapatkan lokasi",
          backgroundColor: Colors.orange);
    }
  }

  void updateVehicle(String vehicle) {
    selectedVehicle.value = vehicle;
    fetchRoute();
  }

  Future<void> fetchRoute() async {
    if (userLocation.value == null || destination.value == null) return;

    routePoints.clear();
    routeSteps.clear();

    try {
      final profile = selectedVehicle.value == 'motorcycle' ? 'bike' : 'car';
      final url = "http://router.project-osrm.org/route/v1/$profile/"
          "${userLocation.value!.longitude},${userLocation.value!.latitude};"
          "${destination.value!.longitude},${destination.value!.latitude}"
          "?overview=full&steps=true&geometries=geojson";

      final response = await _dio.get(url);

      if (response.statusCode != 200) throw Exception('Gagal mendapatkan rute');

      _parseRouteData(response.data);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat rute: ${e.toString()}",
          backgroundColor: Colors.red);
    } finally {
      isLoading(false);
    }
  }

  void _parseRouteData(Map<String, dynamic> data) {
    try {
      final coordinates = data['routes'][0]['geometry']['coordinates'];
      routePoints(coordinates
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList());
      print("Route found: ${coordinates.length} points");
      final legs = data['routes'][0]['legs'];
      if (legs != null && legs.isNotEmpty) {
        final leg = legs[0];
        routeSteps(List<Map<String, dynamic>>.from(leg["steps"].map((step) {
          final maneuver = step['maneuver'];
          return {
            'instruction': parseManeuver(maneuver),
            'name': step['name'] ?? 'Jalan tanpa nama',
            'distance': step['distance'],
            'type': maneuver?['type'],
            'modifier': maneuver?['modifier'],
          };
        })));
        final alternatives = data['alternatives'] ?? [];
        if (alternatives.isNotEmpty) {
          _alternativeRoutes.value =
              alternatives.map((alt) => _parseAlternativeRoute(alt)).toList();
        }
      }
    } catch (e) {
      throw Exception('Format data tidak valid');
    }
  }

  List<LatLng> _parseAlternativeRoute(Map<String, dynamic> altData) {
    try {
      final coordinates = altData['geometry']['coordinates'];
      return coordinates
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } catch (e) {
      throw Exception('Format alternatif tidak valid');
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

      if (_searchCache.containsKey(query)) {
        searchSuggestions(_searchCache[query]!);
        return;
      }

      try {
        final response = await _dio.get(
          "https://nominatim.openstreetmap.org/search",
          queryParameters: {
            'q': query,
            'format': 'json',
            'addressdetails': 1,
            'countrycodes': 'id',
            'viewbox': '106.4,-6.4,107.0,-6.0',
            'bounded': 1,
            'limit': 10,
          },
        );

        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(response.data);

        if (userLocation.value != null) {
          results = results.map((item) {
            final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0;
            final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0;
            return {
              ...item,
              'distance':
                  calculateDistance(userLocation.value!, LatLng(lat, lon))
            };
          }).toList()
            ..sort((a, b) =>
                (a['distance'] as double).compareTo(b['distance'] as double));
        }

        final finalResults = results.take(5).toList();
        _searchCache[query] = finalResults;
        searchSuggestions(finalResults);
      } catch (e) {
        Get.snackbar("Error", "Gagal memuat saran lokasi");
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

    // Fungsi konversi angka ke urutan (1 -> pertama, 2 -> kedua, dst)
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
      return '${distance.toStringAsFixed(0)} meter'; // 850 -> 850 meter
    }
    return '${(distance / 1000).toStringAsFixed(1)} km'; // 1250 -> 1.3 km
  }

  // Helper method untuk tipe lokasi
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
    fetchRoute();
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

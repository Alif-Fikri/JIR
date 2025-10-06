import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:JIR/helper/mapbox_config.dart';

class RouteOption {
  RouteOption({
    required this.id,
    required this.index,
    required this.points,
    required this.steps,
    required this.distance,
    required this.duration,
    required this.summary,
  });

  final String id;
  final int index;
  final List<LatLng> points;
  final List<Map<String, dynamic>> steps;
  final double distance;
  final double duration;
  final String summary;
}

class RouteController extends GetxController {
  final Dio _dio = Dio();
  final RxList<Map<String, dynamic>> routeSteps = <Map<String, dynamic>>[].obs;
  final RxString selectedVehicle = 'motorcycle'.obs;
  final RxBool isLoading = false.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> destination = Rx<LatLng?>(null);
  final RxList<LatLng> optimizedWaypoints = <LatLng>[].obs;
  final RxList<RouteOption> routeOptions = <RouteOption>[].obs;
  final RxInt selectedRouteIndex = 0.obs;
  final RxDouble userHeading = 0.0.obs;
  final RxList<Map<String, dynamic>> searchSuggestions =
      <Map<String, dynamic>>[].obs;
  final RxBool routeActive = false.obs;
  final RxDouble totalRouteDistance = 0.0.obs;
  final RxDouble totalRouteDuration = 0.0.obs;
  final RxDouble remainingRouteDistance = 0.0.obs;
  final RxDouble remainingRouteDuration = 0.0.obs;
  final RxString destinationLabel = ''.obs;
  final RxString destinationAddress = ''.obs;
  final RxString nextInstruction = ''.obs;
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
        _updateRemainingMetrics(currentLocation);

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

      _updateRemainingMetrics(currentLocation);
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

  int? _findNearestPointIndex(LatLng point, List<LatLng> route) {
    if (route.isEmpty) return null;

    int nearestIndex = 0;
    double minDistance = double.maxFinite;

    for (int i = 0; i < route.length; i++) {
      final dist = calculateDistance(point, route[i]);
      if (dist < minDistance) {
        minDistance = dist;
        nearestIndex = i;
      }
    }
    return nearestIndex;
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
    await _requestMapboxRoute(
      start: start,
      end: end,
      successTitle: 'Rute diperbarui',
      successMessage: 'Rute telah diperbarui.',
      failureTitle: 'Tidak dapat memperbarui rute',
      failureMessage: 'Rute tidak tersedia saat ini. Silakan coba lagi nanti.',
    );
  }

  void _startCompassUpdates() {
    try {
      if (_compassSubscription != null) {
        return;
      }

      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (event.heading == null) {
          return;
        }
        final double heading = event.heading!;
        userHeading(heading);
      }, onError: (error) {});
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
      _updateRemainingMetrics(userLocation.value);
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

    if (selectedVehicle.value.isEmpty) {
      selectedVehicle.value = 'motorcycle';
    }

    routePoints.clear();
    routeSteps.clear();
    optimizedWaypoints.clear();
    routeOptions.clear();
    selectedRouteIndex.value = 0;
    isLoading(true);

    try {
      await _requestMapboxRoute(
        start: userLocation.value!,
        end: destination.value!,
        failureTitle: 'Gagal memuat rute',
        failureMessage: 'Gagal memuat rute. Silakan coba lagi.',
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> _requestMapboxRoute({
    required LatLng start,
    required LatLng end,
    String? successTitle,
    String? successMessage,
    String? failureTitle,
    String? failureMessage,
  }) async {
    if (!MapboxConfig.isTokenValid()) {
      _showUserMessage(
        'Token Mapbox tidak tersedia',
        'Pastikan MAPBOX_ACCESS_TOKEN sudah dikonfigurasi pada aplikasi.',
      );
      return;
    }

    final vehicle =
        selectedVehicle.value.isEmpty ? 'motorcycle' : selectedVehicle.value;
    final profile = _mapboxProfileForVehicle(vehicle);
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

    final baseQuery = <String, dynamic>{
      'alternatives': 'true',
      'geometries': 'geojson',
      'overview': 'full',
      'steps': 'true',
      'annotations': 'distance,duration',
      'language': 'id',
      'voice_instructions': 'false',
      'banner_instructions': 'false',
      'access_token': MapboxConfig.accessToken,
    };

    final shouldAvoidHighways = vehicle == 'motorcycle';
    if (shouldAvoidHighways) {
      baseQuery['exclude'] = 'toll,ferry';
    }

    try {
      final response = await _dio.get(
        url,
        queryParameters: Map<String, dynamic>.from(baseQuery),
        options: Options(responseType: ResponseType.json),
      );

      Map<String, dynamic>? data;
      if (response.statusCode == 200) {
        data = response.data as Map<String, dynamic>?;
      }

      if ((data?['routes'] as List?)?.isEmpty ?? true) {
        if (shouldAvoidHighways) {
          final fallbackQuery = Map<String, dynamic>.from(baseQuery)
            ..remove('exclude');
          final fallbackResponse = await _dio.get(
            url,
            queryParameters: fallbackQuery,
            options: Options(responseType: ResponseType.json),
          );

          if (fallbackResponse.statusCode == 200) {
            data = fallbackResponse.data as Map<String, dynamic>?;
          }
        }
      }

      if (data == null || ((data['routes'] as List?)?.isEmpty ?? true)) {
        _logError(
            'Mapbox route status ${response.statusCode}', StackTrace.current);
        _showUserMessage(
          failureTitle ?? 'Gagal memuat rute',
          failureMessage ??
              'Rute tidak tersedia saat ini. Silakan coba lagi nanti.',
        );
        return;
      }

      _parseOptimizedRouteDataSafely(data);
      if (successTitle != null && successMessage != null) {
        _showUserMessage(successTitle, successMessage);
      }
    } on DioException catch (e) {
      _logError(e, e.stackTrace);
      _showUserMessage(
        failureTitle ?? 'Gagal memuat rute',
        failureMessage ??
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        failureTitle ?? 'Gagal memuat rute',
        failureMessage ??
            'Terjadi kesalahan saat memuat rute. Silakan coba lagi.',
      );
    }
  }

  void _parseOptimizedRouteDataSafely(dynamic data) {
    try {
      _parseMapboxRouteData(data as Map<String, dynamic>);
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Data rute tidak valid',
        'Server mengirim data rute yang tidak dapat diproses. Silakan coba lagi nanti.',
      );
    }
  }

  void _parseMapboxRouteData(Map<String, dynamic> map) {
    final waypoints = map['waypoints'] as List? ?? [];
    optimizedWaypoints.value = waypoints
        .whereType<Map<String, dynamic>>()
        .map<LatLng?>((wp) {
          final location = wp['location'];
          if (location is List && location.length >= 2) {
            final lng = double.tryParse(location[0].toString());
            final lat = double.tryParse(location[1].toString());
            if (lat != null && lng != null) {
              return LatLng(lat, lng);
            }
          }
          return null;
        })
        .whereType<LatLng>()
        .toList();

    final routes = map['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No routes found in Mapbox response');
    }

    routes.sort((a, b) {
      final durationA = (a as Map<String, dynamic>)['duration'] as num?;
      final durationB = (b as Map<String, dynamic>)['duration'] as num?;
      return (durationA ?? double.infinity)
          .compareTo(durationB ?? double.infinity);
    });

    final parsedOptions = <RouteOption>[];
    final maxRoutes = routes.length < 2 ? routes.length : 2;
    for (int i = 0; i < maxRoutes; i++) {
      final route = routes[i] as Map<String, dynamic>;
      final summaryRaw = (route['summary'] ?? '').toString().trim();
      parsedOptions.add(
        RouteOption(
          id: 'route_$i',
          index: i,
          points: _extractRouteCoordinates(route),
          steps: _extractRouteSteps(route),
          distance: (route['distance'] as num?)?.toDouble() ?? 0.0,
          duration: (route['duration'] as num?)?.toDouble() ?? 0.0,
          summary: summaryRaw.isNotEmpty ? summaryRaw : 'Rute ${i + 1}',
        ),
      );
    }

    routeOptions.assignAll(parsedOptions);

    if (routeOptions.isEmpty) {
      routePoints.clear();
      routeSteps.clear();
      totalRouteDistance.value = 0.0;
      totalRouteDuration.value = 0.0;
      remainingRouteDistance.value = 0.0;
      remainingRouteDuration.value = 0.0;
      nextInstruction.value = '';
      routeActive.value = false;
      return;
    }

    _applyRouteSelection(0);
  }

  void _applyRouteSelection(int index, {bool triggerFeedback = false}) {
    if (index < 0 || index >= routeOptions.length) {
      if (triggerFeedback) {
        _showUserMessage('Rute tidak tersedia',
            'Pilihan rute tidak dapat digunakan saat ini.');
      }
      return;
    }

    final alreadySelected = selectedRouteIndex.value == index;
    final label = index == 0 ? 'Rute tercepat' : 'Rute ${index + 1}';
    final option = routeOptions[index];

    if (alreadySelected) {
      selectedRouteIndex.refresh();
    } else {
      selectedRouteIndex.value = index;
    }
    routePoints.value = List<LatLng>.from(option.points);
    routeSteps.value = option.steps
        .map<Map<String, dynamic>>((step) => Map<String, dynamic>.from(step))
        .toList();
    totalRouteDistance.value = option.distance;
    totalRouteDuration.value = option.duration;
    remainingRouteDistance.value = option.distance;
    remainingRouteDuration.value = option.duration;
    nextInstruction.value = routeSteps.isNotEmpty
        ? routeSteps.first['instruction']?.toString() ?? ''
        : '';
    routeActive.value = routePoints.isNotEmpty;

    if (triggerFeedback) {
      if (alreadySelected) {
        _showUserMessage('Rute diperbarui', '$label diperbarui.');
      } else {
        _showUserMessage('Rute diperbarui', '$label kini aktif.');
      }
    }

    if (userLocation.value != null) {
      _updateRemainingMetrics(userLocation.value);
    }

    update();
  }

  List<LatLng> _extractRouteCoordinates(Map<String, dynamic> route) {
    final geometry = route['geometry'];
    if (geometry is Map<String, dynamic>) {
      final coordinates = geometry['coordinates'] as List? ?? [];
      return coordinates
          .map<LatLng?>((coord) {
            if (coord is List && coord.length >= 2) {
              final lng = double.tryParse(coord[0].toString());
              final lat = double.tryParse(coord[1].toString());
              if (lat != null && lng != null) {
                return LatLng(lat, lng);
              }
            }
            return null;
          })
          .whereType<LatLng>()
          .toList();
    }

    throw Exception('Geometry data is missing');
  }

  List<Map<String, dynamic>> _extractRouteSteps(Map<String, dynamic> route) {
    final legs = route['legs'] as List? ?? [];
    if (legs.isEmpty) return <Map<String, dynamic>>[];

    final steps = (legs.first as Map<String, dynamic>)['steps'] as List? ?? [];
    return steps.map<Map<String, dynamic>>((step) {
      final stepMap = step as Map<String, dynamic>;
      final maneuver = stepMap['maneuver'] as Map<String, dynamic>?;
      final instruction = (maneuver?['instruction'] ?? '').toString();
      final modifier = (maneuver?['modifier'] ?? '').toString();
      final type = (maneuver?['type'] ?? '').toString();
      final name = (stepMap['name'] ?? '').toString();
      return {
        'instruction':
            instruction.isEmpty ? parseManeuver(maneuver) : instruction,
        'distance': (stepMap['distance'] as num?)?.toDouble() ?? 0.0,
        'duration': (stepMap['duration'] as num?)?.toDouble() ?? 0.0,
        'type': type,
        'modifier': modifier,
        'name': name.isEmpty ? 'Jalan tanpa nama' : name,
      };
    }).toList();
  }

  String _mapboxProfileForVehicle(String vehicle) {
    switch (vehicle) {
      case 'car':
        return 'driving-traffic';
      case 'motorcycle':
        return 'driving';
      default:
        return 'driving';
    }
  }

  void useAlternativeRoute(int index) {
    selectRouteByIndex(index, showFeedback: true);
  }

  void selectRouteByIndex(int index, {bool showFeedback = false}) {
    _applyRouteSelection(index, triggerFeedback: showFeedback);
  }

  void selectRouteById(String routeId, {bool showFeedback = false}) {
    final idx = routeOptions.indexWhere(
      (option) => option.id.toLowerCase() == routeId.toLowerCase(),
    );
    if (idx != -1) {
      _applyRouteSelection(idx, triggerFeedback: showFeedback);
    } else if (showFeedback) {
      _showUserMessage(
        'Rute tidak ditemukan',
        'Rute yang dipilih tidak tersedia. Silakan pilih rute lain.',
      );
    }
  }

  Future<void> fetchSearchSuggestions(String query) async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        searchSuggestions.clear();
        return;
      }

      if (!MapboxConfig.isTokenValid()) {
        searchSuggestions.clear();
        _showUserMessage(
          'Token Mapbox tidak tersedia',
          'Pastikan MAPBOX_ACCESS_TOKEN sudah dikonfigurasi pada aplikasi.',
        );
        return;
      }

      try {
        final encodedQuery = Uri.encodeComponent(query.trim());
        final params = <String, dynamic>{
          'access_token': MapboxConfig.accessToken,
          'autocomplete': 'true',
          'limit': '6',
          'language': 'id',
          'country': 'ID',
          'types': 'address,poi,place,neighborhood,locality',
          'bbox':
              '$_jakartaMinLon,$_jakartaMinLat,$_jakartaMaxLon,$_jakartaMaxLat',
        };

        if (userLocation.value != null) {
          params['proximity'] =
              '${userLocation.value!.longitude},${userLocation.value!.latitude}';
        }

        final response = await _dio.get(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedQuery.json',
          queryParameters: params,
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

        final features = (response.data['features'] as List?) ?? [];
        final suggestions = features
            .whereType<Map<String, dynamic>>()
            .where(_isFeatureWithinJakarta)
            .map<Map<String, dynamic>>((feature) {
              final center = feature['center'] as List?;
              if (center == null || center.length < 2) {
                return {};
              }

              final lon = double.tryParse(center[0].toString());
              final lat = double.tryParse(center[1].toString());
              if (lat == null || lon == null) {
                return {};
              }

              final placeName = (feature['place_name'] ?? '').toString();
              final textPrimary = (feature['text'] ?? '').toString();
              final placeTypes =
                  (feature['place_type'] as List?)?.map((e) => e.toString()) ??
                      [];

              return {
                'id': feature['id'],
                'display_name':
                    textPrimary.isNotEmpty ? textPrimary : placeName,
                'place_name': placeName,
                'lat': lat,
                'lon': lon,
                'type': placeTypes.isNotEmpty ? placeTypes.first : 'unknown',
                'context': feature['context'],
              };
            })
            .where((item) => item.isNotEmpty)
            .toList();

        final currentLocation = userLocation.value;
        if (currentLocation != null) {
          suggestions.sort((a, b) {
            final latA = (a['lat'] as num).toDouble();
            final lonA = (a['lon'] as num).toDouble();
            final latB = (b['lat'] as num).toDouble();
            final lonB = (b['lon'] as num).toDouble();

            final distanceA = calculateDistance(
              currentLocation,
              LatLng(latA, lonA),
            );
            final distanceB = calculateDistance(
              currentLocation,
              LatLng(latB, lonB),
            );
            return distanceA.compareTo(distanceB);
          });
        }

        searchSuggestions.value = suggestions;
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
      'address': 'Alamat',
      'neighborhood': 'Lingkungan',
      'locality': 'Area Lokal',
      'place': 'Tempat',
      'region': 'Provinsi/Wilayah',
      'district': 'Kecamatan',
      'postcode': 'Kode Pos',
      'poi': 'Titik Menarik',
      'poi.landmark': 'Landmark',
      'country': 'Negara',
      'airport': 'Bandara',
      'suburb': 'Kawasan',
      'street': 'Jalan',
      'park': 'Taman',
      'natural_feature': 'Objek Alam',
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

  void selectDestinationSuggestion(Map<String, dynamic> suggestion) {
    final latValue = suggestion['lat'];
    final lonValue = suggestion['lon'];
    if (latValue == null || lonValue == null) return;

    final lat = double.tryParse(latValue.toString());
    final lon = double.tryParse(lonValue.toString());
    if (lat == null || lon == null) return;

    destination.value = LatLng(lat, lon);
    destinationLabel.value =
        suggestion['display_name']?.toString() ?? 'Tujuan perjalanan';
    destinationAddress.value =
        suggestion['place_name']?.toString() ?? destinationLabel.value;
    if (selectedVehicle.value.isEmpty) {
      selectedVehicle.value = 'motorcycle';
    }
    fetchOptimizedRoute();
  }

  void clearRoute() {
    routePoints.clear();
    routeSteps.clear();
    optimizedWaypoints.clear();
    destination.value = null;
    routeOptions.clear();
    selectedRouteIndex.value = 0;
    searchSuggestions.clear();
    totalRouteDistance.value = 0;
    totalRouteDuration.value = 0;
    remainingRouteDistance.value = 0;
    remainingRouteDuration.value = 0;
    nextInstruction.value = '';
    destinationLabel.value = '';
    destinationAddress.value = '';
    routeActive.value = false;
    update();
  }

  void _updateRemainingMetrics(LatLng? currentLocation) {
    if (currentLocation == null || routePoints.isEmpty) {
      return;
    }

    final index = _findNearestPointIndex(currentLocation, routePoints);
    if (index == null) {
      return;
    }

    double distanceToNextPoint =
        calculateDistance(currentLocation, routePoints[index]);

    double remainingDistance = distanceToNextPoint;
    for (int i = index; i < routePoints.length - 1; i++) {
      remainingDistance +=
          calculateDistance(routePoints[i], routePoints[i + 1]);
    }

    remainingRouteDistance.value =
        remainingDistance.clamp(0, totalRouteDistance.value).toDouble();

    if (totalRouteDistance.value > 0) {
      final ratio = remainingRouteDistance.value / totalRouteDistance.value;
      remainingRouteDuration.value = (totalRouteDuration.value * ratio)
          .clamp(0, totalRouteDuration.value)
          .toDouble();
    } else {
      remainingRouteDuration.value = 0;
    }

    final distanceCovered =
        (totalRouteDistance.value - remainingRouteDistance.value)
            .clamp(0, totalRouteDistance.value);
    double accumulated = 0;
    String instruction = '';

    for (final step in routeSteps) {
      final stepDistance = (step['distance'] as num?)?.toDouble() ?? 0.0;
      accumulated += stepDistance;
      if (accumulated >= distanceCovered) {
        instruction = step['instruction']?.toString() ?? '';
        break;
      }
    }

    nextInstruction.value = instruction;

    if (remainingRouteDistance.value <= 30) {
      remainingRouteDistance.value = 0;
      remainingRouteDuration.value = 0;
      nextInstruction.value = 'Anda telah tiba di tujuan';
      if (routePoints.isNotEmpty) {
        routePoints.clear();
      }
      if (optimizedWaypoints.isNotEmpty) {
        optimizedWaypoints.clear();
      }
      if (routeOptions.isNotEmpty) {
        routeOptions.clear();
        selectedRouteIndex.value = 0;
      }
      routeActive.value = false;
    } else {
      routeActive.value = true;
    }
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _debounceTimer?.cancel();
    _compassSubscription?.cancel();
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

  static const double _jakartaMinLon = 106.4;
  static const double _jakartaMaxLon = 107.3;
  static const double _jakartaMinLat = -6.6;
  static const double _jakartaMaxLat = -5.8;
  static const List<String> _jakartaKeywords = [
    'jakarta',
    'dki',
    'kepulauan seribu',
    'tangerang',
    'tangerang selatan',
    'bekasi',
    'depok',
    'bogor',
  ];

  bool _isFeatureWithinJakarta(Map<String, dynamic> feature) {
    final center = feature['center'] as List?;
    if (center == null || center.length < 2) {
      return false;
    }

    final lon = double.tryParse(center[0].toString());
    final lat = double.tryParse(center[1].toString());
    if (lat == null || lon == null) {
      return false;
    }

    final withinBounds = lon >= _jakartaMinLon &&
        lon <= _jakartaMaxLon &&
        lat >= _jakartaMinLat &&
        lat <= _jakartaMaxLat;
    if (!withinBounds) {
      return false;
    }

    final placeName = (feature['place_name'] ?? '').toString().toLowerCase();
    final primaryText = (feature['text'] ?? '').toString().toLowerCase();
    if (_jakartaKeywords.any((keyword) =>
        placeName.contains(keyword) || primaryText.contains(keyword))) {
      return true;
    }

    final contexts =
        (feature['context'] as List?)?.whereType<Map<String, dynamic>>() ?? [];
    for (final ctx in contexts) {
      final ctxText = (ctx['text'] ?? '').toString().toLowerCase();
      final ctxPlace = (ctx['place_name'] ?? '').toString().toLowerCase();
      final ctxId = (ctx['id'] ?? '').toString().toLowerCase();
      final matchesKeyword = _jakartaKeywords.any(
        (keyword) => ctxText.contains(keyword) || ctxPlace.contains(keyword),
      );
      if (matchesKeyword || ctxId.contains('id-jk')) {
        return true;
      }
    }

    return false;
  }

  void _logError(Object e, StackTrace? st) {
    if (st != null) {}
  }
}

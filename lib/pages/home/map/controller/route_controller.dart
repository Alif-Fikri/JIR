import 'dart:async';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:JIR/helper/google_maps_config.dart';
import 'package:JIR/services/navigation_service/navigation_foreground_service.dart';

part 'route_controller_places.dart';
part 'route_controller_routes.dart';
part 'route_controller_navigation.dart';

class RouteOption {
  RouteOption({
    required this.id,
    required this.index,
    required this.points,
    required this.steps,
    required this.distance,
    required this.duration,
    required this.summary,
    this.durationTypical = 0.0,
    this.trafficDelay = 0.0,
  });

  final String id;
  final int index;
  final List<LatLng> points;
  final List<Map<String, dynamic>> steps;
  final double distance;
  final double duration;
  final String summary;
  final double durationTypical;
  final double trafficDelay;
}

class _RouteRequestOutcome {
  const _RouteRequestOutcome._(this.success, this.message, this.code);

  factory _RouteRequestOutcome.success() =>
      const _RouteRequestOutcome._(true, null, null);

  factory _RouteRequestOutcome.failure({String? message, String? code}) =>
      _RouteRequestOutcome._(false, message, code);

  final bool success;
  final String? message;
  final String? code;
}

class RouteController extends GetxController {
  final Dio _dio = Dio();
  final PolylinePoints _polylinePoints = PolylinePoints();
  String? _placesSessionToken;
  final RxList<Map<String, dynamic>> routeSteps = <Map<String, dynamic>>[].obs;
  final RxString selectedVehicle = 'motorcycle'.obs;
  final RxBool isLoading = false.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> destination = Rx<LatLng?>(null);
  final RxList<LatLng> optimizedWaypoints = <LatLng>[].obs;
  final RxList<RouteOption> routeOptions = <RouteOption>[].obs;
  final RxInt selectedRouteIndex = 0.obs;
  final RxList<LatLng> activeRoutePolyline = <LatLng>[].obs;
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
  bool _foregroundServiceActive = false;
  DateTime? _lastForegroundUpdate;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  void _initialize() async {
    if (!GoogleMapsConfig.isValid()) {
      _showUserMessage(
        'API Google Maps tidak ditemukan',
        'Pastikan GOOGLE_MAPS_API_KEY sudah dikonfigurasi pada berkas .env.',
      );
    }
    _resetPlacesSession();
    await _getUserLocation();
    startPoint = userLocation.value;
    _startLocationUpdates();
    _startCompassUpdates();
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

  void updateVehicle(String vehicle) {
    selectedVehicle.value = vehicle;
    fetchOptimizedRoute();
  }

  String? _extractGoogleErrorMessage(dynamic data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        final message = error['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final status = error['status']?.toString();
        if (status != null && status.isNotEmpty) {
          return status;
        }
      }

      final errorMessage = data['error_message']?.toString();
      if (errorMessage != null && errorMessage.isNotEmpty) {
        return errorMessage;
      }

      final status = data['status']?.toString();
      if (status != null && status.isNotEmpty && status != 'OK') {
        return status;
      }
    }
    return null;
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
    activeRoutePolyline.assignAll(routePoints);
    totalRouteDistance.value = option.distance;
    final adjustedTotal = adjustedDuration(
      option.duration,
      vehicle: selectedVehicle.value,
    );
    totalRouteDuration.value = adjustedTotal;
    remainingRouteDistance.value = option.distance;
    remainingRouteDuration.value = adjustedTotal;
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

    _syncForegroundNotification(forceStart: true);

    update();
  }

  List<LatLng> _decodePolyline(String encoded) {
    if (encoded.isEmpty) return const <LatLng>[];
    final points = _polylinePoints.decodePolyline(encoded);
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  String _stripHtml(String input) {
    if (input.isEmpty) return '';
    final withoutTags = input.replaceAll(RegExp(r'<[^>]+>'), ' ');
    final decoded = withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<');
    return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  double _vehicleDurationMultiplier(String vehicle) {
    switch (vehicle) {
      case 'car':
        return 1.25;
      case 'motorcycle':
        return 0.88;
      default:
        return 1.0;
    }
  }

  double adjustedDuration(num baseSeconds, {String? vehicle}) {
    final key = (vehicle ?? selectedVehicle.value).isEmpty
        ? 'motorcycle'
        : (vehicle ?? selectedVehicle.value);
    final multiplier = _vehicleDurationMultiplier(key);
    final raw = baseSeconds.toDouble();
    return (raw * multiplier).clamp(0, double.maxFinite);
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
      final trimmed = query.trim();
      if (trimmed.isEmpty) {
        searchSuggestions.clear();
        return;
      }

      if (!GoogleMapsConfig.isValid()) {
        searchSuggestions.clear();
        _showUserMessage(
          'API Google Maps tidak tersedia',
          'Pastikan GOOGLE_MAPS_API_KEY sudah dikonfigurasi pada aplikasi.',
        );
        return;
      }

      try {
        final locationBias = userLocation.value;
        _placesSessionToken ??=
            DateTime.now().millisecondsSinceEpoch.toString();
        final Map<String, Map<String, dynamic>> uniqueSuggestions = {};

        Future<void> collect(List<Map<String, dynamic>> results) async {
          for (final suggestion in results) {
            final id = suggestion['id']?.toString();
            if (id == null || id.isEmpty) continue;
            final current = uniqueSuggestions[id];
            if (current == null) {
              uniqueSuggestions[id] = suggestion;
            } else {
              final currentDistance =
                  (current['distance_meters'] as num?)?.toDouble() ??
                      double.maxFinite;
              final newDistance =
                  (suggestion['distance_meters'] as num?)?.toDouble() ??
                      double.maxFinite;
              if (newDistance < currentDistance) {
                uniqueSuggestions[id] = suggestion;
              }
            }
            if (uniqueSuggestions.length >= 12) break;
          }
        }

        Future<void> tryFetch(
          String source,
          Future<List<Map<String, dynamic>>> Function() fetcher,
        ) async {
          try {
            final items = await fetcher();
            await collect(items);
          } catch (e, st) {
            if (e is DioException) {
              final payload = e.response?.data;
              if (payload != null) {
                debugPrint(
                    '[RouteController][Places][$source][payload] $payload');
              }
            }
            _logError(e, st, 'Places:$source');
          }
        }

        await tryFetch(
          'searchText',
          () => _searchPlacesByText(trimmed, locationBias),
        );

        if (uniqueSuggestions.length < 6) {
          await tryFetch(
            'autocomplete',
            () => _searchPlacesAutocomplete(trimmed, locationBias),
          );
        }

        if (uniqueSuggestions.length < 6 && locationBias != null) {
          await tryFetch(
            'nearby',
            () => _searchPlacesNearby(trimmed, locationBias),
          );
        }

        if (uniqueSuggestions.isEmpty) {
          searchSuggestions.clear();
          return;
        }

        final allSuggestions = uniqueSuggestions.values.toList()
          ..sort((a, b) {
            final aDistance =
                (a['distance_meters'] as num?)?.toDouble() ?? double.maxFinite;
            final bDistance =
                (b['distance_meters'] as num?)?.toDouble() ?? double.maxFinite;
            if (aDistance == bDistance) {
              final aName = (a['display_name']?.toString() ?? '').toLowerCase();
              final bName = (b['display_name']?.toString() ?? '').toLowerCase();
              return aName.compareTo(bName);
            }
            return aDistance.compareTo(bDistance);
          });

        final prioritized = allSuggestions.where((item) {
          final placeName = (item['place_name'] ?? '').toString().toLowerCase();
          final displayName =
              (item['display_name'] ?? '').toString().toLowerCase();
          return _containsJakartaKeyword(placeName) ||
              _containsJakartaKeyword(displayName);
        }).toList();

        final effective = prioritized.isNotEmpty
            ? prioritized.take(6).toList()
            : allSuggestions.take(6).toList();

        searchSuggestions.value = effective;
      } on DioException catch (e) {
        _logError(e, e.stackTrace);
        _showUserMessage(
          'Pencarian gagal',
          'Tidak dapat melakukan pencarian. Periksa koneksi Anda.',
        );
      } catch (e, st) {
        _logError(e, st);
        _showUserMessage(
          'Pencarian gagal',
          'Terjadi kesalahan saat mencari. Silakan coba lagi.',
        );
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

  static String formatDuration(num seconds) {
    if (seconds.isNaN || seconds.isInfinite || seconds <= 0) {
      return 'Tiba sebentar lagi';
    }

    final totalMinutes = (seconds / 60).round().clamp(1, 1000000);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours jam $minutes menit';
    }
    if (hours > 0) {
      return '$hours jam';
    }
    return '$minutes menit';
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

  Future<void> selectDestinationSuggestion(
      Map<String, dynamic> suggestion) async {
    final rawPlaceId = suggestion['id']?.toString();
    if (rawPlaceId == null || rawPlaceId.isEmpty) {
      return;
    }

    final placeId = rawPlaceId.startsWith('places/')
        ? rawPlaceId.split('/').last
        : rawPlaceId;

    if (!GoogleMapsConfig.isValid()) {
      _showUserMessage(
        'API Google Maps tidak tersedia',
        'Tidak dapat mengambil detail lokasi saat ini.',
      );
      return;
    }

    try {
      final lookupId =
          placeId.startsWith('places/') ? placeId.split('/').last : placeId;
      final encodedPlaceId = Uri.encodeComponent(lookupId);
      final queryParams = {
        'languageCode': 'id',
        'regionCode': 'ID',
        if (_placesSessionToken != null) 'sessionToken': _placesSessionToken!,
      };

      final detailsFieldMask = [
        'id',
        'displayName.text',
        'formattedAddress',
        'types',
        'location.latitude',
        'location.longitude',
        'addressComponents',
      ].join(',');

      final response = await _dio.get(
        'https://places.googleapis.com/v1/places/$encodedPlaceId',
        queryParameters: queryParams,
        options: Options(
          headers: _buildPlacesHeaders(
            fieldMask: detailsFieldMask,
            includeSessionToken: true,
          ),
          responseType: ResponseType.json,
        ),
      );

      final result = (response.data as Map?)?.cast<String, dynamic>();
      if (result == null) {
        _showUserMessage(
          'Detil lokasi tidak ditemukan',
          'Silakan coba pilihan lokasi lainnya.',
        );
        return;
      }

      final location = (result['location'] as Map?)?.cast<String, dynamic>();
      final lat = double.tryParse(location?['latitude']?.toString() ?? '');
      final lon = double.tryParse(location?['longitude']?.toString() ?? '');

      if (lat == null || lon == null) {
        _showUserMessage(
          'Lokasi tidak ditemukan',
          'Detail koordinat tidak tersedia untuk pilihan ini.',
        );
        return;
      }

      final displayName = (result['displayName'] as Map?)?['text']?.toString();
      final formattedAddress = result['formattedAddress']?.toString();

      destination.value = LatLng(lat, lon);
      destinationLabel.value = displayName ??
          suggestion['display_name']?.toString() ??
          'Tujuan perjalanan';
      destinationAddress.value = formattedAddress ??
          suggestion['place_name']?.toString() ??
          destinationLabel.value;
      if (selectedVehicle.value.isEmpty) {
        selectedVehicle.value = 'motorcycle';
      }
      _resetPlacesSession();
      await fetchOptimizedRoute();
    } on DioException catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Gagal mengambil detail lokasi',
        'Tidak dapat mendapatkan koordinat untuk lokasi yang dipilih.',
      );
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Gagal mengambil detail lokasi',
        'Terjadi kesalahan saat memproses lokasi yang dipilih.',
      );
    }
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
    activeRoutePolyline.clear();
    _syncForegroundNotification();
    update();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _debounceTimer?.cancel();
    _compassSubscription?.cancel();
    if (_foregroundServiceActive) {
      unawaited(NavigationForegroundBridge.stop());
      _foregroundServiceActive = false;
      _lastForegroundUpdate = null;
    }
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

  bool _containsJakartaKeyword(String value) {
    if (value.isEmpty) return true;
    for (final keyword in _jakartaKeywords) {
      if (value.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  void _logError(Object e, StackTrace? st, [String? context]) {
    final prefix =
        context != null ? '[RouteController][$context]' : '[RouteController]';
    debugPrint('$prefix $e');
    if (st != null) {
      debugPrint(st.toString());
    }
  }
}

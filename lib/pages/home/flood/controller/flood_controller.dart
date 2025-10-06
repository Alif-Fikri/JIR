import 'dart:math' as math;

import 'package:JIR/pages/home/flood/widgets/flood_item_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:JIR/services/flood_service/flood_api_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

class FloodMonitoringController extends GetxController {
  final currentLocation = Rxn<LatLng>();
  LatLng? _pendingCenter;
  double? _pendingZoom;
  bool _manualCenterRequested = false;
  final floodData = <Map<String, dynamic>>[].obs;
  final suggestions = <Map<String, dynamic>>[].obs;

  mb.MapboxMap? _mapboxMap;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  bool _didInitialCameraMove = false;

  @override
  void onInit() {
    super.onInit();
    fetchFloodData();
    getCurrentLocation();
    searchController.addListener(() {
      updateSuggestions(searchController.text);
    });
    ever(currentLocation, (_) {
      final loc = currentLocation.value;
      if (loc != null && !_didInitialCameraMove && !_manualCenterRequested) {
        _moveCamera(loc, zoom: 15.0);
        _didInitialCameraMove = true;
      }
    });
  }

  void setMapController(mb.MapboxMap map) {
    _mapboxMap = map;
    if (_pendingCenter != null) {
      final target = _pendingCenter!;
      final zoom = _pendingZoom ?? 15.0;
      _pendingCenter = null;
      _pendingZoom = null;
      _moveCamera(target, zoom: zoom);
      _didInitialCameraMove = true;
      return;
    }

    final loc = currentLocation.value;
    if (!_manualCenterRequested && !_didInitialCameraMove && loc != null) {
      debugPrint('[FloodController] Moving to user location: $loc');
      _moveCamera(loc, zoom: 15.0);
      _didInitialCameraMove = true;
    }
  }

  Future<void> fetchFloodData() async {
    try {
      final service = FloodService();
      final data = await service.fetchFloodData();
      final normalized = data.map((item) {
        final name =
            (item["NAMA_PINTU_AIR"] ?? item["LOKASI"] ?? "N/A").toString();
        final lat = double.tryParse(item["LATITUDE"]?.toString() ?? '') ?? 0.0;
        final lon = double.tryParse(item["LONGITUDE"]?.toString() ?? '') ?? 0.0;
        final rawStatus = item["STATUS_SIAGA"];
        final statusStr = _formatStatus(rawStatus);
        final rawHeight = item["TINGGI_AIR"];
        final height =
            rawHeight == null ? 0 : int.tryParse(rawHeight.toString()) ?? 0;
        final tanggal = (item["TANGGAL"] ?? "").toString();
        return {
          "NAMA_PINTU_AIR": name,
          "LATITUDE": lat,
          "LONGITUDE": lon,
          "STATUS_SIAGA": statusStr,
          "TINGGI_AIR": height,
          "TANGGAL": tanggal,
          "RAW": item,
        };
      }).toList();
      floodData.assignAll(normalized);
    } catch (e, stack) {
      debugPrint('[FloodController] fetchFloodData error: $e');
      debugPrint(stack.toString());
    }
  }

  void updateSuggestions(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      suggestions.clear();
      return;
    }
    final found = floodData.where((item) {
      return item["NAMA_PINTU_AIR"].toString().toLowerCase().contains(query);
    }).toList();
    suggestions.assignAll(found.take(10).toList());
  }

  void selectSuggestion(Map<String, dynamic> item) {
    _manualCenterRequested = true;
    final lat = item["LATITUDE"] as double;
    final lon = item["LONGITUDE"] as double;
    final target = LatLng(lat, lon);
    _moveCamera(target, zoom: 15.0);
    _openFloodInfo(item, history: _historyForLocation(item));
    suggestions.clear();
    searchController.text = item["NAMA_PINTU_AIR"].toString();
    FocusScope.of(Get.context!).unfocus();
  }

  void onMarkerDataTap(Map<String, dynamic> item) {
    _manualCenterRequested = true;
    final lat = _coerceDouble(item["LATITUDE"]);
    final lon = _coerceDouble(item["LONGITUDE"]);
    if (lat != null && lon != null) {
      _moveCamera(LatLng(lat, lon), zoom: 15.0);
    }
    _openFloodInfo(item, history: _historyForLocation(item));
  }

  void _openFloodInfo(Map<String, dynamic> item,
      {List<Map<String, dynamic>>? history}) {
    final String statusStr = item["STATUS_SIAGA"]?.toString() ?? "Unknown";
    final int height = item["TINGGI_AIR"] is int
        ? item["TINGGI_AIR"] as int
        : int.tryParse(item["TINGGI_AIR"].toString()) ?? 0;
    final String name = item["NAMA_PINTU_AIR"]?.toString() ?? "N/A";
    final List<Map<String, dynamic>> series =
        history ?? _historyForLocation(item);
    Get.bottomSheet(
      FloodInfoBottomSheet(
        status: statusStr,
        statusIconPath: "assets/images/siaga.png",
        waterHeight: height,
        waterIconPath: "assets/images/ketinggian.png",
        location: name,
        locationIconPath: "assets/images/lokasi.png",
        floodData: series,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> getCurrentLocation({bool forceRecenter = false}) async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final latlng = LatLng(pos.latitude, pos.longitude);
      currentLocation.value = latlng;
      if (forceRecenter) {
        _manualCenterRequested = false;
        _moveCamera(latlng, zoom: 15.0);
        _didInitialCameraMove = true;
        return;
      }

      if (!_manualCenterRequested && !_didInitialCameraMove) {
        _moveCamera(latlng, zoom: 15.0);
        _didInitialCameraMove = true;
      }
    } catch (e, stack) {
      debugPrint('[FloodController] getCurrentLocation error: $e');
      debugPrint(stack.toString());
    }
  }

  Future<void> searchLocation(String query, {BuildContext? context}) async {
    final q = query.trim();
    if (q.isEmpty) {
      if (context != null) FocusScope.of(context).unfocus();
      return;
    }
    if (context != null) FocusScope.of(context).unfocus();
    try {
      final found = floodData.firstWhere(
        (item) => item["NAMA_PINTU_AIR"]
            .toString()
            .toLowerCase()
            .contains(q.toLowerCase()),
        orElse: () => {},
      );
      if (found.isNotEmpty) {
        final lat = found["LATITUDE"] as double;
        final lon = found["LONGITUDE"] as double;
        final target = LatLng(lat, lon);
        _manualCenterRequested = true;
        _moveCamera(target, zoom: 15.0);
        _openFloodInfo(found, history: _historyForLocation(found));
        return;
      }
    } catch (e, stack) {
      debugPrint('[FloodController] searchLocation data lookup error: $e');
      debugPrint(stack.toString());
    }
    try {
      final locations = await locationFromAddress(q);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final target = LatLng(loc.latitude, loc.longitude);
        _manualCenterRequested = true;
        _moveCamera(target, zoom: 15.0);
        return;
      }
    } catch (e, stack) {
      debugPrint('[FloodController] searchLocation geocode error: $e');
      debugPrint(stack.toString());
    }
    Get.snackbar('Tidak Ditemukan', 'Lokasi atau data banjir tidak ditemukan');
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocus.dispose();
    suggestions.clear();
    super.onClose();
  }

  void gotoLocation(LatLng loc, {double zoom = 15.0}) {
    try {
      debugPrint(
          '[FloodController] gotoLocation requested: $loc (mapReady=${_mapboxMap != null})');
      _manualCenterRequested = true;
      _moveCamera(loc, zoom: zoom);
      if (_mapboxMap == null) {
        _pendingCenter = loc;
        _pendingZoom = zoom;
      } else {
        _didInitialCameraMove = true;
      }
    } catch (e, stack) {
      debugPrint('[FloodController] gotoLocation error: $e');
      debugPrint(stack.toString());
    }
  }

  Future<void> _moveCamera(LatLng target, {double zoom = 15.0}) async {
    final map = _mapboxMap;
    if (map == null) {
      _pendingCenter = target;
      _pendingZoom = zoom;
      return;
    }
    _pendingCenter = null;
    _pendingZoom = null;
    try {
      await map.flyTo(
        mb.CameraOptions(center: _toPoint(target), zoom: zoom),
        mb.MapAnimationOptions(duration: 700),
      );
    } catch (e, stack) {
      debugPrint('[FloodController] _moveCamera error: $e');
      debugPrint(stack.toString());
    }
  }

  mb.Point _toPoint(LatLng value) =>
      mb.Point(coordinates: mb.Position(value.longitude, value.latitude));

  String _formatStatus(dynamic statusRaw) {
    if (statusRaw == null) return 'Normal';
    if (statusRaw is String) {
      var s = statusRaw.trim();
      final digits = RegExp(r'\d+').firstMatch(s)?.group(0);
      if (digits != null) {
        final n = int.tryParse(digits);
        if (n != null) return _mapIntToStatus(n);
      }
      final maybeNum = int.tryParse(s);
      if (maybeNum != null) return _mapIntToStatus(maybeNum);
      s = s.replaceAll(RegExp(r'status\s*:?\s*', caseSensitive: false), '');
      if (s.isEmpty) return 'Normal';
      return s;
    }
    if (statusRaw is int) return _mapIntToStatus(statusRaw);
    final str = statusRaw.toString();
    final digits = RegExp(r'\d+').firstMatch(str)?.group(0);
    if (digits != null) {
      final n = int.tryParse(digits);
      if (n != null) return _mapIntToStatus(n);
    }
    final cleaned =
        str.replaceAll(RegExp(r'status\s*:?\s*', caseSensitive: false), '');
    return cleaned.isEmpty ? 'Normal' : cleaned;
  }

  String _mapIntToStatus(int v) {
    switch (v) {
      case 3:
        return 'Siaga 3';
      case 2:
        return 'Siaga 2';
      case 1:
        return 'Siaga 1';
      default:
        return 'Normal';
    }
  }

  List<Map<String, dynamic>> _historyForLocation(
      Map<String, dynamic> reference) {
    final name = reference["NAMA_PINTU_AIR"]?.toString().trim().toLowerCase();
    final lat = _coerceDouble(reference["LATITUDE"]);
    final lon = _coerceDouble(reference["LONGITUDE"]);

    final matches = floodData
        .where((item) {
          final itemName =
              item["NAMA_PINTU_AIR"]?.toString().trim().toLowerCase() ?? '';
          final itemLat = _coerceDouble(item["LATITUDE"]);
          final itemLon = _coerceDouble(item["LONGITUDE"]);

          final nameMatches =
              name != null && name.isNotEmpty && itemName == name;
          final coordsMatch = lat != null &&
              lon != null &&
              itemLat != null &&
              itemLon != null &&
              (itemLat - lat).abs() < 0.0001 &&
              (itemLon - lon).abs() < 0.0001;

          return nameMatches || coordsMatch;
        })
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    matches.sort((a, b) {
      final aDate = DateTime.tryParse(a["TANGGAL"]?.toString() ?? '');
      final bDate = DateTime.tryParse(b["TANGGAL"]?.toString() ?? '');
      if (aDate != null && bDate != null) {
        return aDate.compareTo(bDate);
      }
      if (aDate != null) return 1;
      if (bDate != null) return -1;
      return a["NAMA_PINTU_AIR"]
          .toString()
          .compareTo(b["NAMA_PINTU_AIR"].toString());
    });

    if (matches.isEmpty) {
      matches.add(Map<String, dynamic>.from(reference));
    }

    const int minimumSamples = 6;
    if (matches.length < minimumSamples) {
      final seed = _buildSeed(name, lat, lon);
      final status = reference["STATUS_SIAGA"];
      DateTime anchor = DateTime.tryParse(
            matches.first["TANGGAL"]?.toString() ?? '',
          ) ??
          DateTime.now();
      int currentHeight = _extractHeight(matches.first);
      int safetyOffset = 1;

      while (matches.length < minimumSamples) {
        anchor = anchor.subtract(const Duration(hours: 2));
        final synthetic = Map<String, dynamic>.from(reference);
        final delta = _generateDelta(seed, safetyOffset++);
        final adjustedHeight = math.max(0, currentHeight + delta);
        synthetic["TINGGI_AIR"] = adjustedHeight;
        synthetic["TANGGAL"] = anchor.toIso8601String();
        synthetic["STATUS_SIAGA"] = status;
        matches.insert(0, synthetic);
        currentHeight = adjustedHeight;
      }
    }

    return matches;
  }

  double? _coerceDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int _extractHeight(Map<String, dynamic> item) {
    final raw = item["TINGGI_AIR"];
    if (raw is int) return raw;
    if (raw is double) return raw.round();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  int _buildSeed(String? name, double? lat, double? lon) {
    final nameSeed = name?.hashCode ?? 0;
    final latSeed = lat != null ? (lat * 10000).round() : 0;
    final lonSeed = lon != null ? (lon * 10000).round() : 0;
    return nameSeed ^ latSeed ^ lonSeed;
  }

  int _generateDelta(int seed, int step) {
    final random = math.Random((seed + step).abs());
    return random.nextInt(5) - 2; 
  }
}

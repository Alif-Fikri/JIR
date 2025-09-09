import 'package:JIR/pages/home/flood/widgets/flood_item_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:JIR/services/flood_service/flood_api_service.dart';
import 'package:JIR/pages/home/flood/widgets/radar_map.dart';

class FloodMonitoringController extends GetxController {
  var currentLocation = Rxn<LatLng>();
  var floodMarkers = <Marker>[].obs;
  var floodData = <Map<String, dynamic>>[].obs;
  var suggestions = <Map<String, dynamic>>[].obs;

  MapController? mapController;
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
      if (loc != null && mapController != null && !_didInitialCameraMove) {
        try {
          mapController!.move(loc, 15.0);
          _didInitialCameraMove = true;
        } catch (_) {}
      }
    });
  }

  void setMapController(MapController mc) {
    mapController = mc;
    final loc = currentLocation.value;
    try {
      if (!_didInitialCameraMove && loc != null) {
        mapController!.move(loc, 15.0);
        _didInitialCameraMove = true;
      }
    } catch (_) {}
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
      final markers = normalized.map((item) {
        final lat = item["LATITUDE"] as double;
        final lon = item["LONGITUDE"] as double;
        return Marker(
          point: LatLng(lat, lon),
          width: 36,
          height: 36,
          child: GestureDetector(
            onTap: () => _openFloodInfo(item),
            child: const RadarMarker(color: Colors.red),
          ),
        );
      }).toList();
      floodMarkers.assignAll(markers);
    } catch (e) {
      print("Error fetching flood data: $e");
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
    final lat = item["LATITUDE"] as double;
    final lon = item["LONGITUDE"] as double;
    final target = LatLng(lat, lon);
    try {
      mapController?.move(target, 15.0);
    } catch (_) {}
    _openFloodInfo(item);
    suggestions.clear();
    searchController.text = item["NAMA_PINTU_AIR"].toString();
    FocusScope.of(Get.context!).unfocus();
  }

  void _openFloodInfo(Map<String, dynamic> item) {
    final String statusStr = item["STATUS_SIAGA"]?.toString() ?? "Unknown";
    final int height = item["TINGGI_AIR"] is int
        ? item["TINGGI_AIR"] as int
        : int.tryParse(item["TINGGI_AIR"].toString()) ?? 0;
    final String name = item["NAMA_PINTU_AIR"]?.toString() ?? "N/A";
    Get.bottomSheet(
      FloodInfoBottomSheet(
        status: statusStr,
        statusIconPath: "assets/images/siaga.png",
        waterHeight: height,
        waterIconPath: "assets/images/ketinggian.png",
        location: name,
        locationIconPath: "assets/images/lokasi.png",
        floodData: floodData,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Lokasi dinonaktifkan', 'Silakan aktifkan layanan lokasi');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          Get.snackbar('Izin ditolak', 'Izin lokasi diperlukan');
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      LatLng current = LatLng(position.latitude, position.longitude);
      currentLocation.value = current;
      try {
        mapController?.move(current, 15.0);
      } catch (_) {}
    } catch (e) {
      print("Failed to get current location: $e");
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
        try {
          mapController?.move(target, 15.0);
        } catch (_) {}
        _openFloodInfo(found);
        return;
      }
    } catch (_) {}
    try {
      final locations = await locationFromAddress(q);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final target = LatLng(loc.latitude, loc.longitude);
        try {
          mapController?.move(target, 15.0);
        } catch (_) {}
        return;
      }
    } catch (e) {
      print("Geocoding error: $e");
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

  String _formatStatus(dynamic statusRaw) {
    if (statusRaw == null) return 'Status : Normal';
    if (statusRaw is String) {
      final s = statusRaw.trim();
      if (s.toLowerCase().startsWith('status')) return s;
      final digits = RegExp(r'\d+').firstMatch(s)?.group(0);
      if (digits != null) {
        final n = int.tryParse(digits);
        if (n != null) return _mapIntToStatus(n);
      }
      final maybeNum = int.tryParse(s);
      if (maybeNum != null) return _mapIntToStatus(maybeNum);
      return 'Status : $s';
    }
    if (statusRaw is int) return _mapIntToStatus(statusRaw);
    final str = statusRaw.toString();
    final digits = RegExp(r'\d+').firstMatch(str)?.group(0);
    if (digits != null) {
      final n = int.tryParse(digits);
      if (n != null) return _mapIntToStatus(n);
    }
    return 'Status : $str';
  }

  String _mapIntToStatus(int v) {
    switch (v) {
      case 3:
        return 'Status : Siaga 3';
      case 2:
        return 'Status : Siaga 2';
      case 1:
        return 'Status : Siaga 1';
      default:
        return 'Status : Normal';
    }
  }
}

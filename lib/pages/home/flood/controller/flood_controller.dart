import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:JIR/pages/home/flood/widgets/flood_item_data.dart';
import 'package:JIR/services/flood_service/flood_api_service.dart';
import 'package:JIR/pages/home/flood/widgets/radar_map.dart';

class FloodMonitoringController extends GetxController {
  var currentLocation = const LatLng(-6.200000, 106.816666).obs;
  var floodMarkers = <Marker>[].obs;
  var floodData = <Map<String, dynamic>>[].obs;

  late MapController mapController;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    _fetchFloodData();
    getCurrentLocation();
  }

  // GET FLOOD DATA
  Future<void> _fetchFloodData() async {
    try {
      final service = FloodService();
      final data = await service.fetchFloodData();

      floodData.assignAll(data);

      final markers = data.map((item) {
        double lat = double.tryParse(item["LATITUDE"].toString()) ?? 0.0;
        double lng = double.tryParse(item["LONGITUDE"].toString()) ?? 0.0;

        return Marker(
          point: LatLng(lat, lng),
          child: GestureDetector(
            onTap: () {
              Get.bottomSheet(
                FloodInfoBottomSheet(
                  status: item["STATUS_SIAGA"] ?? "Unknown",
                  statusIconPath: "assets/images/siaga.png",
                  waterHeight: int.tryParse(item["TINGGI_AIR"].toString()) ?? 0,
                  waterIconPath: "assets/images/ketinggian.png",
                  location: item["NAMA_PINTU_AIR"] ?? "N/A",
                  locationIconPath: "assets/images/lokasi.png",
                  floodData: floodData,
                ),
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              );
            },
            child: const RadarMarker(color: Colors.red),
          ),
        );
      }).toList();

      floodMarkers.assignAll(markers);
    } catch (e) {
      print("Error fetching flood data: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location Disabled', 'Please enable GPS service');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          Get.snackbar('Permission Denied', 'Location permission is required');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng current = LatLng(position.latitude, position.longitude);
      currentLocation.value = current;
      mapController.move(current, 15.0);
    } catch (e) {
      print("Failed to get current location: $e");
    }
  }

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        LatLng searchedLocation = LatLng(loc.latitude, loc.longitude);
        mapController.move(searchedLocation, 15.0);
      } else {
        Get.snackbar('Not Found', 'Location not found');
      }
    } catch (e) {
      print("Lokasi tidak ditemukan: $e");
    }
  }
}

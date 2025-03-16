import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:smartcitys/pages/home/flood/widgets/flood_item_data.dart';
import 'package:smartcitys/services/flood_service/flood_api_service.dart';
import 'package:smartcitys/pages/home/flood/widgets/radar_map.dart';

class FloodMonitoringController extends GetxController {
  var currentLocation = const LatLng(-6.200000, 106.816666).obs;
  var floodMarkers = <Marker>[].obs;
  var floodData = <Map<String, dynamic>>[].obs;
  late MapController mapController;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _fetchFloodData();
  }

  Future<void> _fetchFloodData() async {
    try {
      final service = FloodService();
      final data = await service.fetchFloodData();

      floodData.value = data;
      floodMarkers.value = data.map((item) {
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
    } catch (e) {
      print("Error fetching flood data: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng current = LatLng(position.latitude, position.longitude);
    mapController.move(current, 15.0);
  }

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        LatLng searchedLocation = LatLng(loc.latitude, loc.longitude);
        mapController.move(searchedLocation, 15.0);
      }
    } catch (e) {
      print("Lokasi tidak ditemukan: $e");
      Get.snackbar('Error', 'Lokasi tidak ditemukan');
    }
  }
}

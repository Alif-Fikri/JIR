import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartcitys/helper/map.dart';
import 'package:smartcitys/pages/home/flood/controller/flood_controller.dart';

class FloodMonitoringPage extends StatelessWidget {
  final LatLng? initialLocation;
  final FloodMonitoringController controller = Get.put(FloodMonitoringController());

  FloodMonitoringPage({super.key, this.initialLocation});

  @override
  Widget build(BuildContext context) {

    if (initialLocation != null) {
      controller.currentLocation.value = initialLocation!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banjir'),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            return ReusableMap(
              initialLocation: controller.currentLocation.value,
              markers: controller.floodMarkers,
              onMapCreated: (mapController) {
                controller.mapController = mapController;
              },
            );
          }),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search . . .',
                        hintStyle: GoogleFonts.inter(
                            color: Colors.black, fontStyle: FontStyle.italic),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.black),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                      ),
                      onSubmitted: controller.searchLocation,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: controller.getCurrentLocation,
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

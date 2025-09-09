import 'package:JIR/helper/map.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:JIR/pages/home/flood/controller/flood_controller.dart';
import 'package:flutter_map/flutter_map.dart';

class FloodMonitoringPage extends StatelessWidget {
  final LatLng? initialLocation;
  final FloodMonitoringController controller =
      Get.put(FloodMonitoringController());

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
            final lat = controller.currentLocation.value;
            final userMarker = lat != null
                ? Marker(
                    point: lat,
                    width: 60,
                    height: 60,
                    child: UserLocationMarker(),
                  )
                : null;
            final combined = [
              ...controller.floodMarkers,
              if (userMarker != null) userMarker
            ];
            return ReusableMap(
              markers: combined,
              initialLocation: controller.currentLocation.value,
              onMapCreated: (mapCtrl) {
                controller.setMapController(mapCtrl);
              },
            );
          }),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
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
                                spreadRadius: 2),
                          ],
                        ),
                        child: TextField(
                          focusNode: controller.searchFocus,
                          controller: controller.searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari nama pintu air atau alamat...',
                            hintStyle: GoogleFonts.inter(
                                color: Colors.black,
                                fontStyle: FontStyle.italic),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.black),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send, color: Colors.black),
                              onPressed: () => controller.searchLocation(
                                controller.searchController.text,
                                context: context,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) => controller
                              .searchLocation(value, context: context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: () {
                        controller.getCurrentLocation();
                        FocusScope.of(context).unfocus();
                      },
                      backgroundColor: Colors.white,
                      mini: true,
                      child: const Icon(Icons.my_location, color: Colors.black),
                    ),
                  ],
                ),
                Obx(() {
                  final s = controller.suggestions;
                  if (s.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6)
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: s.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = s[index];
                        return ListTile(
                          title: Text(item["NAMA_PINTU_AIR"].toString(),
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(item["STATUS_SIAGA"].toString(),
                              style: GoogleFonts.inter(fontSize: 12)),
                          onTap: () => controller.selectSuggestion(item),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

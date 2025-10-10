import 'package:JIR/helper/google_map_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:JIR/pages/home/flood/controller/flood_controller.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';
import 'package:latlong2/latlong.dart' as ll;

class FloodMonitoringPage extends StatelessWidget {
  final LatLng? initialLocation;
  final FloodMonitoringController controller =
      Get.put(FloodMonitoringController());
  final RouteController routeController = Get.find<RouteController>();

  FloodMonitoringPage({super.key, this.initialLocation});

  @override
  Widget build(BuildContext context) {
    final arg = initialLocation ??
        (Get.arguments is LatLng ? Get.arguments as LatLng : null);
    if (arg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.gotoLocation(arg);
      });
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
            final floodDataList = controller.floodData.toList();
            final floodPositions = controller.floodData.map((item) {
              final lat =
                  double.tryParse(item['LATITUDE']?.toString() ?? '0') ?? 0.0;
              final lng =
                  double.tryParse(item['LONGITUDE']?.toString() ?? '0') ?? 0.0;
              return ll.LatLng(lat, lng);
            }).toList();

            final userLocation = controller.currentLocation.value;
            final userPosition = userLocation != null
                ? ll.LatLng(userLocation.latitude, userLocation.longitude)
                : null;

            final waypoints = routeController.optimizedWaypoints
                .map((p) => ll.LatLng(p.latitude, p.longitude))
                .toList();

            final routePolyline = routeController.routePoints
                .map((p) => ll.LatLng(p.latitude, p.longitude))
                .toList();

            final routeLines = routePolyline.length >= 2
                ? [
                    RouteLineConfig(
                      id: 'active-route',
                      points: routePolyline,
                      color: const Color(0xFF2563EB),
                      width: 5.0,
                      opacity: 0.9,
                    ),
                  ]
                : const <RouteLineConfig>[];

            return JirMapView(
              initialLocation: userPosition ??
                  (floodPositions.isNotEmpty ? floodPositions.first : null),
              markers: floodPositions,
              markerData: floodDataList,
              userLocation: userPosition,
              routeLines: routeLines,
              waypoints: waypoints,
              enableMyLocation: true,
              onMarkerDataTap: controller.onMarkerDataTap,
              onMapCreated: controller.setMapController,
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
                        controller.getCurrentLocation(forceRecenter: true);
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

import 'package:JIR/helper/map.dart';
import 'package:JIR/helper/mapbox_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:JIR/pages/home/flood/controller/flood_controller.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class FloodMonitoringPage extends StatelessWidget {
  final LatLng? initialLocation;
  final FloodMonitoringController controller =
      Get.put(FloodMonitoringController());
  final RouteController routeController = Get.isRegistered<RouteController>()
      ? Get.find<RouteController>()
      : Get.put(RouteController());

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

            print(
                '[FLOOD PAGE] floodPositions length=${floodPositions.length}');

            final userLocation = controller.currentLocation.value;
            final userPosition = userLocation != null
                ? ll.LatLng(userLocation.latitude, userLocation.longitude)
                : null;

            final routePoints = routeController.routePoints
                .map((p) => ll.LatLng(p.latitude, p.longitude))
                .toList();
            final waypoints = routeController.optimizedWaypoints
                .map((p) => ll.LatLng(p.latitude, p.longitude))
                .toList();

            return MapboxReusableMap(
              accessToken: MapboxConfig.accessToken,
              styleUri: MapboxStyles.MAPBOX_STREETS,
              initialLocation: userPosition,
              markers: floodPositions,
              markerData: floodDataList,
              userLocation: userPosition,
              routePoints: routePoints,
              waypoints: waypoints,
              onMarkerDataTap: controller.onMarkerDataTap,
              onMapCreated: (mbMap) {
                controller
                    .setMapController(mbMap);
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

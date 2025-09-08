import 'package:JIR/pages/home/map/controller/route_controller_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapFromChatFullGPSNav extends StatelessWidget {
  const MapFromChatFullGPSNav({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RouteControllerForChat());
    final mapController = MapController();

    return Scaffold(
      appBar: AppBar(title: const Text("Navigation Mode")),
      body: Obx(() {
        // if (controller.polylinePoints.isNotEmpty) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     mapController.fitBounds(
        //       LatLngBounds.fromPoints(controller.polylinePoints),
        //       options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
        //     );
        //   });
        // }

        return Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                // center: controller.userLocation.value ?? LatLng(0, 0),
                // zoom: 15,
                maxZoom: 18,
                minZoom: 5,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.polylinePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (controller.startLocation.value != null)
                      Marker(
                        point: controller.startLocation.value!,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.my_location,
                            color: Colors.green, size: 30),
                      ),
                    if (controller.endLocation.value != null)
                      Marker(
                        point: controller.endLocation.value!,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_on,
                            color: Colors.red, size: 30),
                      ),
                    ...controller.waypoints.map((wp) => Marker(
                          point: wp,
                          width: 30,
                          height: 30,
                          child: Icon(Icons.circle,
                              color: Colors.orange, size: 15),
                        )),
                    ...controller.floodMarkers.map((f) => Marker(
                          point: f,
                          width: 30,
                          height: 30,
                          child: Icon(Icons.warning,
                              color: Colors.redAccent, size: 25),
                        )),
                    if (controller.userLocation.value != null)
                      Marker(
                        point: controller.userLocation.value!,
                        width: 50,
                        height: 50,
                        child: AnimatedBuilder(
                          animation: controller.pulseController,
                          builder: (_, child) {
                            return Transform.rotate(
                              angle:
                                  controller.userHeading.value * 3.1415 / 180,
                              child: Container(
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width:
                                          50 * controller.pulseAnimation.value,
                                      height:
                                          50 * controller.pulseAnimation.value,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const Icon(Icons.navigation,
                                        color: Colors.blue, size: 35),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (controller.steps.isNotEmpty)
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white70,
                  height: 180,
                  child: Obx(() {
                    return ListView.separated(
                      itemCount: controller.steps.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) {
                        final step = controller.steps[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                controller.activeStepIndex.value == index
                                    ? Colors.blue
                                    : Colors.grey,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(step['instruction'] ?? ''),
                          subtitle: Text("${step['distance']} meter"),
                        );
                      },
                    );
                  }),
                ),
              ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Obx(() => FloatingActionButton(
                    onPressed: () {
                      controller.isNavigating.value
                          ? controller.stopNavigation()
                          : controller.startNavigation();
                    },
                    child: Icon(controller.isNavigating.value
                        ? Icons.stop
                        : Icons.play_arrow),
                  )),
            ),
          ],
        );
      }),
    );
  }
}

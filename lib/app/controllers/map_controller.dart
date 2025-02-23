// import 'package:flutter_map/flutter_map.dart';
// import 'package:get/get.dart';
// import 'package:latlong2/latlong.dart';

// class GlobalMapController extends GetxController {
//   final MapController mapController = MapController();
//   final Rx<LatLng> initialLocation = const LatLng(-6.2088, 106.8456).obs;
//   final RxList<Marker> markers = <Marker>[].obs;
//   final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
//   final Rx<LatLng?> destination = Rx<LatLng?>(null);
//   final RxList<LatLng> routePoints = <LatLng>[].obs;

//   void updateMarkers(List<Marker> newMarkers) {
//     markers.assignAll(newMarkers);
//   }

//   void moveToLocation(LatLng location) {
//     mapController.move(location, mapController.camera.zoom);
//   }
// }

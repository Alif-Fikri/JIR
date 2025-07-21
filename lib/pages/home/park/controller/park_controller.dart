import 'dart:convert';
import 'package:JIR/helper/loading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:JIR/config.dart';

class ParkSimple {
  final String name;
  final String? street;
  final double latitude;
  final double longitude;

  ParkSimple({
    required this.name,
    this.street,
    required this.latitude,
    required this.longitude,
  });

  factory ParkSimple.fromJson(Map<String, dynamic> json) {
    return ParkSimple(
      name: json['name'],
      street: json['street'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class ParksController extends GetxController {
  final RxList<ParkSimple> parks = <ParkSimple>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble currentLat = 0.0.obs;
  final RxDouble currentLon = 0.0.obs;
  final String parkUrl = "$mainUrl/api/parks/simple";
  final RxString currentAddress = 'Mendapatkan lokasi...'.obs;
  final RxList<ParkSimple> nearbyParks = <ParkSimple>[].obs;
  final RxList<ParkSimple> otherParks = <ParkSimple>[].obs;

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      currentLat.value = position.latitude;
      currentLon.value = position.longitude;
      await _getCurrentAddress(position);
      await fetchNearbyParks();
    } catch (e) {
      errorMessage.value = 'Gagal mendapatkan lokasi: $e';
    }
  }

  Future<void> _getCurrentAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;
      currentAddress.value = [place.street, place.subLocality]
          .where((part) => part != null && part.isNotEmpty)
          .join(', ');
    } catch (e) {
      currentAddress.value = 'Lokasi tidak diketahui';
    }
  }

  Future<void> fetchNearbyParks() async {
    try {
      isLoading.value = true;

      final response = await http.get(Uri.parse(parkUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allParks = data.map((park) => ParkSimple.fromJson(park)).toList();

        allParks.sort((a, b) =>
            calculateDistanceInMeters(a.latitude, a.longitude)
                .compareTo(calculateDistanceInMeters(b.latitude, b.longitude)));

        nearbyParks.value = allParks.take(5).toList();
        otherParks.value = allParks.skip(5).take(20).toList();
      }
    } catch (e) {
      Future.delayed(Duration.zero, () {
        Get.off(() => const LoadingPage());
      });
    } finally {
      isLoading.value = false;
    }
  }

  double calculateDistanceInMeters(double lat, double lon) {
    if (currentLat.value == 0.0 || currentLon.value == 0.0) return 0.0;

    return Geolocator.distanceBetween(
      currentLat.value,
      currentLon.value,
      lat,
      lon,
    );
  }

  String formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}

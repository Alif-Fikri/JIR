import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController with StateMixin<Map<String, dynamic>> {
  final RxString temperature = "".obs;
  final RxString location = "".obs;
  final RxString weatherDescription = "".obs;
  final RxString backgroundImage = "".obs;
  final RxString weatherImage = "".obs;

  @override
  void onInit() {
    super.onInit();
    _getLocationAndWeather();
  }

  Future<void> _getLocationAndWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? locality = placemarks.first.locality;
      location.value = locality?.replaceFirst("Kecamatan ", "") ?? "Unknown Location";

      String kodeWilayah = getKodeWilayahBMKG(location.value);

      final response = await http.get(Uri.parse('https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=$kodeWilayah'));

      if (response.statusCode != 200) {
        throw Exception('Failed to load weather data');
      }

      final data = json.decode(response.body);

      final forecast = data['data']['forecast'][0];
      final cuaca = forecast['cuaca'];
      final suhuMin = forecast['temperature']['min'];
      final suhuMax = forecast['temperature']['max'];

      temperature.value = "$suhuMin°C - $suhuMax°C";
      weatherDescription.value = cuaca;

      change({
        'temperature': temperature.value,
        'location': location.value,
        'description': weatherDescription.value
      }, status: RxStatus.success());

    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  String getKodeWilayahBMKG(String? locality) {
    switch (locality) {
      case "Jakarta Selatan":
        return "3173041004";
      case "Jakarta Pusat":
        return "3171031003";
      case "Jakarta Utara":
        return "3172031001";
      case "Jakarta Barat":
        return "3174031001";
      case "Jakarta Timur":
        return "3175031001";
      default:
        return "3171031003"; 
    }
  }
}

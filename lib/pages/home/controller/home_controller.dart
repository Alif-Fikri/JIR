import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartcitys/helper/weathertranslator.dart';

class HomeController extends GetxController with StateMixin<Map<String, dynamic>> {
  final WeatherFactory _weatherFactory = WeatherFactory(dotenv.env['WEATHER_API_KEY']!);
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

      Weather? weather = await _weatherFactory.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Update State
      temperature.value = weather.temperature?.celsius?.toStringAsFixed(1) ?? "N/A";
      location.value = placemarks.first.locality?.replaceFirst("Kecamatan ", "") ?? "Unknown Location";
      weatherDescription.value = WeatherTranslator.translate(weather.weatherDescription);
      
      change({
        'temperature': temperature.value,
        'location': location.value,
        'description': weatherDescription.value
      }, status: RxStatus.success());

    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}
import 'package:JIR/pages/home/weather/service/weather_service.dart';
import 'package:get/get.dart';

class WeatherController extends GetxController {
  final WeatherService service = WeatherService();
  var loading = true.obs;
  var error = ''.obs;
  var temperature = 0.0.obs;
  var description = ''.obs;
  var location = ''.obs;

  @override
  void onInit() {
    fetchWeather();
    super.onInit();
  }

  Future<void> fetchWeather() async {
    try {
      loading(true);
      final data = await service.fetchWeather();
      temperature.value = data['temperature']?.toDouble() ?? 0.0;
      description.value = data['description'] ?? '';
      location.value = data['location'] ?? 'Lokasi tidak diketahui';
      error.value = '';
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading(false);
    }
  }
}

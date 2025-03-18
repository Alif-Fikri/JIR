import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:smartcitys/pages/home/weather/weather_helper.dart';
import 'package:weather/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;

  var temperature = 'Loading...'.obs;
  var location = 'Loading...'.obs;
  var weatherDescription = 'Loading...'.obs;
  var weatherIcon = ''.obs;
  var backgroundImage = ''.obs;
  var isLoading = true.obs;

  late WeatherFactory wf;

  @override
  void onInit() {
    super.onInit();
    wf = WeatherFactory(dotenv.env['WEATHER_API_KEY']!);
    _initAnimation();
    fetchData();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void _initAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> fetchData() async {
    isLoading(true);
    await _getLocationAndWeather();
    isLoading(false);
  }

  Future<void> _getLocationAndWeather() async {
    _setLoadingState();

    try {
      if (!await _handleLocationPermission()) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weather = await wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.isNotEmpty ? placemarks.first : const Placemark();

      temperature.value = weather.temperature?.celsius?.toStringAsFixed(1) ?? 'N/A';
      location.value = place.locality?.replaceFirst("Kecamatan ", "") ?? 'Unknown Location';
      weatherDescription.value = WeatherHelper.translateWeather(weather.weatherDescription);
      weatherIcon.value = WeatherHelper.getImageForWeather(weather.weatherDescription);

      final currentHour = DateTime.now().hour;
      backgroundImage.value = WeatherHelper.getBackgroundImage(currentHour);

    } catch (e) {
      debugPrint('Error: $e');
      _setError('Failed to fetch data');
    }
  }

  void _setLoadingState() {
    location.value = 'Loading...';
    temperature.value = 'Loading...';
    weatherDescription.value = 'Loading...';
    weatherIcon.value = '';
    backgroundImage.value = '';
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setError('Location permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setError('Location permission permanently denied. Please enable location in settings.');
      return false;
    }

    return true;
  }

  void _setError(String message) {
    location.value = message;
    temperature.value = 'N/A';
    weatherDescription.value = 'N/A';
    weatherIcon.value = 'assets/images/Cuaca Smart City Icon-01.png'; 
    final currentHour = DateTime.now().hour;
    backgroundImage.value = WeatherHelper.getBackgroundImage(currentHour);
  }
}

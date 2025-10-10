import 'dart:async';
import 'package:JIR/pages/home/weather/service/weather_service.dart';
import 'package:JIR/pages/home/weather/widget/weather_helper.dart';
import 'package:JIR/services/news_service/news_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;

  var temperature = 'Loading...'.obs;
  var location = 'Loading...'.obs;
  var weatherDescription = 'Loading...'.obs;
  var weatherIcon = ''.obs;
  var backgroundImage = ''.obs;
  var weatherConditionType = ''.obs;
  var isLoading = true.obs;

  var newsList = <NewsItem>[].obs;
  var isNewsLoading = false.obs;
  var newsIndex = 0.obs;

  late final WeatherService _weatherService;
  WeatherCurrent? _cachedWeather;
  Placemark? _cachedPlacemark;
  Position? _cachedPosition;

  Position? get lastKnownPosition => _cachedPosition;

  Future<Position?> ensurePosition({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPosition != null) {
      return _cachedPosition;
    }

    if (!await _handleLocationPermission()) {
      return null;
    }

    final position = await _getPositionWithFallback();
    if (position != null) {
      _cachedPosition = position;
    }
    return position;
  }

  @override
  void onInit() {
    super.onInit();
    _weatherService = WeatherService();
    _initAnimation();
    fetchData();
    fetchNews();
  }

  void setNewsIndex(int i) => newsIndex.value = i;

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

  Future<void> refreshData() async {
    await fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await _getLocationAndWeather().timeout(const Duration(seconds: 15));
    } on TimeoutException catch (e) {
      debugPrint('HomeController.fetchData timeout: $e');
      _setError('Gagal memuat data cuaca (timeout)');
    } catch (e, st) {
      debugPrint('HomeController.fetchData error: $e');
      debugPrintStack(stackTrace: st);
      _setError('Gagal memuat data cuaca');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getLocationAndWeather() async {
    _setLoadingState();

    try {
      if (!await _handleLocationPermission()) {
        return;
      }

      final position = await _getPositionWithFallback();
      if (position == null) {
        debugPrint('HomeController: unable to obtain location');
        _setError('Lokasi tidak tersedia');
        return;
      }
      _cachedPosition = position;

      late WeatherCurrent weather;
      try {
        weather = await _weatherService
            .fetchCurrent(lat: position.latitude, lon: position.longitude)
            .timeout(const Duration(seconds: 10));
        _cachedWeather = weather;
      } on TimeoutException catch (e) {
        debugPrint('HomeController weather timeout: $e');
        if (_cachedWeather != null) {
          weather = _cachedWeather!;
        } else {
          throw TimeoutException('Weather service timeout');
        }
      }

      List<Placemark> placemarks = const [];
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 8));
        if (placemarks.isNotEmpty) {
          _cachedPlacemark = placemarks.first;
        }
      } on TimeoutException catch (e) {
        debugPrint('HomeController placemark timeout: $e');
        if (_cachedPlacemark != null) {
          placemarks = [_cachedPlacemark!];
        }
      }

      final place = placemarks.isNotEmpty
          ? placemarks.first
          : _cachedPlacemark ?? const Placemark();

      if (!weather.temperatureCelsius.isNaN) {
        temperature.value = weather.temperatureCelsius.toStringAsFixed(1);
      } else if (temperature.value.isEmpty ||
          temperature.value == 'Loading...' ||
          temperature.value == 'N/A') {
        temperature.value = 'N/A';
      }
      location.value = place.locality?.replaceFirst('Kecamatan ', '') ??
          (location.value.isNotEmpty && location.value != 'Loading...'
              ? location.value
              : 'Unknown Location');
      final rawDescription = weather.description.isNotEmpty
          ? weather.description
          : weather.conditionType;
      weatherConditionType.value = weather.conditionType;
      weatherDescription.value = WeatherHelper.translateWeather(
        rawDescription,
        conditionType: weather.conditionType,
      );
      weatherIcon.value = WeatherHelper.getImageForWeather(
        rawDescription,
        conditionType: weather.conditionType,
      );

      final currentHour = DateTime.now().hour;
      backgroundImage.value = WeatherHelper.getBackgroundImage(currentHour);
    } catch (e, st) {
      debugPrint('Error: $e');
      debugPrintStack(stackTrace: st);
      _setError('Failed to fetch data');
    }
  }

  Future<Position?> _getPositionWithFallback() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));
    } on TimeoutException catch (e) {
      debugPrint('HomeController position timeout: $e');
      return await Geolocator.getLastKnownPosition();
    } catch (e, st) {
      debugPrint('HomeController position error: $e');
      debugPrintStack(stackTrace: st);
      if (_cachedPosition != null) {
        return _cachedPosition;
      }
      final last = await Geolocator.getLastKnownPosition();
      return last;
    }
  }

  void _setLoadingState() {
    location.value = 'Loading...';
    temperature.value = 'Loading...';
    weatherDescription.value = 'Loading...';
    weatherIcon.value = '';
    backgroundImage.value = '';
    weatherConditionType.value = '';
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
      _setError(
          'Location permission permanently denied. Please enable location in settings.');
      return false;
    }

    return true;
  }

  void _setError(String message) {
    location.value = message;
    temperature.value = 'N/A';
    weatherDescription.value = 'N/A';
    weatherIcon.value = 'assets/images/Cuaca Smart City Icon-01.png';
    weatherConditionType.value = '';
    final currentHour = DateTime.now().hour;
    backgroundImage.value = WeatherHelper.getBackgroundImage(currentHour);
  }

  Future<void> fetchNews() async {
    try {
      isNewsLoading.value = true;
      final items = await NewsService.fetchNews();
      newsList.assignAll(items);
    } finally {
      isNewsLoading.value = false;
    }
  }
}

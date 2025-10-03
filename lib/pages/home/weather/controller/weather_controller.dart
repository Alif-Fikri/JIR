import 'package:get/get.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/pages/home/weather/widget/weather_helper.dart';
import 'package:JIR/pages/home/weather/service/weather_service.dart';

class WeatherController extends GetxController {
  final RxBool loading = true.obs;
  final RxString error = ''.obs;
  final RxString temperature = ''.obs;
  final RxString description = ''.obs;
  final RxString location = ''.obs;
  final RxString temperatureRange = ''.obs;
  final RxString weatherIcon = ''.obs;
  final RxString backgroundImage = ''.obs;
  final RxString username = 'Pengguna'.obs;

  final RxList<Map<String, dynamic>> hourlyWindow = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> history = <Map<String, dynamic>>[].obs;

  HomeController? _homeController;
  late final AuthService _authService;
  late final WeatherService _service;
  final List<Worker> _workers = [];

  @override
  void onInit() {
    super.onInit();
    _auth_service_init();
    _service = WeatherService();
    _homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    _initUsername();
    _bindHomeData();
    fetchHourlyWindow();
  }

  Future<void> _auth_service_init() async {
    _auth_service_init_sync();
  }

  void _auth_service_init_sync() {
    _authService = Get.find<AuthService>();
  }

  Future<void> fetchHourlyWindow() async {
    try {
      final list = await _service.fetchHourlyWindow(before: 2, after: 2);
      hourlyWindow.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> fetchHistory({int hours = 24}) async {
    try {
      final list = await _service.fetchHistory(hours: hours);
      history.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> refreshWeather() async {
    if (_homeController == null) return;
    try {
      await _homeController!.refreshData();
      await fetchHourlyWindow();
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> _initUsername() async {
    try {
      final profile = await _authService.fetchProfile();
      final raw = (profile['username'] ?? profile['name'] ?? '') as dynamic;
      final value = raw is String ? raw.trim() : raw?.toString().trim();
      if (value != null && value.isNotEmpty) {
        username.value = value;
      } else {
        username.value = 'Pengguna';
      }
    } catch (_) {
      username.value = 'Pengguna';
    }
  }

  void _bindHomeData() {
    final home = _homeController;
    if (home == null) {
      loading.value = false;
      error.value = 'Home controller tidak tersedia';
      return;
    }

    void sync() {
      loading.value = home.isLoading.value;
      if (home.isLoading.value) {
        error.value = '';
        return;
      }

      final rawTemp = home.temperature.value.trim();
      temperature.value = rawTemp;
      final parsedTemp = double.tryParse(rawTemp.replaceAll(',', '.'));
      if (parsedTemp != null) {
        temperatureRange.value = '${parsedTemp.toStringAsFixed(1)}° C';
      } else if (rawTemp.isNotEmpty && !rawTemp.toLowerCase().contains('loading')) {
        temperatureRange.value = rawTemp;
      } else {
        temperatureRange.value = '-';
      }

      final rawDescription = home.weatherDescription.value;
      description.value = WeatherHelper.translateWeather(rawDescription);

      final loc = home.location.value;
      location.value = loc.isNotEmpty ? loc : 'Lokasi tidak diketahui';

      final iconPath = home.weatherIcon.value;
      weatherIcon.value = iconPath.isNotEmpty ? iconPath : 'assets/images/Cuaca Smart City Icon-01.png';

      final bg = home.backgroundImage.value;
      backgroundImage.value = bg.isNotEmpty ? bg : '';

      error.value = '';
    }

    sync();

    _workers.addAll([
      ever(home.isLoading, (_) => sync()),
      ever(home.temperature, (_) => sync()),
      ever(home.weatherDescription, (_) => sync()),
      ever(home.location, (_) => sync()),
      ever(home.weatherIcon, (_) => sync()),
      ever(home.backgroundImage, (_) => sync()),
    ]);
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }
}

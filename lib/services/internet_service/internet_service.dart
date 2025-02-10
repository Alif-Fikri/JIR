import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:smartcitys/app/routes/app_routes.dart';
import 'package:smartcitys/helper/no_connection.dart';

class InternetService extends GetxController {
  final Connectivity connectivity = Connectivity();
  StreamSubscription? _connectionSubscription;
  bool _isNoInternetPageShown = false;
  String? _lastRoute; // Private variable
  String? get lastRoute => _lastRoute; // Getter public
  set lastRoute(String? route) => _lastRoute = route; // Setter public

  Future<bool> checkConnection() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _startMonitoring() {
    _connectionSubscription = connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) => _updateConnectionStatus(result),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      if (!_isNoInternetPageShown) {
        _isNoInternetPageShown = true;
        _lastRoute = Get.currentRoute;
        Get.offAll(
          () => const NoInternetPage(),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 300),
          
        );
      }
    } else {
      if (_isNoInternetPageShown) {
        _isNoInternetPageShown = false;
        if (_lastRoute != null && _lastRoute != AppRoutes.noInternet) {
          Get.offAllNamed(_lastRoute!);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    super.onClose();
  }
}
import 'package:get/get.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/pages/home/map/controller/flood_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Get.put(GlobalMapController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FloodController>(() => FloodController());
  }
}

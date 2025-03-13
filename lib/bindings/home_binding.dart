import 'package:get/get.dart';
import 'package:smartcitys/pages/home/controller/home_controller.dart';
import 'package:smartcitys/pages/home/map/controller/flood_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Get.put(GlobalMapController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FloodController>(() => FloodController());
  }
}

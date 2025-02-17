import 'package:get/get.dart';
import 'package:smartcitys/app/controllers/report_controller.dart';

class ReportBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(() => ReportController());
  }
}

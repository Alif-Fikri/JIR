import 'package:get/get.dart';
import 'package:smartcitys/pages/home/report/controller/report_controller.dart';

class ReportBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(() => ReportController());
  }
}

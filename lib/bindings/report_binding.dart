import 'package:get/get.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';

class ReportBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ReportController>(ReportController(), permanent: true);
  }
}

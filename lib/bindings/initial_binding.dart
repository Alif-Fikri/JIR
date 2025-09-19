import 'package:JIR/bindings/profile_binding.dart';
import 'package:JIR/pages/notifications/controller/notification_controller.dart';
import 'package:get/get.dart';
import 'package:JIR/bindings/auth_binding.dart';
import 'package:JIR/bindings/home_binding.dart';
import 'package:JIR/bindings/report_binding.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(NotificationController());
    AuthBinding().dependencies();
    ReportBinding().dependencies();
    HomeBinding().dependencies();
    ProfileBinding().dependencies();
  }
}

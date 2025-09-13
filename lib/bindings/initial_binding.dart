import 'package:JIR/bindings/profile_binding.dart';
import 'package:JIR/services/notification_service/notification_service.dart';
import 'package:get/get.dart';
import 'package:JIR/bindings/auth_binding.dart';
import 'package:JIR/bindings/home_binding.dart';
import 'package:JIR/bindings/report_binding.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    ReportBinding().dependencies();
    HomeBinding().dependencies();
    ProfileBinding().dependencies();
    NotificationService.I.init();
  }
}

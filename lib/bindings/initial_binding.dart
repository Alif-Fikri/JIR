import 'package:get/get.dart';
import 'package:smartcitys/bindings/auth_binding.dart';
import 'package:smartcitys/bindings/home_binding.dart';
import 'package:smartcitys/bindings/report_binding.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    ReportBinding().dependencies();
    HomeBinding().dependencies();
  }
}

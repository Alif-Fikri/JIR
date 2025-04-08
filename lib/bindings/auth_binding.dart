import 'package:get/get.dart';
import 'package:JIR/pages/auth/controller/login_controller.dart';
import 'package:JIR/pages/auth/controller/signup_controller.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:JIR/pages/auth/service/google_api_auth.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => GoogleAuthService());
    Get.lazyPut(() => SignupController());
    Get.lazyPut(() => LoginController());
  }
}

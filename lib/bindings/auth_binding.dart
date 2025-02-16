import 'package:get/get.dart';
import 'package:smartcitys/app/controllers/auth_controller/login_controller.dart';
import 'package:smartcitys/app/controllers/auth_controller/signup_controller.dart';
import 'package:smartcitys/services/auth_service/auth_api_service.dart';
import 'package:smartcitys/services/auth_service/google_api_auth.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => GoogleAuthService());
    Get.lazyPut(() => SignupController());
    Get.lazyPut(() => LoginController());
  }
}
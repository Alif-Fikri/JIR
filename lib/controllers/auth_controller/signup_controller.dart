import 'package:get/get.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/services/auth_service/auth_api_service.dart';

class SignupController extends GetxController {
  final AuthService _authService = Get.find();
  
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxBool isTermsAccepted = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void validateAndRegister() async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    if (password.value != confirmPassword.value) {
      errorMessage.value = 'Passwords do not match';
      return;
    }

    if (!isTermsAccepted.value) {
      errorMessage.value = 'Please accept the terms and conditions';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final response = await _authService.signup(
      username.value,
      email.value,
      password.value,
    );

    if (response['success']) {
      Get.offAll(() => const Menu());
    } else {
      errorMessage.value = response['message'];
    }
    
    isLoading.value = false;
  }

  void navigateToLogin() {
    Get.offAll(() => const Menu());
  }
}
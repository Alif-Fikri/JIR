import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:JIR/helper/menu.dart';
import 'package:JIR/pages/auth/view/login.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';

class SignupController extends GetxController {
  final AuthService _authService = Get.find();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isTermsAccepted = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void validateAndRegister() async {
    final username = usernameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    if (password != confirmPassword) {
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
      username,
      email,
      password,
    );

    if (response['success']) {
      Get.offAll(() => const Menu());
    } else {
      errorMessage.value = response['message'];
    }

    isLoading.value = false;
  }

  void navigateToLogin() {
    Get.off(() => LoginPage()); // Ini seharusnya navigate ke LoginPage
    // Seharusnya:
    // Get.offAll(() => LoginPage());
    // atau
    // Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

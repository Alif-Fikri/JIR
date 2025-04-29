import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/helper/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+com$');
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).+$');

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Mohon isi semua kolom yang tersedia';
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      errorMessage.value = 'Email harus valid dan berakhiran .com';
      return;
    }

    if (!passwordRegex.hasMatch(password)) {
      errorMessage.value =
          'Kata sandi harus memiliki minimal 1 huruf kapital dan 1 angka';
      return;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'Kata sandi tidak cocok';
      return;
    }

    if (!isTermsAccepted.value) {
      errorMessage.value = 'Harap setujui syarat dan ketentuan';
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
      CustomSnackbar.show(
        context: Get.context!,
        message: "Pendaftaran berhasil! Silakan login.",
        imageAssetPath: 'assets/images/jir_logo3.png',
      );
      Get.offNamed(AppRoutes.login);
    } else {
      CustomSnackbar.show(
        context: Get.context!,
        message: response['message'] ?? "Terjadi kesalahan, silakan coba lagi.",
        imageAssetPath: 'assets/images/jir_logo3.png',
      );
      errorMessage.value =
          response['message'] ?? "Terjadi kesalahan, silakan coba lagi.";
    }

    isLoading.value = false;
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

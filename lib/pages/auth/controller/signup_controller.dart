import 'dart:developer' as developer;
import 'package:JIR/app/routes/app_routes.dart';
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

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[a-zA-Z]{2,}$');
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).+$');

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Mohon isi semua kolom yang tersedia';
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      errorMessage.value = 'Email tidak valid';
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

    try {
      final response = await _authService.signup(
        username,
        email,
        password,
      );

      if (response['success'] == true) {
        Get.offNamed(AppRoutes.login);
      } else {
        errorMessage.value = response['message'] ?? 'Pendaftaran gagal.';
      }
    } catch (e, st) {
      developer.log('Signup error',
          error: e, stackTrace: st, name: 'SignupController');
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
    } finally {
      isLoading.value = false;
    }
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

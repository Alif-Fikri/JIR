import 'package:JIR/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:JIR/pages/auth/service/google_api_auth.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find();
  final GoogleAuthService _googleAuthService = Get.find();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void login() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result['success'] == true) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value =
            result['message'] ?? 'Login gagal. Silakan coba lagi.';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
    } finally {
      isLoading.value = false;
    }
  }

  void googleSignIn() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _googleAuthService.signInWithGoogle();

      if (result.success) {
        final data = result.data ?? {};
        final dynamic successFlag = data['success'];
        final bool backendSuccess = successFlag == null || successFlag == true;

        if (backendSuccess) {
          Get.offAllNamed(AppRoutes.home);
          return;
        }

        final backendMessage = data['message']?.toString();
        errorMessage.value = backendMessage?.isNotEmpty == true
            ? backendMessage!
            : 'Login dengan Google gagal.';
        return;
      }

      if (result.cancelled) {
        errorMessage.value = 'Login Google dibatalkan.';
        return;
      }

      errorMessage.value =
          result.message ?? 'Terjadi kesalahan saat login dengan Google.';
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat login dengan Google.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

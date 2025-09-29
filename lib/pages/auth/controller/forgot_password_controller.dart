import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends GetxController {
  final emailCtrl = TextEditingController();
  final isLoading = false.obs;
  final message = ''.obs;

  final AuthService _authService = AuthService();

  Future<void> submit() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      message.value = 'Email tidak boleh kosong';
      Get.snackbar('Error', message.value, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      isLoading.value = true;
      final res = await _authService.forgotPassword(email);
      if (res['success'] == true) {
        Get.snackbar('Sukses', res['message'],
            snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(seconds: 1));
        Get.back();
      } else {
        Get.snackbar('Gagal', res['message'] ?? 'Failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}

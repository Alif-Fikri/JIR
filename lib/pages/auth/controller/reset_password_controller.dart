import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ResetPasswordController extends GetxController {
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final isLoading = false.obs;
  final message = ''.obs;

  final AuthService _authService = AuthService();

  Future<void> submit(String oobCode) async {
    final newPassword = newPasswordCtrl.text.trim();
    final confirmPassword = confirmPasswordCtrl.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Password tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPassword.length < 8) {
      Get.snackbar('Error', 'Password minimal 8 karakter',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar('Error', 'Password tidak cocok',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      final res = await _authService.resetPassword(oobCode, newPassword);
      if (res['success'] == true) {
        Get.snackbar('Sukses', res['message'],
            snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(milliseconds: 800));

        Get.offAllNamed('/login');
      } else {
        Get.snackbar('Gagal', res['message'] ?? 'Reset gagal',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}

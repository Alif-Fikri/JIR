import 'dart:developer' as developer;
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ResetPasswordController extends GetxController {
  final emailCtrl = TextEditingController();
  final tokenCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final isLoading = false.obs;
  final message = ''.obs;

  final AuthService _authService = AuthService();

  void setInitialEmail(String? email) {
    if (email != null && email.isNotEmpty && emailCtrl.text.isEmpty) {
      emailCtrl.text = email;
    }
  }

  void setInitialToken(String? token) {
    if (token != null && token.isNotEmpty && tokenCtrl.text.isEmpty) {
      tokenCtrl.text = token;
    }
  }

  Future<void> submit() async {
    final email = emailCtrl.text.trim();
    final token = tokenCtrl.text.trim();
    final newPassword = newPasswordCtrl.text.trim();
    final confirmPassword = confirmPasswordCtrl.text.trim();
    if (email.isEmpty) {
      message.value = 'Email tidak boleh kosong';
      return;
    }
    if (token.isEmpty) {
      message.value = 'Token tidak boleh kosong';
      return;
    }
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      message.value = 'Password tidak boleh kosong';
      return;
    }
    if (newPassword.length < 8) {
      message.value = 'Password minimal 8 karakter';
      return;
    }
    if (newPassword != confirmPassword) {
      message.value = 'Password tidak cocok';
      return;
    }

    try {
      isLoading.value = true;
      message.value = '';

      final res = await _authService.resetPassword(email, token, newPassword);
      if (res['success'] == true) {
        Get.snackbar('Sukses', res['message'] ?? 'Password berhasil diubah',
            snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed(AppRoutes.home);
      } else {
        message.value = res['message'] ?? 'Gagal mereset password.';
      }
    } catch (e, st) {
      developer.log('resetPassword error',
          error: e, stackTrace: st, name: 'ResetPasswordController');
      message.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    tokenCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}

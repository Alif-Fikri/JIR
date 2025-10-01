import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:JIR/app/routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final emailCtrl = TextEditingController();
  final isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSuccess = false.obs;

  final AuthService _authService = AuthService();

  Future<void> submit() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      errorMessage.value = 'Email tidak boleh kosong';
      isSuccess.value = false;
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;

      final res = await _authService.forgotPassword(email);

      if (res['success'] == true) {
        isSuccess.value = true;
        final msg = res['message'] ??
            'Token reset telah dikirim ke email jika terdaftar.';
        errorMessage.value = msg;
        final token = (res['reset_token'] is String)
            ? res['reset_token'] as String
            : null;
        Get.toNamed(
          AppRoutes.resetPassword,
          arguments: {
            'email': email,
            if (token != null) 'token': token,
          },
        );
      } else {
        isSuccess.value = false;
        errorMessage.value = res['message'] ?? 'Gagal mengirim link reset';
      }
    } catch (e, st) {
      developer.log('forgotPassword error',
          error: e, stackTrace: st, name: 'ForgotPasswordController');
      isSuccess.value = false;
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
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

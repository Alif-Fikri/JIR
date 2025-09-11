import 'package:JIR/helper/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';

class ChangePasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  var isObscuredNew = true.obs;
  var isObscuredConfirm = true.obs;
  var isLoading = false.obs;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != newPasswordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> changePassword() async {
    if (isLoading.value) return;
    final newPwdError = validatePassword(newPasswordController.text);
    final confirmPwdError =
        validateConfirmPassword(confirmPasswordController.text);

    if (newPwdError != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: newPwdError,
        useAppIcon: true,
      );
      return;
    }
    if (confirmPwdError != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: confirmPwdError,
        useAppIcon: true,
      );
      return;
    }

    isLoading(true);
    try {
      final response = await _authService.changePassword(
        newPasswordController.text,
        confirmPasswordController.text,
      );

      if (response['success']) {
        Get.back();
        CustomSnackbar.show(
          context: Get.context!,
          message: "Password berhasil diubah",
          useAppIcon: true,
        );
      } else {
        CustomSnackbar.show(
          context: Get.context!,
          message: response['message'] ?? "Gagal mengubah password",
          useAppIcon: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        context: Get.context!,
        message: "Terjadi kesalahan. Silakan coba lagi.",
        useAppIcon: true,
      );
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

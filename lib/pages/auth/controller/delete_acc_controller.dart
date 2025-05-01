import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:JIR/helper/custom_snackbar.dart';

class DeleteAccountController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;
  final RxString password = ''.obs;

  Future<void> deleteAccount(String password) async {
    isLoading(true);
    try {
      final response = await _authService.deleteAccount(password);

      if (response['success']) {
        Get.offAllNamed('/login');
        CustomSnackbar.show(
          context: Get.context!,
          message: "Akun berhasil dihapus",
          imageAssetPath: 'assets/images/jir_logo3.png',
        );
      } else {
        CustomSnackbar.show(
          context: Get.context!,
          message: response['message'] ?? "Gagal menghapus akun",
          imageAssetPath: 'assets/images/jir_logo3.png',
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        context: Get.context!,
        message: "Terjadi kesalahan saat menghapus akun",
        imageAssetPath: 'assets/images/jir_logo3.png',
      );
    } finally {
      isLoading(false);
    }
  }
}

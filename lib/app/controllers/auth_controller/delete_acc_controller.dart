import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartcitys/services/auth_service/auth_api_service.dart';

class DeleteAccountController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;
  final RxString password = ''.obs;

  Future<void> deleteAccount(String password) async {
    try {
      isLoading(true);
      final response = await _authService.deleteAccount(password);
      
      if (response['success']) {
        Get.offAllNamed('/login');
        Get.snackbar(
          'Success',
          'Account deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading(false);
    }
  }
}
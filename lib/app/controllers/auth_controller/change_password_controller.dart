import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartcitys/services/auth_service/auth_api_service.dart';

class ChangePasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Observables
  var isObscuredNew = true.obs;
  var isObscuredConfirm = true.obs;
  var isLoading = false.obs;

  // Validations
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> changePassword() async {
    if (isLoading.value) return;

    final newPasswordError = validatePassword(newPasswordController.text);
    final confirmPasswordError =
        validateConfirmPassword(confirmPasswordController.text);

    if (newPasswordError != null || confirmPasswordError != null) {
      Get.snackbar(
        'Error',
        'Please fix the errors in the form',
        snackPosition: SnackPosition.BOTTOM,
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
        Get.snackbar(
          'Success',
          'Password changed successfully',
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred. Please try again',
        snackPosition: SnackPosition.BOTTOM,
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

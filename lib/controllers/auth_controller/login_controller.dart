import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/services/auth_service/auth_api_service.dart';
import 'package:smartcitys/services/auth_service/google_api_auth.dart';

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
    
    final result = await _authService.login(
      emailController.text,
      passwordController.text,
    );

    if (result['success']) {
      Get.offAll(() => Menu());
    } else {
      errorMessage.value = result['message'];
    }
    
    isLoading.value = false;
  }

  void googleSignIn() async {
    final result = await _googleAuthService.signInWithGoogle();
    if (result != null) {
      Get.offAll(() => Menu());
    } else {
      errorMessage.value = 'Google sign in failed';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
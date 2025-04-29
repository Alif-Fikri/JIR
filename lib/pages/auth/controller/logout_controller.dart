import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class LogoutController extends GetxController {
  final AuthService _authService = AuthService();
  var isLoading = false.obs;

 Future<void> logout() async {
  isLoading.value = true;

  final response = await _authService.logout();

  if (response['success']) {
    Fluttertoast.showToast(
      msg: "Logout successful!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    Get.reset();
    Get.offAllNamed(AppRoutes.login); 
  } else {
    Fluttertoast.showToast(
      msg: response['message'],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  isLoading.value = false;
 }
}

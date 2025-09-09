import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/helper/custom_snackbar.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:get/get.dart';

class LogoutController extends GetxController {
  final AuthService _authService = AuthService();
  var isLoading = false.obs;

  Future<void> logout() async {
    isLoading.value = true;

    final response = await _authService.logout();

    if (response['success']) {
      CustomSnackbar.show(
        context: Get.context!,
        message: "Anda berhasil logout",
        imageAssetPath: 'assets/images/jir_logo3.png',
      );
      Get.offAllNamed(AppRoutes.login);
    } else {
      CustomSnackbar.show(
        context: Get.context!,
        message: "Logout anda gagal, coba lagi nanti!.",
        imageAssetPath: 'assets/images/jir_logo3.png',
      );
    }

    isLoading.value = false;
  }
}

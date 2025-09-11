import 'package:get/get.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:JIR/helper/custom_snackbar.dart';

class DeleteAccountController extends GetxController {
  late final AuthService _authService;
  final RxBool isLoading = false.obs;
  final RxString password = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthService>()) {
      _authService = Get.find<AuthService>();
    } else {
      _authService = AuthService();
    }
  }

  Future<void> deleteAccount(String password) async {
    isLoading(true);
    try {
      final response = await _authService.deleteAccount(password);

      if (response['success']) {
        Get.offAllNamed('/login');
        CustomSnackbar.show(
          context: Get.context!,
          message: "Akun berhasil dihapus",
          useAppIcon: true,
        );
      } else {
        CustomSnackbar.show(
          context: Get.context!,
          message: response['message'] ?? "Gagal menghapus akun",
          useAppIcon: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        context: Get.context!,
        message: "Terjadi kesalahan saat menghapus akun",
        useAppIcon: true,
      );
    } finally {
      isLoading(false);
    }
  }
}

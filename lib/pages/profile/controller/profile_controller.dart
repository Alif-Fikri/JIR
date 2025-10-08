import 'package:get/get.dart';
import 'package:JIR/pages/auth/service/auth_api_service.dart';

class ProfileController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  var name = ''.obs;
  var email = ''.obs;
  var isLoading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading(true);
      final data = await _auth.fetchProfile();
      final rawName =
          (data['username'] ?? data['name'] ?? '').toString().trim();
      final rawEmail = (data['email'] ?? '').toString().trim();

      if (rawEmail.isNotEmpty && rawName.isEmpty) {
        name.value = rawEmail.split('@').first;
      } else if (rawName.isNotEmpty) {
        name.value = rawName;
      } else {
        name.value = 'Pengguna';
      }

      email.value = rawEmail;
      error.value = '';
    } catch (e) {
      error.value = 'Gagal memuat profil. Silakan coba lagi.';
      if (Get.isLogEnable) {
        Get.log('ProfileController loadProfile error: $e');
      }
      name.value = 'Pengguna';
      email.value = '';
    } finally {
      isLoading(false);
    }
  }
}

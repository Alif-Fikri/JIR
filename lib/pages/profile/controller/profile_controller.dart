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
      name.value = data['username'] ?? data['name'] ?? '';
      email.value = data['email'] ?? '';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading(false);
    }
  }
}

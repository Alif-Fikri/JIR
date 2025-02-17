import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/pages/home/report/report_loading.dart';

class ReportController extends GetxController {
  final imageFile = Rxn<File>();
  final description = ''.obs;
  final _picker = ImagePicker();

  final reports = <Map<String, dynamic>>[].obs;

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: ${e.toString()}');
    }
  }

  void submitReport() {
    if (imageFile.value == null || description.isEmpty) {
      Get.snackbar('Error', 'Harap lengkapi semua field');
      return;
    }

    Get.to(() => const ReportLoadingPage());

    Future.delayed(const Duration(seconds: 5), () {
      reports.add({
        'imagePath': imageFile.value!.path,
        'description': description.value,
        'status': 'Menunggu'
      });
      imageFile.value = null;
      description.value = '';
      Get.snackbar('Sukses', 'Laporan berhasil dikirim');
      Get.off(() => Menu(), arguments: 1);
    });
  }

  @override
  void onInit() {
    super.onInit();
    print("ReportController initialized");
  }
}

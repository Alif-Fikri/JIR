import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:JIR/helper/menu.dart';
import 'package:JIR/pages/home/report/widget/report_loading.dart';

class ReportController extends GetxController {
  final imageFile = Rxn<File>();
  final description = ''.obs;
  final reportType = 'Banjir'.obs;
  final severity = 'Rendah'.obs;
  final address = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final contactName = ''.obs;
  final contactPhone = ''.obs;
  final dateTime = DateTime.now().obs;
  final isAnonymous = false.obs;

  final _picker = ImagePicker();
  final reports = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReportsFromHive();
  }

  Future<void> loadReportsFromHive() async {
    if (!Hive.isBoxOpen('reports')) {
      await Hive.openBox('reports');
    }
    final box = Hive.box('reports');
    final List stored = box.get('list', defaultValue: []);
    reports.assignAll(List<Map<String, dynamic>>.from(stored));
  }

  Future<void> saveReportsToHive() async {
    if (!Hive.isBoxOpen('reports')) {
      await Hive.openBox('reports');
    }
    final box = Hive.box('reports');
    await box.put('list', List<Map<String, dynamic>>.from(reports));
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<void> fillLocationFromGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Lokasi', 'Layanan lokasi tidak aktif');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Lokasi', 'Permission lokasi ditolak');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Lokasi', 'Permission lokasi permanen ditolak');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude.value = pos.latitude;
      longitude.value = pos.longitude;
      address.value =
          '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      Get.snackbar('Lokasi', 'Lokasi berhasil diambil');
    } catch (e) {
      Get.snackbar('Lokasi', 'Gagal mengambil lokasi: ${e.toString()}');
    }
  }

  void setDateTime(DateTime dt) {
    dateTime.value = dt;
  }

  void submitReport() async {
    if (!isAnonymous.value) {
      if (contactName.value.trim().isEmpty ||
          contactPhone.value.trim().isEmpty) {
        Get.snackbar('Error', 'Isi nama & nomor telepon atau centang anonim');
        return;
      }
    }

    if (imageFile.value == null) {
      Get.snackbar('Error', 'Masukkan foto bukti');
      return;
    }

    Get.to(() => const ReportLoadingPage());

    final now = DateTime.now();
    final report = {
      'id': now.millisecondsSinceEpoch,
      'type': reportType.value,
      'severity': severity.value,
      'address': address.value,
      'latitude': latitude.value,
      'longitude': longitude.value,
      'description': description.value,
      'imagePath': imageFile.value!.path,
      'contactName': isAnonymous.value ? 'Anonim' : contactName.value,
      'contactPhone': isAnonymous.value ? '' : contactPhone.value,
      'dateTime': dateTime.value.toIso8601String(),
      'isAnonymous': isAnonymous.value,
      'status': 'Menunggu'
    };

    await Future.delayed(const Duration(seconds: 3));
    reports.insert(0, Map<String, dynamic>.from(report));
    await saveReportsToHive();

    imageFile.value = null;
    description.value = '';
    contactName.value = '';
    contactPhone.value = '';
    isAnonymous.value = false;

    Get.snackbar('Sukses', 'Laporan berhasil dikirim');
    Get.off(() => const Menu(), arguments: 1);
  }
}

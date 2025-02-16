import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smartcitys/app/routes/app_routes.dart';

class ReportController extends GetxController {
  final imageFile = Rxn<File>();
  final description = ''.obs;
  final _picker = ImagePicker();

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
    
    Get.snackbar('Sukses', 'Laporan berhasil dikirim');
    Get.offAllNamed(AppRoutes.home);
  }
}

class ReportPage extends StatelessWidget {
  final ReportController controller = Get.put(ReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Lapor',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xff45557B),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildImagePickerButton(),
          const SizedBox(height: 20),
          Text(
            'Tap ikon di atas untuk memilih gambar',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return InkWell(
      onTap: _showImageSourceDialog,
      child: Image.asset(
        'assets/images/report.png',
        height: 60,
        width: 60,
      ),
    );
  }

  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Pilih Sumber Gambar',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Galeri', style: GoogleFonts.inter()),
              onTap: () => _handleImageSelection(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Kamera', style: GoogleFonts.inter()),
              onTap: () => _handleImageSelection(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageSelection(ImageSource source) {
    Get.back();
    controller.pickImage(source).then((_) {
      if (controller.imageFile.value != null) {
        Get.to(() => ReportFormPage());
      }
    });
  }
}

class ReportFormPage extends StatelessWidget {
  final ReportController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildFormContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Laporan Baru',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xff45557B),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 20),
          _buildDescriptionField(),
          const SizedBox(height: 30),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Obx(() => controller.imageFile.value != null
        ? Column(
            children: [
              Image.file(
                controller.imageFile.value!,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
            ],
          )
        : const SizedBox.shrink());
  }

  Widget _buildDescriptionField() {
    return TextField(
      onChanged: (value) => controller.description.value = value,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: "Tambahkan deskripsi...",
        border: const OutlineInputBorder(),
        hintStyle: GoogleFonts.inter(color: Colors.grey),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: controller.submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff45557B),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Kirim Laporan',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
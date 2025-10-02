import 'package:JIR/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';

class ReportPage extends StatelessWidget {
  final ReportController controller = Get.find<ReportController>();
  ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Lapor',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xff45557B),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: _showImageSourceDialog,
      backgroundColor: const Color(0xff45557B),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
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
        Get.toNamed(AppRoutes.reportForm);
      }
    });
  }
}

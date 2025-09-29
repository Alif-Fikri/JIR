import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/auth/controller/reset_password_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  final String oobCode;

  ResetPasswordPage({super.key, required this.oobCode});

  final ResetPasswordController controller = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    final fixedWidth = 350.0;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: Colors.black)),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: fixedWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buat Password Baru',
                    style: GoogleFonts.inter(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Masukkan password baru untuk akunmu.',
                    style: GoogleFonts.inter()),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.newPasswordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password baru', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.confirmPasswordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Konfirmasi password',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.submit(oobCode),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF45557B)),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text('Reset Password',
                                style: GoogleFonts.inter()),
                      ),
                    )),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

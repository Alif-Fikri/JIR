import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/auth/controller/forgot_password_controller.dart';
import 'package:JIR/pages/auth/widget/helper_auth.dart'; // buildErrorMessage

class ForgotPasswordPage extends StatelessWidget {
  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());
  final borderRadius = BorderRadius.circular(12);
  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fixedWidth = 350.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: fixedWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reset Password',
                    style: GoogleFonts.inter(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                    'Masukkan email yang terdaftar, kami akan mengirim token untuk reset.',
                    style: GoogleFonts.inter()),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: borderRadius),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: borderRadius,
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: borderRadius,
                      borderSide:
                          const BorderSide(color: Color(0xFF45557B), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
                Obx(() => controller.errorMessage.value.isNotEmpty
                    ? buildErrorMessage(controller.errorMessage.value)
                    : const SizedBox.shrink()),
                const SizedBox(height: 10),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF45557B),
                          shape: RoundedRectangleBorder(
                              borderRadius: borderRadius),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Kirim',
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    )),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/auth/controller/reset_password_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  final String? initialEmail;
  final String? initialToken;

  ResetPasswordPage({super.key, this.initialEmail, this.initialToken});

  final ResetPasswordController controller = Get.put(ResetPasswordController());
  final borderRadius = BorderRadius.circular(12);
  @override
  Widget build(BuildContext context) {
    final fixedWidth = 350.0;
    controller.setInitialEmail(initialEmail);
    controller.setInitialToken(initialToken);
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
                Text(
                    'Masukkan token yang dikirim ke email dan password baru untuk akunmu.',
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
                const SizedBox(height: 12),
                TextField(
                  controller: controller.tokenCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Token',
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
                const SizedBox(height: 12),
                TextField(
                  controller: controller.newPasswordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password baru',
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
                const SizedBox(height: 12),
                TextField(
                  controller: controller.confirmPasswordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi password',
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
                const SizedBox(height: 16),
                Obx(() {
                  final msg = controller.message.value;
                  if (msg.isEmpty) return const SizedBox.shrink();
                  final lower = msg.toLowerCase();
                  final isSuccess = lower.contains('berhasil') ||
                      lower.contains('sukses') ||
                      lower.contains('password has been') ||
                      lower.contains('password has been reset');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      msg,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isSuccess ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
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
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text('Reset Password',
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
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

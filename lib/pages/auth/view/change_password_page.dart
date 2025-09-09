import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/auth/controller/change_password_controller.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final ChangePasswordController controller =
      Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.4,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ubah Kata Sandi',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() => TextField(
                        controller: controller.newPasswordController,
                        obscureText: controller.isObscuredNew.value,
                        onChanged: (_) => controller.update(),
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Baru',
                          errorText:
                              controller.newPasswordController.text.isEmpty
                                  ? null
                                  : controller.validatePassword(
                                      controller.newPasswordController.text),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isObscuredNew.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black26,
                            ),
                            onPressed: () => controller.isObscuredNew.toggle(),
                          ),
                          filled: true,
                          fillColor: const Color(0xffF6F6F6),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xffD8D8D8)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xff45557B), width: 2.0),
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  Obx(() => TextField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.isObscuredConfirm.value,
                        onChanged: (_) => controller.update(),
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi Baru',
                          errorText: controller
                                  .confirmPasswordController.text.isEmpty
                              ? null
                              : controller.validateConfirmPassword(
                                  controller.confirmPasswordController.text),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isObscuredConfirm.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black26,
                            ),
                            onPressed: () =>
                                controller.isObscuredConfirm.toggle(),
                          ),
                          filled: true,
                          fillColor: const Color(0xffF6F6F6),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xffD8D8D8)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xff45557B), width: 2.0),
                          ),
                        ),
                      )),
                  const SizedBox(height: 30),
                  Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff45557B),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.changePassword,
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Perbarui Kata Sandi'),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

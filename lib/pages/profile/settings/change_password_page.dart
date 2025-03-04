import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/app/controllers/auth_controller/change_password_controller.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final ChangePasswordController controller = Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          children: [
            Obx(() => TextField(
              controller: controller.newPasswordController,
              obscureText: controller.isObscuredNew.value, 
              decoration: InputDecoration(
                labelText: 'New Password',
                errorText: controller.validatePassword(
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
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffD8D8D8))),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xff45557B), width: 3.0),
                ),
              ),
            )),
            const SizedBox(height: 20), 
            Obx(() => TextField(
              controller: controller.confirmPasswordController,
              obscureText: controller.isObscuredConfirm.value, 
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                errorText: controller.validateConfirmPassword(
                    controller.confirmPasswordController.text),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isObscuredConfirm.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.black26,
                  ),
                  onPressed: () => controller.isObscuredConfirm.toggle(),
                ),
                filled: true,
                fillColor: const Color(0xffF6F6F6),
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffD8D8D8))),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xff45557B), width: 3.0),
                ),
              ),
            )),
            const Spacer(),
            Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff45557B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 15, horizontal: 24),
                textStyle: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w400),
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.changePassword,
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : const Text('Update Password'),
            )),
          ],
        ),
      ),
    );
  }
}
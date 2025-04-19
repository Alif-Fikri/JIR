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
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change Password',
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
                              onPressed: () =>
                                  controller.isObscuredNew.toggle(),
                            ),
                            filled: true,
                            fillColor: const Color(0xffF6F6F6),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffD8D8D8))),
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
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffD8D8D8))),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff45557B), width: 3.0),
                            ),
                          ),
                        )),
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

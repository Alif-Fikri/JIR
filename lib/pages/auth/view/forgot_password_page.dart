import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/auth/controller/forgot_password_controller.dart';
import 'package:JIR/pages/auth/widget/helper_auth.dart'; 

class ForgotPasswordPage extends StatelessWidget {
  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());
  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fixedWidth = 350.w;
    final borderRadius = BorderRadius.circular(12.r);
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
                        fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                Text(
                    'Masukkan email yang terdaftar, kami akan mengirim token untuk reset.',
                    style: GoogleFonts.inter(fontSize: 14.sp)),
                SizedBox(height: 16.h),
                TextField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.inter(fontSize: 14.sp),
                    border: OutlineInputBorder(borderRadius: borderRadius),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: borderRadius,
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: borderRadius,
                      borderSide: BorderSide(
                          color: const Color(0xFF45557B), width: 2.w),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  ),
                ),
                Obx(() => controller.errorMessage.value.isNotEmpty
                    ? buildErrorMessage(controller.errorMessage.value)
                    : const SizedBox.shrink()),
                SizedBox(height: 10.h),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 48.h,
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
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.w))
                            : Text('Kirim',
                                style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600)),
                      ),
                    )),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

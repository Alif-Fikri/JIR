import 'package:JIR/pages/auth/widget/helper_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/auth/controller/login_controller.dart';
import 'package:JIR/app/routes/app_routes.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Get.toNamed(AppRoutes.home),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ic_launcher.png',
                width: 100.w,
                height: 100.h,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: fixedWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selamat Datang Kembali di JIR',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              buildTextField(
                controller: controller.emailController,
                label: 'Email',
                icon: 'assets/images/person.png',
              ),
              SizedBox(height: 25.h),
              buildTextField(
                controller: controller.passwordController,
                label: 'Kata Sandi',
                icon: 'assets/images/password.png',
                isObscure: true,
              ),
              Obx(() => controller.errorMessage.isNotEmpty
                  ? buildErrorMessage(controller.errorMessage.value)
                  : const SizedBox.shrink()),
              SizedBox(height: 25.h),
              SizedBox(
                width: fixedWidth,
                height: fixedHeight,
                child: ElevatedButton(
                  onPressed: controller.login,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    backgroundColor: const Color(0xFF45557B),
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Color(0xffFF4136),
                        )
                      : Text(
                          'Masuk',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                ),
              ),
              SizedBox(
                width: fixedWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.forgotPassword);
                      },
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            color: Color(0xFF005FCB),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.grey],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      "ATAU",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                width: fixedWidth,
                height: fixedHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1.r,
                      blurRadius: 5.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: controller.googleSignIn,
                  icon: Image.asset(
                    'assets/images/logo_google.png',
                    height: 24.h,
                    width: 24.w,
                  ),
                  label: Text(
                    'Masuk dengan Google',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    backgroundColor: const Color(0xFFF6F6F6),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              RichText(
                text: TextSpan(
                  text: "Belum punya akun? ",
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                    ),
                  ),
                  children: [
                    TextSpan(
                      text: 'Daftar',
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: Color(0xFF005FCB),
                          fontSize: 12.sp,
                        ),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.toNamed(
                              AppRoutes.signup,
                            ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

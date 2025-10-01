import 'package:JIR/pages/auth/widget/helper_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/auth/controller/signup_controller.dart';
import 'package:JIR/app/routes/app_routes.dart';

class SignupPage extends GetView<SignupController> {
  final fixedWidth = 350.0;
  final fixedHeight = 50.0;

  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: fixedWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selamat Datang di JIR',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildTextField(
                label: 'Nama Pengguna',
                icon: 'assets/images/person.png',
                controller: controller.usernameController,
              ),
              const SizedBox(height: 25),
              buildTextField(
                label: 'Email',
                icon: 'assets/images/email.png',
                controller: controller.emailController,
              ),
              const SizedBox(height: 25),
              buildTextField(
                label: 'Kata Sandi',
                icon: 'assets/images/password.png',
                isObscure: true,
                controller: controller.passwordController,
              ),
              const SizedBox(height: 25),
              buildTextField(
                label: 'Konfirmasi Kata Sandi',
                icon: 'assets/images/password.png',
                isObscure: true,
                controller: controller.confirmPasswordController,
              ),
              Obx(() => controller.errorMessage.isNotEmpty
                  ? buildErrorMessage(controller.errorMessage.value)
                  : const SizedBox.shrink()),
              const SizedBox(height: 10),
              SizedBox(
                width: fixedWidth,
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => Checkbox(
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                          value: controller.isTermsAccepted.value,
                          onChanged: (value) =>
                              controller.isTermsAccepted.value = value ?? false,
                        )),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            'Saya telah membaca dan menyetujui ',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Get.toNamed(AppRoutes.termsOfService);
                            },
                            child: Text(
                              'Ketentuan Layanan ',
                              style: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF005FCB),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'dan ',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Get.toNamed(AppRoutes.privacyPolicy);
                            },
                            child: Text(
                              'Kebijakan Privasi',
                              style: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF005FCB),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: fixedWidth,
                height: fixedHeight,
                child: ElevatedButton(
                  onPressed: controller.validateAndRegister,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFF45557B),
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Daftar',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'Sudah punya akun? ',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    TextSpan(
                      text: 'Masuk',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          color: Color(0xFF005FCB),
                          fontSize: 12,
                        ),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.toNamed(AppRoutes.login),
                    ),
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

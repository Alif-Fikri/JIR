import 'package:JIR/pages/auth/widget/helper_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/auth/controller/login_controller.dart';
import 'package:JIR/app/routes/app_routes.dart';

class LoginPage extends GetView<LoginController> {
  final fixedWidth = 350.0;
  final fixedHeight = 50.0;

  LoginPage({super.key}) {
    Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 115.0,
                width: fixedWidth,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: fixedWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome Back to JIR',
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
                controller: controller.emailController,
                label: 'Username/Email',
                icon: 'assets/images/person.png',
              ),
              const SizedBox(height: 25),
              buildTextField(
                controller: controller.passwordController,
                label: 'Password',
                icon: 'assets/images/password.png',
                isObscure: true,
              ),
              Obx(() => controller.errorMessage.isNotEmpty
                  ? buildErrorMessage(controller.errorMessage.value)
                  : const SizedBox.shrink()),
              const SizedBox(height: 25),
              SizedBox(
                width: fixedWidth,
                height: fixedHeight,
                child: ElevatedButton(
                  onPressed: controller.login,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFF45557B),
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Color(0xffFF4136),
                        )
                      : Text(
                          'Sign In',
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
              SizedBox(
                width: fixedWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(color: Color(0xFF005FCB)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
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
              const SizedBox(height: 10),
              Container(
                width: fixedWidth,
                height: fixedHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: controller.googleSignIn,
                  icon: Image.asset(
                    'assets/images/logo_google.png',
                    height: 24,
                    width: 24,
                  ),
                  label: Text(
                    'Sign In with Google',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFFF6F6F6),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          color: Color(0xFF005FCB),
                          fontSize: 12,
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

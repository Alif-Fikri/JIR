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
              _buildTextField(
                controller: controller.emailController,
                label: 'Username/Email',
                icon: 'assets/images/person.png',
              ),
              const SizedBox(height: 25),
              _buildTextField(
                controller: controller.passwordController,
                label: 'Password',
                icon: 'assets/images/password.png',
                isObscure: true,
              ),
              Obx(() => controller.errorMessage.isNotEmpty
                  ? _buildErrorMessage(controller.errorMessage.value)
                  : const SizedBox.shrink()),
              const SizedBox(height: 25),
              SizedBox(
                width: fixedWidth,
                height: fixedHeight,
                child: ElevatedButton(
                  onPressed: controller.login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
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
                              fontSize: 16,
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
                      height: 1, // Ketebalan garis
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.grey
                          ], // Gradien ujung yang lancip
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
                      height: 1, // Ketebalan garis
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey,
                            Colors.transparent
                          ], // Gradien ujung yang lancip
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
                      offset: const Offset(0, 5), // Posisi bayangan
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
                    padding: const EdgeInsets.symmetric(vertical: 15),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String icon,
    bool isObscure = false,
  }) {
    return SizedBox(
      width: fixedWidth,
      height: fixedHeight,
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF6F6F6),
          labelText: label,
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
                bottom: 15.0, top: 15.0, left: 30, right: 10),
            child: Image.asset(
              icon,
              width: 16,
              height: 16,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: fixedWidth,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(
              Icons.info,
              color: Colors.red,
              size: 16,
            ),
            Text(
              message,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

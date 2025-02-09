import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/app/routes/app_routes.dart';
import 'package:smartcitys/controllers/auth_controller/signup_controller.dart';

class SignupPage extends GetView<SignupController> {
  final fixedWidth = 350.0;
  final fixedHeight = 50.0;

  SignupPage({super.key}) {
    Get.put(SignupController());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
    canPop: false,
      child: Scaffold(
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
                      'Welcome to JIR',
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
                  label: 'Username',
                  icon: 'assets/images/person.png',
                  controller: controller.usernameController,
                ),
                const SizedBox(height: 25),

                _buildTextField(
                  label: 'Email',
                  icon: 'assets/images/email.png',
                  controller: controller.emailController,
                ),
                const SizedBox(height: 25),

                _buildTextField(
                  label: 'Password',
                  icon: 'assets/images/password.png',
                  isObscure: true,
                  controller: controller.passwordController,
                ),
                const SizedBox(height: 25),

                _buildTextField(
                  label: 'Confirm Password',
                  icon: 'assets/images/password.png',
                  isObscure: true,
                  controller: controller.confirmPasswordController,
                ),
                Obx(() => controller.errorMessage.isNotEmpty
                    ? _buildErrorMessage(controller.errorMessage.value)
                    : const SizedBox.shrink()),
                const SizedBox(height: 10),
                // Terms and Conditions Checkbox
                SizedBox(
                  width: fixedWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Checkbox(
                            activeColor: Colors.white,
                            checkColor: Colors.black,
                            value: controller.isTermsAccepted.value,
                            onChanged: (value) => controller
                                .isTermsAccepted.value = value ?? false,
                          )),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I have read and accept the general ',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            children: [
                              TextSpan(
                                text: 'terms, use, and privacy policy',
                                style: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF005FCB),
                                    fontSize: 12,
                                  ),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Sign Up Button
                SizedBox(
                  width: fixedWidth,
                  height: fixedHeight,
                  child: ElevatedButton(
                    onPressed: controller.validateAndRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF45557B),
                    ),
                    child: Obx(() => controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Sign Up',
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
                RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign In',
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

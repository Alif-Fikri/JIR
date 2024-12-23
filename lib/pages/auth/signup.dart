import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/pages/auth/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isTermsAccepted = false;
  bool isPasswordMismatch = false;
  String errorMessage = '';
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  final fixedWidth = 350.0;
  final fixedHeight = 50.0;

  Future<void> _registerUser() async {
    final url = Uri.parse('http://localhost:8000/auth/signup');
    setState(() {
      errorMessage = '';
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['access_token'];

        // Simpan token ke Hive
        await saveToken(token);

        // Navigasi ke halaman berikutnya
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Menu()),
        );
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ?? 'Registration failed';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to connect to the server. Please try again.';
      });
    }
  }

  Future<void> saveToken(String token) async {
    try {
      var box = await Hive.openBox('authBox'); 
      await box.put('token', token); 
      print('Token saved: $token');
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  void _validateAndRegister() {
    setState(() {
      errorMessage = '';
      isPasswordMismatch = false;

      // Validasi Input
      if (username.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        errorMessage = 'All fields are required.';
        return;
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        errorMessage = 'Invalid email format.';
        return;
      }

      if (password != confirmPassword) {
        errorMessage = 'Password doesn’t match.';
        isPasswordMismatch = true;
        return;
      }

      if (!isTermsAccepted) {
        errorMessage = 'You must accept the terms and conditions.';
        return;
      }
    });

    // Jika semua validasi berhasil, kirim data ke server
    if (errorMessage.isEmpty) {
      _registerUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
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
                // Username Field
                _buildTextField(
                  label: 'Username',
                  icon: 'assets/images/person.png',
                  onChanged: (value) => setState(() => username = value),
                ),
                const SizedBox(height: 25),
                // Email Field
                _buildTextField(
                  label: 'Email',
                  icon: 'assets/images/email.png',
                  onChanged: (value) => setState(() => email = value),
                ),
                const SizedBox(height: 25),
                // Password Field
                _buildTextField(
                  label: 'Password',
                  icon: 'assets/images/password.png',
                  isObscure: true,
                  onChanged: (value) => setState(() => password = value),
                ),
                const SizedBox(height: 25),
                // Confirm Password Field
                _buildTextField(
                  label: 'Confirm Password',
                  icon: 'assets/images/password.png',
                  isObscure: true,
                  onChanged: (value) => setState(() => confirmPassword = value),
                ),
                if (errorMessage.isNotEmpty)
                  Container(
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
                            errorMessage,
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
                  ),
                const SizedBox(height: 10),
                // Terms and Conditions Checkbox
                SizedBox(
                  width: fixedWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        value: isTermsAccepted,
                        onChanged: (value) =>
                            setState(() => isTermsAccepted = value!),
                      ),
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
                                  ..onTap = () {
                                    // Action to open terms page
                                  },
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
                    onPressed: () {
                      _validateAndRegister();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF45557B),
                    ),
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                          ..onTap = () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
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
    required String label,
    required String icon,
    bool isObscure = false,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: fixedWidth,
      height: fixedHeight,
      child: TextField(
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        obscureText: isObscure,
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
        onChanged: onChanged,
      ),
    );
  }
}

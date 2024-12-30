import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/pages/auth/signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  final fixedWidth = 350.0;
  final fixedHeight = 50.0;

  Future<void> _login() async {
    final url = Uri.parse('http://localhost:8000/auth/login');
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Server response: $responseBody');


        final token = responseBody['access_token'];


        await saveToken(token);


        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Menu()),
        );
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Invalid email or password.';
        });
      } else {
        setState(() {
          errorMessage = 'Server error. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Unable to connect to the server.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _validateAndLogin() {
    setState(() {
      errorMessage = '';

      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        errorMessage = 'Email and Password are required.';
        return;
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
        errorMessage = 'Invalid email format.';
        return;
      }
    });

    if (errorMessage.isEmpty) {
      _login();
    }
  }

  Future<void> saveToken(String token) async {
    print('saveToken called with token: $token');
    try {
      var box = await Hive.openBox('authBox');
      print('Hive box opened successfully');
      await box.put('token', token);
      print('Token saved: $token');
    } catch (e) {
      print('Error saving token: $e');
    }
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
              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Username/Email',
                icon: 'assets/images/person.png',
              ),
              const SizedBox(height: 25),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: 'assets/images/password.png',
                isObscure: true,
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
              const SizedBox(height: 25),

              SizedBox(
                width: fixedWidth,
                height: fixedHeight,
                child: ElevatedButton(
                  onPressed: () {
                    _validateAndLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFF45557B),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
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
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: fixedWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Aksi saat tombol Forgot Password ditekan
                      },
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
                        color: Colors.black, // Warna teks "OR"
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
                width: fixedWidth, // Set lebar tetap untuk tombol Google
                height: fixedHeight,
                decoration: BoxDecoration(
                  color: Colors.white, // Warna latar belakang container
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Warna bayangan
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 5), // Posisi bayangan
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Aksi saat tombol Sign In with Google ditekan
                  },
                  icon: Image.asset(
                    'assets/images/google.png',
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
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
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
}

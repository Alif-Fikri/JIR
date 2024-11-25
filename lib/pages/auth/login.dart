import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/pages/auth/signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordIncorrect = false;
  String errorMessage = '';

  Future<void> _login() async {
    const url = 'http://localhost:8000/auth/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Menu()));
      } else if (response.statusCode == 401) {
        setState(() {
          isPasswordIncorrect = true;
          errorMessage = 'Invalid email or password';
        });
      } else {
        setState(() {
          isPasswordIncorrect = true;
          errorMessage = 'Server Error. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        isPasswordIncorrect = true;
        errorMessage = 'Unable to connect to server.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const fixedWidth = 350.0;
    const fixedHeight = 50.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 115.0,
              width: 347,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: fixedWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selamat Datang Pengguna JIR',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: TextField(
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  labelText: 'Username/Email',
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 15.0, top: 15.0, left: 30, right: 10),
                    child: Image.asset(
                      'assets/images/person.png',
                      width: 15,
                      height: 16,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: TextField(
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  labelText: 'Password',
                  labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 15.0, top: 15.0, left: 30, right: 10),
                    child: Image.asset(
                      'assets/images/password.png',
                      width: 15,
                      height: 16,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            if (isPasswordIncorrect)
              Container(
                width: fixedWidth,
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.info,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
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
            const SizedBox(height: 20),
            SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: ElevatedButton(
                onPressed: () {
                  _login();
                  setState(() {
                    isPasswordIncorrect = true;
                    errorMessage = 'Password Incorrect';
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color(0xFF45557B),
                ),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
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
                        colors: [Colors.grey, Colors.transparent],
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
            const SizedBox(height: 50),
            RichText(
              text: TextSpan(
                text: 'Don’t Have An Account? ',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Signup',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          color: Color(0xFF005FCB),
                          fontSize: 12,
                          fontWeight: FontWeight.w300),
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                SignupPage(), // Halaman Signup
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
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/auth/login.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isPasswordMismatch = false;
  bool isTermsAccepted = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    const fixedWidth = 350.0;
    const fixedHeight = 50.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
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
                Container(
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
                Container(
                  width: fixedWidth, // Set lebar tetap untuk field input
                  height: fixedHeight,
                  child: TextField(
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color:
                          Colors.black, // Warna teks yang diketik oleh pengguna
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF6F6F6),
                      labelText: 'Username',
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
                const SizedBox(height: 25),
                Container(
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
                      labelText: 'Email',
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 15.0, top: 15.0, left: 30, right: 10),
                        child: Image.asset(
                          'assets/images/email.png',
                          width: 16,
                          height: 17,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: fixedWidth,
                  height: fixedHeight,
                  child: TextField(
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color:
                          Colors.black, // Warna teks yang diketik oleh pengguna
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
                const SizedBox(height: 25),
                Container(
                  width: fixedWidth, // Set lebar tetap untuk field input
                  height: fixedHeight,
                  child: TextField(
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color:
                          Colors.black, // Warna teks yang diketik oleh pengguna
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
                    onChanged: (value) {
                      setState(() {
                        isPasswordMismatch = true; // Simulasi password mismatch
                      });
                    },
                  ),
                ),
                if (isPasswordMismatch)
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
                const SizedBox(height: 10),
                Container(
                  width: fixedWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        value: isTermsAccepted,
                        onChanged: (value) {
                          setState(() {
                            isTermsAccepted = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I have read and Accept the general ',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  color: Colors.black, fontSize: 12),
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'terms, use, and privacy policy',
                                style: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                      color: Color(0xFF005FCB), fontSize: 12),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Aksi untuk membuka halaman terms
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
                Container(
                  width: fixedWidth,
                  height: fixedHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Aksi saat tombol Sign In ditekan
                      setState(() {
                        isPasswordMismatch = true; // Contoh menampilkan error
                        errorMessage = 'Password Doesn’t match';
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
                      'Sign Up',
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
                RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: GoogleFonts.inter(
                      textStyle:
                          const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign In',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                              color: Color(0xFF005FCB), fontSize: 12),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    LoginPage(), // Halaman Signup
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
}

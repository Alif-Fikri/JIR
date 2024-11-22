import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/auth/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordIncorrect = false; // Untuk menampilkan pesan error
  String errorMessage = '';

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
              width: fixedWidth, // Lebar tetap untuk keselarasan
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
              width: fixedWidth, // Set lebar tetap untuk field input
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
              width: fixedWidth, // Set lebar tetap untuk field input
              height: fixedHeight,
              child: TextField(
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black, // Warna teks yang diketik oleh pengguna
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
            // Menampilkan pesan error di bagian bawah kanan jika ada error
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
              width: fixedWidth, // Set lebar tetap untuk tombol Sign In
              height: fixedHeight,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi saat tombol Sign In ditekan
                  setState(() {
                    isPasswordIncorrect = true; // Contoh menampilkan error
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
                            builder: (context) => SignupPage(), // Halaman Signup
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

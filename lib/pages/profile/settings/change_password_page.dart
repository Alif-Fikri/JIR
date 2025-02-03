import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isObscured1 = true;
  bool _isObscured2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured1 ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black26,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured1 = !_isObscured1;
                    });
                  },
                ),
                filled: true,
                fillColor: Color(0xffF6F6F6),
                hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                labelStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffD8D8D8))),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff45557B), width: 3.0)),
                border: const OutlineInputBorder(),
              ),
              obscureText: _isObscured1,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured2 ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black26,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured2 = !_isObscured2;
                    });
                  },
                ),
                filled: true,
                fillColor: Color(0xffF6F6F6),
                hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffD8D8D8))),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff45557B), width: 3.0),
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: _isObscured2,
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff45557B),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
                textStyle: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w400),
              ),
              onPressed: () {},
              child: const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}

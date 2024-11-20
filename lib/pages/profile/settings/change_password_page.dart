import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
        backgroundColor: Color(0xff45557B),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: Icon(Icons.visibility_off),
                                hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                labelStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff45557B), width: 2.0)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff45557B), width: 3.0)),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: Icon(Icons.visibility_off),
                hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff45557B), width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff45557B), width: 3.0),
                ),
                border:
                    OutlineInputBorder(), // Tetap gunakan ini untuk memastikan ada border default
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(),
              onPressed: () {},
              child: Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}

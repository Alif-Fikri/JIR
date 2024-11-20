import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfService extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms Of Service'),
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        backgroundColor: Color(0xff45557B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                  'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                  'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                  'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
                  '\n\n'
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                  'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                  'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                  'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
                  '\n\n'
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5, // Jarak antarbaris teks
                    color: Colors.black,
                  ),
                  textAlign:
                      TextAlign.justify, // Mengatur teks agar rata kiri-kanan
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

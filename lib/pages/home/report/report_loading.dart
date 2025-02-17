import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ReportLoadingPage extends StatelessWidget {
  const ReportLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/loading.json',
                width: 200, height: 200, repeat: true),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Terimakasih atas laporan\nAnda, silahkan tunggu\nbeberapa saat',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

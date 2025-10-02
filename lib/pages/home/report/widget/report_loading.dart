import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                width: 200.w, height: 200.w, repeat: true),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                'Terimakasih atas laporan\nAnda, silahkan tunggu\nbeberapa saat',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
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

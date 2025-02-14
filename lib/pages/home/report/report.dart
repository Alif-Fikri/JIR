import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:smartcitys/app/routes/app_routes.dart';
import 'package:smartcitys/helper/menu.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lapor'),
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () => Get.toNamed(AppRoutes.flood),
                child: Image.asset(
                  'assets/images/report.png',
                  height: 60,
                  width: 60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

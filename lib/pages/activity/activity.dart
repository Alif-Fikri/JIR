import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:JIR/pages/home/report/widget/report_card.dart';

class ActivityPage extends StatelessWidget {
  final ReportController controller = Get.find<ReportController>();

  ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Aktivitas',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: const Color(0xff51669D),
            height: 2.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.reports.isEmpty) {
            return Center(
              child: Text(
                'Belum ada laporan',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.reports.length,
            itemBuilder: (context, index) {
              final report = controller.reports[index];
              return ReportCard(
                username: "Lapor saya",
                avatarUrl: "assets/images/default_avatar.png",
                status: report['status'],
                description: report['description'],
                imageUrl: report['imagePath'],
              );
            },
          );
        }),
      ),
    );
  }
}

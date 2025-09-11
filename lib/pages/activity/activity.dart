import 'package:JIR/pages/home/report/widget/report_detail.dart';
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
        title: Text('Aktivitas',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black)),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: const Color(0xff51669D), height: 2.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final reports = controller.reports;
          if (reports.isEmpty) {
            return Center(
                child: Text('Belum ada laporan',
                    style: GoogleFonts.inter(color: Colors.grey)));
          }

          return ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = reports[index];
              final id = report['id']?.toString() ?? index.toString();
              return Dismissible(
                key: ValueKey('report_$id'),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  controller.reports.removeAt(index);
                  await controller.saveReportsToHive();
                  Get.snackbar('Terhapus', 'Laporan dihapus',
                      snackPosition: SnackPosition.BOTTOM);
                },
                child: ReportCard(
                  username: report['contactName'] ?? 'Pengguna',
                  avatarUrl: report['avatar'] ?? '',
                  status: report['status'] ?? 'Menunggu',
                  description: report['description'] ?? '',
                  imageUrl: report['imagePath'] ?? '',
                  dateTimeIso:
                      report['dateTime'] ?? DateTime.now().toIso8601String(),
                  onTap: () => Get.to(() => ReportDetailPage(report: report)),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

import 'dart:io';

import 'package:JIR/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:JIR/pages/home/report/widget/report_card.dart';

class ActivityPage extends StatefulWidget {
  ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final ReportController controller = Get.find<ReportController>();
  late Box box;
  bool _ready = false;
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      _openBox(),
      Future.delayed(const Duration(milliseconds: 700)),
    ]);
    if (!mounted) return;
    _loadFromBox();
    setState(() {
      _showShimmer = false;
      _ready = true;
    });
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen('reports')) {
      await Hive.openBox('reports');
    }
    box = Hive.box('reports');
  }

  void _loadFromBox() {
    final rawList = box.get('list', defaultValue: []);
    final parsed = <Map<String, dynamic>>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map) {
          parsed.add(Map<String, dynamic>.from(item));
        }
      }
    }
    controller.reports.assignAll(parsed);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _showShimmer = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!Hive.isBoxOpen('reports')) {
      await Hive.openBox('reports');
    }
    box = Hive.box('reports');
    if (!mounted) return;
    _loadFromBox();
    setState(() {
      _showShimmer = false;
      _ready = true;
    });
    Get.snackbar('Sukses', 'Daftar laporan diperbarui',
        snackPosition: SnackPosition.BOTTOM);
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.2, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Container(
                    height: 14, width: double.infinity, color: Colors.white),
                const SizedBox(height: 6),
                Container(height: 12, width: 140, color: Colors.white),
              ])),
          const SizedBox(width: 8),
          Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16))),
        ]),
        const SizedBox(height: 12),
        Container(height: 12, width: double.infinity, color: Colors.white),
        const SizedBox(height: 8),
        Container(height: 12, width: double.infinity, color: Colors.white),
        const SizedBox(height: 12),
        ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                height: 180, width: double.infinity, color: Colors.white)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showShimmer) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text('Aktivitas',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(color: const Color(0xff51669D), height: 2.0)),
        ),
        body: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => _buildShimmerItem(),
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Aktivitas',
            style: GoogleFonts.inter(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: const Color(0xff51669D), height: 2.0)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: _onRefresh)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final reports = controller.reports;
          if (reports.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 200),
                  Center(
                      child: Text('Belum ada laporan',
                          style: GoogleFonts.inter(color: Colors.grey)))
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: Color(0xff45557B),
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = Map<String, dynamic>.from(reports[index]);
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
                    onTap: () =>
                        Get.toNamed(AppRoutes.reportdetail, arguments: report),
                    onShowImage: () {
                      final imageUrl = report['imagePath'] ?? '';
                      if (imageUrl.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(16),
                            child: InteractiveViewer(
                              child: imageUrl.startsWith('http')
                                  ? Image.network(imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink())
                                  : Image.file(File(imageUrl),
                                      fit: BoxFit.contain),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

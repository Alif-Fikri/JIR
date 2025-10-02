import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:JIR/pages/home/report/widget/report_card.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

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
      margin: EdgeInsets.symmetric(horizontal: 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(width: 0.2, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6.r,
              offset: Offset(0, 3.h))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          SizedBox(width: 12.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Container(
                    height: 14.h, width: double.infinity, color: Colors.white),
                SizedBox(height: 6.h),
                Container(height: 12.h, width: 140.w, color: Colors.white),
              ])),
          SizedBox(width: 8.w),
          Container(
              width: 60.w,
              height: 24.h,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r))),
        ]),
        SizedBox(height: 12.h),
        Container(height: 12.h, width: double.infinity, color: Colors.white),
        SizedBox(height: 8.h),
        Container(height: 12.h, width: double.infinity, color: Colors.white),
        SizedBox(height: 12.h),
        ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
                height: 180.h, width: double.infinity, color: Colors.white)),
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
                  fontSize: 20.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.h),
              child: Container(color: const Color(0xff51669D), height: 2.h)),
        ),
        body: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
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
                fontSize: 20.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.h),
            child: Container(color: const Color(0xff51669D), height: 2.h)),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh, color: Colors.black87, size: 24.sp),
              onPressed: _onRefresh)
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(() {
          final reports = controller.reports;
          if (reports.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200.h),
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
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final report = Map<String, dynamic>.from(reports[index]);
                final id = report['id']?.toString() ?? index.toString();
                return Dismissible(
                  key: ValueKey('report_$id'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8.r)),
                    child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
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
                      if (imageUrl.isEmpty) return;
                      final isNetworkImage = imageUrl.startsWith('http');
                      final localFile =
                          isNetworkImage ? null : resolveLocalFile(imageUrl);
                      if (!isNetworkImage && localFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Gambar tidak ditemukan atau telah dipindahkan.')),
                        );
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.all(16.w),
                          child: InteractiveViewer(
                            child: isNetworkImage
                                ? Image.network(imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink())
                                : Image.file(localFile!, fit: BoxFit.contain),
                          ),
                        ),
                      );
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

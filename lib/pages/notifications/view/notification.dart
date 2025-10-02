import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
    if (mounted) {
      setState(() {
        _showShimmer = false;
      });
    }
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }
    box = Hive.box('notifications');
    if (mounted) {
      setState(() {
        _ready = true;
      });
    }
  }

  Future<void> _saveList(List list) async {
    await box.put('list', list);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _showShimmer = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }
    box = Hive.box('notifications');
    if (mounted) {
      setState(() {
        _ready = true;
        _showShimmer = false;
      });
      Get.closeAllSnackbars();
      Get.snackbar(
        'Sukses',
        'Daftar notifikasi diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      constraints: BoxConstraints(minHeight: 112.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 18.h,
                          width: double.infinity,
                          color: Colors.white),
                      SizedBox(height: 8.h),
                      Container(
                          height: 14.h,
                          width: double.infinity,
                          color: Colors.white),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(width: 44.w, height: 44.w, color: Colors.white),
              ],
            ),
            SizedBox(height: 8.h),
            Align(
                alignment: Alignment.centerRight,
                child:
                    Container(height: 12.h, width: 120.w, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready && _showShimmer == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final boxRef = Hive.box('notifications');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Notifikasi',
            style: GoogleFonts.inter(
                fontSize: 20.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _onRefresh,
          ),
        ],
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.h),
            child: Container(color: const Color(0xff51669D), height: 2.h)),
      ),
      body: ValueListenableBuilder(
        valueListenable: boxRef.listenable(keys: ['list']),
        builder: (context, _, __) {
          final rawList = List<Map>.from(boxRef.get('list', defaultValue: []));
          if (_showShimmer) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  itemCount: 6,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, __) => _buildShimmerItem(),
                ),
              ),
            );
          }
          if (rawList.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xff45557B),
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200.h),
                  Center(
                      child: Text("Belum ada notifikasi",
                          style: GoogleFonts.inter(fontSize: 14.sp))),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0xff45557B),
            onRefresh: _onRefresh,
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: rawList.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final m = Map<String, dynamic>.from(rawList[index]);
                final notification = NotificationModel.fromMap(m);

                return Dismissible(
                  key: ValueKey(notification.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (dir) async {
                    final id = notification.id;
                    final newList =
                        List<Map>.from(boxRef.get('list', defaultValue: []));
                    final idx = newList.indexWhere(
                        (e) => (e['id']?.toString() ?? '') == id.toString());
                    if (idx == -1) return false;
                    newList.removeAt(idx);
                    await _saveList(newList);
                    Get.closeAllSnackbars();
                    Get.snackbar('Sukses', 'Notifikasi dihapus',
                        snackPosition: SnackPosition.BOTTOM);
                    return true;
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12.r)),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: NotificationItem(notification: notification),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  String _friendlyTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {}
    try {
      final ms = int.parse(raw);
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {}
    return raw;
  }

  String _resolveIconAsset() {
    final provided = (notification.icon).trim();
    if (provided.isNotEmpty) return provided;
    final Map<String, dynamic>? raw = notification.raw;
    final typ = (raw != null && raw['type'] != null)
        ? raw['type'].toString().toLowerCase()
        : '';
    if (typ.contains('flood') ||
        typ.contains('banjir') ||
        typ.contains('peringatan')) {
      return 'assets/images/peringatan.png';
    }
    if (typ.contains('weather') ||
        typ.contains('cuaca') ||
        typ.contains('suhu')) {
      return 'assets/images/suhu.png';
    }
    if (typ.contains('report') || typ.contains('laporan')) {
      return 'assets/images/laporan.png';
    }
    return 'assets/images/ic_launcher.png';
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _friendlyTime(notification.time);
    final iconAsset = _resolveIconAsset();
    final double cardMinHeight = 112.h;
    return Container(
      constraints: BoxConstraints(minHeight: cardMinHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100, width: 0.6.w),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12.r,
              offset: Offset(0, 6.h)),
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4.r,
              offset: Offset(0, 2.h)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        SizedBox(height: 8.h),
                        Text(notification.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400)),
                      ]),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6.r,
                            offset: Offset(0, 3.h))
                      ]),
                  padding: EdgeInsets.all(8.w),
                  child: _buildIconWidget(iconAsset),
                ),
              ]),
              SizedBox(height: 8.h),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(timeStr,
                      style: GoogleFonts.inter(
                          fontSize: 11.sp, color: Colors.grey))),
            ]),
      ),
    );
  }

  Widget _buildIconWidget(String asset) {
    if (asset.startsWith('http')) {
      return Image.network(asset,
          width: 40.w, height: 40.w, fit: BoxFit.contain);
    }
    return Image.asset(asset, width: 40.w, height: 40.w, fit: BoxFit.contain);
  }
}

class NotificationModel {
  final int id;
  final String icon;
  final String title;
  final String message;
  final String time;
  final bool isChecked;
  final Map<String, dynamic>? raw;

  NotificationModel(
      {required this.id,
      required this.icon,
      required this.title,
      required this.message,
      required this.time,
      this.isChecked = false,
      this.raw});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'message': message,
      'time': time,
      'isChecked': isChecked,
      'raw': raw ?? {}
    };
  }

  factory NotificationModel.fromMap(Map m) {
    final idVal = m['id'];
    final idComputed = idVal is int
        ? idVal
        : (int.tryParse(idVal.toString()) ??
            DateTime.now().millisecondsSinceEpoch);
    final timeVal = (m['time'] as String?) ?? '';
    return NotificationModel(
        id: idComputed,
        icon: (m['icon'] as String?) ?? '',
        title: (m['title'] as String?) ?? '',
        message: (m['message'] as String?) ?? '',
        time: timeVal,
        isChecked: m['isChecked'] == true,
        raw: m['raw'] is Map ? Map<String, dynamic>.from(m['raw']) : null);
  }
}

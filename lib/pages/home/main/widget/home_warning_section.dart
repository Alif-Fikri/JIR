import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/pages/home/main/widget/home_shimmer.dart';
import 'package:JIR/pages/notifications/controller/notification_controller.dart';

class HomeWarningSection extends StatelessWidget {
  const HomeWarningSection({
    super.key,
    required this.homeController,
    required this.notificationController,
  });

  final HomeController homeController;
  final NotificationController notificationController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        if (homeController.isLoading.value) {
          return const _WarningShimmer();
        }

        final warnings = notificationController.warnings;
        if (warnings.isEmpty) {
          return const SizedBox.shrink();
        }

        final toShow = warnings.take(2).toList();
        return Column(
          children: [
            Text(
              'WARNING',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            ...toShow.map(
              (item) => _WarningBox(
                title: (item['title'] ?? item['message'] ?? '').toString(),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _WarningShimmer extends StatelessWidget {
  const _WarningShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeShimmer.rect(
          height: 28.h,
          width: 120.w,
          radius: BorderRadius.circular(6.r),
        ),
        SizedBox(height: 16.h),
        HomeShimmer.rect(
          height: 64.h,
          width: double.infinity,
          radius: BorderRadius.circular(8.r),
        ),
        SizedBox(height: 8.h),
        HomeShimmer.rect(
          height: 64.h,
          width: double.infinity,
          radius: BorderRadius.circular(8.r),
        ),
      ],
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD205),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, color: Colors.red, size: 20.r),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

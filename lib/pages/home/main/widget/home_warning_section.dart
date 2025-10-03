import 'dart:math' as math;
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
          ShakingIcon(icon: Icons.warning, color: Colors.red, size: 20.r),
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
          SizedBox(width: 8.w),
          ShakingIcon(icon: Icons.warning, color: Colors.red, size: 20.r),
        ],
      ),
    );
  }
}

class ShakingIcon extends StatefulWidget {
  const ShakingIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    this.duration = const Duration(milliseconds: 3000),
    this.amplitudeX = 3.0,
    this.amplitudeY = 1.5,
    this.rotationDegrees = 4.0,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Duration duration;
  final double amplitudeX;
  final double amplitudeY;
  final double rotationDegrees;

  @override
  State<ShakingIcon> createState() => _ShakingIconState();
}

class _ShakingIconState extends State<ShakingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value * 2 * math.pi;
        final dx = math.sin(t * 3) * widget.amplitudeX;
        final dy = math.cos(t * 2.2) * widget.amplitudeY;
        final angle =
            math.sin(t * 3.6) * (widget.rotationDegrees * math.pi / 180);
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: angle,
            child: child,
          ),
        );
      },
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}

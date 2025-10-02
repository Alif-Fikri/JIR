import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/pages/home/main/widget/home_shimmer.dart';

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        if (controller.isLoading.value) {
          return GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 30.h,
            children: List.generate(8, (_) => const _FeatureShimmer()),
          );
        }

        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 30.h,
          children: const [
            _FeatureIcon(
              label: 'Pantau Banjir',
              imagePath: 'assets/images/pantau_banjir.png',
              route: AppRoutes.flood,
            ),
            _FeatureIcon(
              label: 'Pantau Kerumunan',
              imagePath: 'assets/images/pantau_kerumunan.png',
              route: AppRoutes.crowd,
            ),
            _FeatureIcon(
              label: 'Taman',
              imagePath: 'assets/images/taman.png',
              route: AppRoutes.park,
            ),
            _FeatureIcon(
              label: 'Peta',
              imagePath: 'assets/images/peta.png',
              route: AppRoutes.peta,
            ),
            _FeatureIcon(
              label: 'CCTV',
              imagePath: 'assets/images/cctv.png',
              route: AppRoutes.cctv,
            ),
            _FeatureIcon(
              label: 'Cuaca',
              imagePath: 'assets/images/cuaca.png',
              route: AppRoutes.cuaca,
            ),
            _FeatureIcon(
              label: 'Laporan',
              imagePath: 'assets/images/laporan.png',
              route: AppRoutes.lapor,
            ),
          ],
        );
      }),
    );
  }
}

class _FeatureShimmer extends StatelessWidget {
  const _FeatureShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(30.r),
          child: CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.white,
            child: HomeShimmer.circle(size: 36),
          ),
        ),
        SizedBox(height: 8.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 70.w),
          child: HomeShimmer.rect(
            height: 10.h,
            width: 50.w,
            radius: BorderRadius.circular(6.r),
          ),
        ),
      ],
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({
    required this.label,
    required this.imagePath,
    required this.route,
  });

  final String label;
  final String imagePath;
  final String route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30.r),
            shadowColor: Colors.grey.withOpacity(1),
            child: CircleAvatar(
              radius: 30.r,
              backgroundColor: const Color(0xFFEAEFF3),
              child: Image.asset(
                imagePath,
                width: 30.w,
                height: 30.h,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 70.w),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: const Color(0xFF355469),
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

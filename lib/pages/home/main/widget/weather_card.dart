import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/pages/home/main/widget/home_shimmer.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.controller});

  final HomeController controller;

  static const double cardHeight = 250;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final weatherIcon = controller.weatherIcon.value.trim();
      final weatherDesc = controller.weatherDescription.value;
      final temp = controller.temperature.value;
      final location = controller.location.value;
      final ready = !isLoading && weatherDesc.isNotEmpty && location.isNotEmpty;
      final bgPath = controller.backgroundImage.value.trim();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: cardHeight.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: _buildBackgroundWidget(bgPath, isLoading),
              ),
            ),
            Positioned(
              bottom: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.all(10.w),
                width: 110.w,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: ready
                    ? _buildContent(weatherIcon, weatherDesc, temp, location)
                    : _buildLoadingState(),
              ),
            ),
            Positioned(
              top: -20.h,
              right: -10.w,
              child: CircleAvatar(
                radius: 35.r,
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/images/path.png',
                  width: 45.w,
                  height: 45.h,
                  color: Colors.black,
                  errorBuilder: (_, __, ___) => SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContent(
    String iconPath,
    String description,
    String temperature,
    String location,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80.w,
          height: 50.h,
          child: iconPath.isNotEmpty
              ? Image.asset(
                  iconPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => SizedBox.shrink(),
                )
              : SizedBox.shrink(),
        ),
        SizedBox(height: 5.h),
        Text(
          description,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$temperature°',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          location,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 8.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80.w,
          height: 50.h,
          child: HomeShimmer.rect(
            height: 50.h,
            width: 80.w,
            radius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(height: 8.h),
        HomeShimmer.rect(height: 12.h, width: 80.w),
        SizedBox(height: 6.h),
        HomeShimmer.rect(height: 12.h, width: 40.w),
        SizedBox(height: 6.h),
        HomeShimmer.rect(height: 9.h, width: 70.w),
      ],
    );
  }

  Widget _buildBackgroundWidget(String bgPath, bool isLoading) {
    if (bgPath.isNotEmpty) {
      return Image.asset(
        bgPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _backgroundFallback(isLoading),
      );
    }
    return _backgroundFallback(isLoading);
  }

  Widget _backgroundFallback(bool isLoading) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(color: Colors.white),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff51669D), Color(0xff45557B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.06,
          child: Image.asset(
            'assets/images/pattern.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

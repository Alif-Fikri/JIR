import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildBackgroundWidget(bgPath, isLoading),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(10),
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ready
                    ? _buildContent(weatherIcon, weatherDesc, temp, location)
                    : _buildLoadingState(),
              ),
            ),
            Positioned(
              top: -20,
              right: -10,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/images/path.png',
                  width: 45,
                  height: 45,
                  color: Colors.black,
                  errorBuilder: (_, __, ___) => const SizedBox(),
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
          width: 80,
          height: 50,
          child: iconPath.isNotEmpty
              ? Image.asset(
                  iconPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$temperature°',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          location,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 8,
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
          width: 80,
          height: 50,
          child: HomeShimmer.rect(
            height: 50,
            width: 80,
            radius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        HomeShimmer.rect(height: 12, width: 80),
        const SizedBox(height: 6),
        HomeShimmer.rect(height: 12, width: 40),
        const SizedBox(height: 6),
        HomeShimmer.rect(height: 9, width: 70),
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
      decoration: const BoxDecoration(
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
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

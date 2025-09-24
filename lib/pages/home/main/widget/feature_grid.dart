import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:shimmer/shimmer.dart';

class FeatureGrid extends StatelessWidget {
  final HomeController controller;
  const FeatureGrid({super.key, required this.controller});
  Widget _shimmerRect(
      {double height = 12,
      double width = double.infinity,
      BorderRadius? radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius ?? BorderRadius.circular(6)),
      ),
    );
  }

  Widget _shimmerCircle({double size = 44}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }

  Widget _shimmerFeature() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: _shimmerCircle(size: 36)),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 70),
          child: _shimmerRect(
              height: 10, width: 50, radius: BorderRadius.circular(6)),
        ),
      ],
    );
  }

  Widget featureIcon({
    required VoidCallback onPressed,
    String? imagePath,
    IconData? icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30),
            shadowColor: Colors.grey.withOpacity(1.0),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFEAEFF3),
              child: imagePath != null
                  ? Image.asset(imagePath, width: 30, height: 30)
                  : Icon(icon, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 70),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF355469)),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -125),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          if (isLoading) {
            return GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 30.0,
              children: List.generate(8, (_) => _shimmerFeature()),
            );
          }
          return GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 30.0,
            children: [
              featureIcon(
                  onPressed: () => Get.toNamed(AppRoutes.flood),
                  label: 'Pantau Banjir',
                  imagePath: 'assets/images/pantau_banjir.png'),
              featureIcon(
                  onPressed: () => Get.toNamed(AppRoutes.crowd),
                  imagePath: 'assets/images/pantau_kerumunan.png',
                  label: 'Pantau Kerumunan'),
              featureIcon(
                  onPressed: () => Get.toNamed(AppRoutes.park),
                  imagePath: 'assets/images/taman.png',
                  label: 'Taman'),
              featureIcon(
                  onPressed: () => Get.toNamed(AppRoutes.peta),
                  imagePath: 'assets/images/peta.png',
                  label: 'Peta'),
              featureIcon(
                  onPressed: () => Get.toNamed(AppRoutes.cctv),
                  imagePath: 'assets/images/cctv.png',
                  label: 'CCTV'),
              featureIcon(
                  onPressed: () => Get.toNamed(AppRoutes.cuaca),
                  imagePath: 'assets/images/cuaca.png',
                  label: 'Cuaca'),
              featureIcon(
                  onPressed: () => Get.toNamed(AppRoutes.lapor),
                  imagePath: 'assets/images/laporan.png',
                  label: 'Laporan'),
            ],
          );
        }),
      ),
    );
  }
}

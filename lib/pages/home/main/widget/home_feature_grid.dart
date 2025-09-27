import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/pages/home/main/widget/home_shimmer.dart';

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        if (controller.isLoading.value) {
          return GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 30,
            children: List.generate(8, (_) => const _FeatureShimmer()),
          );
        }

        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 30,
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
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: HomeShimmer.circle(size: 36),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 70),
          child: HomeShimmer.rect(
            height: 10,
            width: 50,
            radius: BorderRadius.circular(6),
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
            borderRadius: BorderRadius.circular(30),
            shadowColor: Colors.grey.withOpacity(1),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFEAEFF3),
              child: Image.asset(
                imagePath,
                width: 30,
                height: 30,
              ),
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
                  fontSize: 11,
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

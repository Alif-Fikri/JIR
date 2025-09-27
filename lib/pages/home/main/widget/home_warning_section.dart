import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
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
          height: 28,
          width: 120,
          radius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 16),
        HomeShimmer.rect(
          height: 64,
          width: double.infinity,
          radius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        HomeShimmer.rect(
          height: 64,
          width: double.infinity,
          radius: BorderRadius.circular(8),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD205),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

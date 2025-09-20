import 'package:JIR/pages/notifications/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/helper/loading.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.find<HomeController>();
  final NotificationController nc = Get.find<NotificationController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingPage();
      }
      return _buildMainContent();
    });
  }

  Widget _buildMainContent() {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            RefreshIndicator(
              color: Colors.white,
              backgroundColor: Color(0xff45557B),
              onRefresh: controller.refreshData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(87),
                        bottomRight: Radius.circular(87),
                      ),
                      child: Container(
                        height: 308.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF45557B),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "JIR APPLICATION",
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      return Transform.translate(
                        offset: const Offset(0, -170),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 250,
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          controller.backgroundImage.value,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 50,
                                        child: Image.asset(
                                          controller.weatherIcon.value,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        controller.weatherDescription.value,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "${controller.temperature.value}°",
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        controller.location.value,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -20.0,
                                right: -10.0,
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    'assets/images/path.png',
                                    width: 45,
                                    height: 45,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Transform.translate(
                      offset: const Offset(0, -140),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(50),
                          shadowColor: Colors.grey.withOpacity(0.5),
                          child: TextField(
                            style: GoogleFonts.inter(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search . . .',
                              hintStyle: GoogleFonts.inter(
                                  fontSize: 15.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5.0,
                                    top: 5.0,
                                    left: 18.0,
                                    right: 15.0),
                                child: Image.asset(
                                  'assets/images/search.png',
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEDEDED),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -125),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 30.0,
                          children: [
                            featureIcon(
                              onPressed: () => Get.toNamed(AppRoutes.flood),
                              label: 'Pantau Banjir',
                              imagePath: 'assets/images/pantau_banjir.png',
                            ),
                            featureIcon(
                              onPressed: () => Get.toNamed(AppRoutes.crowd),
                              imagePath: 'assets/images/pantau_kerumunan.png',
                              label: 'Pantau Kerumunan',
                            ),
                            featureIcon(
                              onPressed: () => Get.toNamed(AppRoutes.park),
                              imagePath: 'assets/images/taman.png',
                              label: 'Taman',
                            ),
                            featureIcon(
                              onPressed: () => Get.toNamed(AppRoutes.peta),
                              imagePath: 'assets/images/peta.png',
                              label: 'Peta',
                            ),
                            featureIcon(
                              onPressed: () => Get.toNamed(AppRoutes.cctv),
                              imagePath: 'assets/images/cctv.png',
                              label: 'CCTV',
                            ),
                            featureIcon(
                              onPressed: () => Get.toNamed(AppRoutes.cuaca),
                              imagePath: 'assets/images/cuaca.png',
                              label: 'Cuaca',
                            ),
                            featureIcon(
                              onPressed: () {
                                Get.toNamed(AppRoutes.lapor);
                              },
                              imagePath: 'assets/images/laporan.png',
                              label: 'Laporan',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -80),
                      child: Image.asset('assets/images/line2.png'),
                    ),
                    const SizedBox(height: 16),
                    Transform.translate(
                      offset: const Offset(0, -60),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Obx(() {
                          final warns = nc.warnings;
                          if (warns.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final toShow = warns.take(2).toList();
                          return Column(
                            children: [
                              Text(
                                "WARNING",
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              ...toShow.map((n) {
                                final title = (n['title'] ?? n['message'] ?? '')
                                    .toString();
                                return warningBox(title);
                              }).toList(),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.all(16),
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: controller.animationController,
              builder: (context, child) {
                double bounce = math.sin(
                        controller.animationController.value * 2 * math.pi) *
                    5;
                return Positioned(
                  bottom: 50 + bounce,
                  right: 25,
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.chatbot),
                    child: Image.asset('assets/images/robot.png',
                        width: 70, height: 70),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget featureIcon(
      {required VoidCallback onPressed,
      String? imagePath,
      IconData? icon,
      required String label}) {
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

  Widget warningBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD205),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

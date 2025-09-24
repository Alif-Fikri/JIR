import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';

class WeatherCard extends StatelessWidget {
  final HomeController controller;
  const WeatherCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final bgPath = controller.backgroundImage.value.toString().trim();
      final iconPath = controller.weatherIcon.value.toString().trim();
      final weatherDesc = controller.weatherDescription.value;
      final temp = controller.temperature.value;
      final location = controller.location.value;
      final ready = !isLoading && weatherDesc.isNotEmpty && location.isNotEmpty;

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
                        offset: const Offset(0, 8))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: bgPath.isNotEmpty
                      ? Image.asset(bgPath, fit: BoxFit.cover)
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xff51669D), Color(0xff45557B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
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
                      borderRadius: BorderRadius.circular(15)),
                  child: ready
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 50,
                              child: iconPath.isNotEmpty
                                  ? Image.asset(iconPath, fit: BoxFit.cover)
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 5),
                            Text(weatherDesc,
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                            Text("$temp°",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                            Text(location,
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700)),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 80, height: 50, color: Colors.white24),
                            const SizedBox(height: 8),
                            Container(
                                width: 80, height: 12, color: Colors.white24),
                            const SizedBox(height: 6),
                            Container(
                                width: 40, height: 12, color: Colors.white24),
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
                  child: Image.asset('assets/images/path.png',
                      width: 45, height: 45, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

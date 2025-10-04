import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:JIR/pages/home/map/controller/route_controller.dart';

class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key, this.heading});

  final double? heading;

  @override
  Widget build(BuildContext context) {
    RouteController? rc;
    if (heading == null && Get.isRegistered<RouteController>()) {
      rc = Get.find<RouteController>();
    }

    Widget marker(double direction) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          Transform.rotate(
            angle: (direction * (math.pi / 180)),
            child: CustomPaint(
              size: const Size(48, 48),
              painter: _DirectionLightPainter(),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (rc != null) {
      return Obx(() {
        final double currentHeading = rc!.userHeading.value;
        return marker(currentHeading);
      });
    }

    return marker(heading ?? 0);
  }
}

class _DirectionLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = ui.Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..close();

    canvas.drawPath(path, shadowPaint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

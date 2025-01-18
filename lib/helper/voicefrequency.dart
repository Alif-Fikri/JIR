import 'package:flutter/material.dart';
import 'dart:math';

class VoiceFrequencyPainter extends CustomPainter {
  final double progress;

  VoiceFrequencyPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final numWaves = 40; // Banyak gelombang

    for (int i = 0; i < numWaves; i++) {
      final x = i * (size.width / numWaves);
      final amplitude = sin((progress + i) * 0.5) * 30;
      final startY = centerY - amplitude;
      final endY = centerY + amplitude;
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

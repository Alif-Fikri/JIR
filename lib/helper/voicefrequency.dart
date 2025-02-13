import 'package:flutter/material.dart';
import 'dart:math';

class VoiceFrequencyPainter extends CustomPainter {
  final double progress;

  VoiceFrequencyPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    const numWaves = 40;

    for (int i = 0; i < numWaves; i++) {
      final x = i * (size.width / numWaves);
      final amplitude = sin((progress + i) * 0.5) * 30;
      final startY = centerY - amplitude;
      final endY = centerY + amplitude;

    
      final colorProgress = (sin(progress) + 1) / 2;
      final color = Color.lerp(Colors.red, Colors.blue, colorProgress)!;

      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

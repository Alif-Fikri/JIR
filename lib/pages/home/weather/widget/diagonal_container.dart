import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class DiagonalContainer extends StatelessWidget {
  const DiagonalContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DiagonalShadowPainter(),
      child: ClipPath(
        clipper: DiagonalClipper(),
        child: Container(
          width: double.infinity,
          height: 330.h,
          color: const Color(0xffFEE67A),
        ),
      ),
    );
  }
}

Path getDiagonalPath(Size size) {
  final radius = 20.w;
  final diagonalHeight = 48.3.h;

  Path path = Path();

  path.moveTo(0, 0);
  path.lineTo(size.width, 0);
  path.lineTo(size.width, size.height - diagonalHeight - radius);
  path.quadraticBezierTo(
    size.width,
    size.height - diagonalHeight,
    size.width - radius,
    size.height - diagonalHeight,
  );
  path.lineTo(radius, size.height);
  path.quadraticBezierTo(
    0,
    size.height,
    0,
    size.height - radius,
  );
  path.close();

  return path;
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getDiagonalPath(size);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DiagonalShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = getDiagonalPath(size);
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.9),
      5.r,
      true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

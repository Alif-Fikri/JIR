import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeShimmer {
  static Widget rect({
    double height = 12,
    double width = double.infinity,
    BorderRadius? radius,
  }) {
    final h = height.h;
    final w = width == double.infinity ? double.infinity : width.w;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius ?? BorderRadius.circular(6.r),
        ),
      ),
    );
  }

  static Widget circle({double size = 44}) {
    final s = size.r;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: s,
        height: s,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

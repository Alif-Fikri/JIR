import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

final double fixedWidth = 350.w;
final double fixedHeight = 50.h;

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String icon,
  bool isObscure = false,
}) {
  return SizedBox(
    width: fixedWidth,
    height: fixedHeight,
    child: TextField(
      controller: controller,
      obscureText: isObscure,
      cursorColor: const Color(0xFF45557B),
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        prefixIcon: Padding(
          padding:
              EdgeInsets.only(bottom: 15.h, top: 15.h, left: 30.w, right: 10.w),
          child: Image.asset(
            icon,
            width: 16.w,
            height: 16.h,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFDADADA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFDADADA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: const Color(0xFF45557B), width: 2.w),
        ),
      ),
    ),
  );
}

Widget buildErrorMessage(String message) {
  return Container(
    width: fixedWidth,
    alignment: Alignment.centerRight,
    child: Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.info,
            color: Colors.red,
            size: 16.sp,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(50.r),
        shadowColor: Colors.grey.withOpacity(0.5),
        child: TextField(
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Search . . .',
            hintStyle: GoogleFonts.inter(
              fontSize: 15.sp,
              color: Colors.black,
              fontStyle: FontStyle.italic,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                bottom: 5.h,
                top: 5.h,
                left: 18.w,
                right: 15.w,
              ),
              child: Image.asset(
                'assets/images/search.png',
                height: 25.h,
                width: 25.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.r),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFEDEDED),
          ),
        ),
      ),
    );
  }
}

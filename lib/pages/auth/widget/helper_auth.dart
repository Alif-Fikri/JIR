import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double fixedWidth = 350.0;
const double fixedHeight = 50.0;

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
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
              bottom: 15.0, top: 15.0, left: 30, right: 10),
          child: Image.asset(
            icon,
            width: 16,
            height: 16,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDADADA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDADADA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF45557B), width: 2),
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
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(
            Icons.info,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
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

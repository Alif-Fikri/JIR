import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    String? imageAssetPath,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: backgroundColor,
      content: Row(
        children: [
          if (imageAssetPath != null)
            Image.asset(
              imageAssetPath,
              width: 35,
              height: 35,
            ),
          if (imageAssetPath != null) const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(color: textColor),
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

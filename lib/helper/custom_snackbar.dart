import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    String? imageAssetPath,
    bool useAppIcon = false,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
  }) {
    final appIconPath = 'assets/images/ic_launcher.png';
    String? chosenAsset;
    if (imageAssetPath != null && imageAssetPath.isNotEmpty) {
      chosenAsset = imageAssetPath;
    } else if (useAppIcon) {
      chosenAsset = appIconPath;
    }

    Widget leading;
    if (chosenAsset != null) {
      leading = Image.asset(
        chosenAsset,
        width: 36,
        height: 36,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.notifications, color: textColor, size: 20),
          );
        },
      );
    } else {
      leading = CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade200,
        child: Icon(Icons.notifications, color: textColor, size: 20),
      );
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: backgroundColor,
      content: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(color: textColor),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

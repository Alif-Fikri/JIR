import 'dart:io';
import 'package:flutter/material.dart';

Widget buildReportImage(String imagePath,
    {double? height, BoxFit fit = BoxFit.cover}) {
  if (imagePath.isEmpty) {
    return Container(
      height: height ?? 160,
      color: Colors.grey[100],
      child: Center(child: Text('Tidak ada foto')),
    );
  }

  final trimmed = imagePath.trim();

  if (trimmed.startsWith('http')) {
    return Image.network(
      trimmed,
      height: height,
      width: double.infinity,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height ?? 160,
          color: Colors.grey[100],
          child: Center(
              child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1)
                      : null)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height ?? 160,
          color: Colors.grey[200],
          child: Center(child: Icon(Icons.broken_image)),
        );
      },
    );
  }
  try {
    final file = File(trimmed);
    if (file.existsSync()) {
      return Image.file(file, height: height, width: double.infinity, fit: fit);
    }
  } catch (_) {}
  return Container(
    height: height ?? 160,
    color: Colors.grey[100],
    child: Center(child: Text('Foto tidak tersedia')),
  );
}

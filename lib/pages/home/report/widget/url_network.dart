import 'dart:io';

import 'package:JIR/utils/file_utils.dart';
import 'package:flutter/material.dart';

Widget buildReportImage(String imageUrl, {double? height, BoxFit? fit}) {
  final useFit = fit ?? BoxFit.cover;
  if (imageUrl.isEmpty) {
    return Container(
      height: height ?? 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image)),
    );
  }

  if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
    return Image.network(
      Uri.encodeFull(imageUrl),
      height: height,
      width: double.infinity,
      fit: useFit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final p = progress.expectedTotalBytes != null
            ? progress.cumulativeBytesLoaded /
                (progress.expectedTotalBytes ?? 1)
            : null;
        return Container(
          height: height ?? 200,
          width: double.infinity,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(value: p),
          ),
        );
      },
      errorBuilder: (context, error, stack) {
        return Container(
          height: height ?? 200,
          width: double.infinity,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image)),
        );
      },
    );
  }

  try {
    final localPath = normalizeLocalPath(imageUrl);
    final f = File(localPath);
    if (f.existsSync()) {
      return Image.file(
        f,
        height: height,
        width: double.infinity,
        fit: useFit,
        errorBuilder: (context, error, stack) {
          return Container(
            height: height ?? 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.broken_image)),
          );
        },
      );
    }
  } catch (_) {}

  return Container(
    height: height ?? 200,
    width: double.infinity,
    color: Colors.grey[200],
    child: const Center(child: Icon(Icons.broken_image)),
  );
}

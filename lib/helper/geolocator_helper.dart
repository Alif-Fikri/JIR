import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class GeolocatorHelper {
  static Future<bool> checkAndRequestPermission(
      {bool showSnackbar = true}) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[GeolocatorHelper] Location permission denied');
          if (showSnackbar) {
            Get.snackbar(
              'Permission Denied',
              'Lokasi diperlukan untuk fitur ini',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[GeolocatorHelper] Location permission denied forever');
        if (showSnackbar) {
          Get.snackbar(
            'Permission Denied',
            'Aktifkan izin lokasi di Settings untuk menggunakan fitur ini',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }
        return false;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[GeolocatorHelper] Location service is disabled');
        if (showSnackbar) {
          Get.snackbar(
            'Location Service Disabled',
            'Aktifkan Location Services di Settings untuk menggunakan fitur ini',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('[GeolocatorHelper] Permission check error: $e');
      if (showSnackbar && e.toString().contains('kCLErrorDomain')) {
        Get.snackbar(
          'Location Error',
          'Aktifkan Location Services di Settings > Privacy > Location Services',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
      return false;
    }
  }

  static Future<Position?> getCurrentPosition({
    bool showSnackbar = true,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      final hasPermission =
          await checkAndRequestPermission(showSnackbar: showSnackbar);
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );

      return position;
    } catch (e) {
      debugPrint('[GeolocatorHelper] getCurrentPosition error: $e');
      if (showSnackbar) {
        Get.snackbar(
          'Location Error',
          'Gagal mendapatkan lokasi saat ini',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return null;
    }
  }

  static Future<Stream<Position>?> getPositionStream({
    bool showSnackbar = true,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) async {
    try {
      final hasPermission =
          await checkAndRequestPermission(showSnackbar: showSnackbar);
      if (!hasPermission) return null;

      final stream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        ),
      );

      return stream;
    } catch (e) {
      debugPrint('[GeolocatorHelper] getPositionStream error: $e');
      if (showSnackbar) {
        Get.snackbar(
          'Location Error',
          'Gagal mendapatkan stream lokasi',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return null;
    }
  }
}

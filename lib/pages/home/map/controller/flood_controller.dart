import 'package:JIR/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:JIR/pages/home/map/widget/detail_flood.dart';
import 'package:JIR/services/flood_service/flood_api_service.dart';

class FloodController extends GetxController {
  final FloodService _floodService = FloodService();
  final floodData = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  bool _hasInitialLoad = false;

  @override
  void onInit() {
    super.onInit();
    loadFloodData();
  }

  Future<void> loadFloodData() async {
    if (_hasInitialLoad) return;
    isLoading(true);
    try {
      final data = await _floodService.fetchFloodData();
      final cleanedData = data.map((item) {
        final rawStatus = item["STATUS_SIAGA"];
        final normalized = _formatStatus(rawStatus);
        return {
          ...item,
          "STATUS_SIAGA": normalized,
        };
      }).toList();

      floodData.value = cleanedData;
      _hasInitialLoad = true;


      // if (floodData.isNotEmpty) {
      //   _showFloodMonitoringBottomSheet(Get.context!);
      // }
    } finally {
      isLoading(false);
    }
  }

  void _showFloodMonitoringBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.2,
          maxChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return FloodMonitoringBottomSheet(
              floodData: floodData,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  void showDisasterDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DisasterBottomSheet(
        location: item['NAMA_PINTU_AIR'] ?? 'Lokasi Tidak Diketahui',
        status: item['STATUS_SIAGA'] ?? 'N/A',
        onViewLocation: () => navigateToFloodMonitoring(context, item),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void navigateToFloodMonitoring(
      BuildContext context, Map<String, dynamic> item) {
    final latStr = item['LATITUDE'].toString();
    final lngStr = item['LONGITUDE'].toString();

    final latitude = double.tryParse(latStr);
    final longitude = double.tryParse(lngStr);

    if (latitude == null || longitude == null) {
      Get.snackbar("Error", "Koordinat tidak valid: ($latStr, $lngStr)");
      return;
    }

    Get.toNamed(AppRoutes.flood, arguments: LatLng(latitude, longitude));
  }

  void showFloodMonitoringSheet() {
    if (floodData.isNotEmpty) {
      _showFloodMonitoringBottomSheet(Get.context!);
    }
  }

  String _formatStatus(dynamic statusRaw) {
    if (statusRaw == null) return 'Normal';
    if (statusRaw is int) return _mapIntToStatus(statusRaw);
    final s = statusRaw.toString().trim();
    final digits = RegExp(r'\d+').firstMatch(s)?.group(0);
    if (digits != null) {
      final n = int.tryParse(digits);
      if (n != null) return _mapIntToStatus(n);
    }
    final cleaned = s
        .replaceAll(RegExp(r'status\s*:?\s*', caseSensitive: false), '')
        .trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == 'n/a') return 'Normal';

    final lower = cleaned.toLowerCase();
    if (lower.contains('siaga 3') || lower == '3') return 'Siaga 3';
    if (lower.contains('siaga 2') || lower == '2') return 'Siaga 2';
    if (lower.contains('siaga 1') || lower == '1') return 'Siaga 1';
    if (lower.contains('sedang')) return 'Sedang';
    if (lower.contains('normal')) return 'Normal';

    return cleaned
        .split(RegExp(r'\s+'))
        .map((w) =>
            w.isEmpty ? w : (w[0].toUpperCase() + w.substring(1).toLowerCase()))
        .join(' ');
  }

  String _mapIntToStatus(int v) {
    switch (v) {
      case 3:
        return 'Siaga 3';
      case 2:
        return 'Siaga 2';
      case 1:
        return 'Siaga 1';
      default:
        return 'Normal';
    }
  }
}

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
        return {
          ...item,
          "STATUS_SIAGA": item["STATUS_SIAGA"]
              .toString()
              .replaceAll(RegExp(r"Status\s*:\s*"), ""),
        };
      }).toList();

      print("Data API setelah dibersihkan: $cleanedData");
      floodData.value = cleanedData;
      _hasInitialLoad = true;

      print("Data banjir di-load sekali saja");

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
}

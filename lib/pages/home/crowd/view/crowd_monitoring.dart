import 'package:JIR/helper/map.dart';
import 'package:JIR/helper/mapbox_config.dart';
import 'package:JIR/pages/home/crowd/controller/crowd_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class CrowdMonitoringPage extends StatelessWidget {
  final CrowdController controller = Get.put(CrowdController());

  CrowdMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Kerumunan',
        style: GoogleFonts.inter(
          fontSize: 20.sp,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: const Color(0xFF45557B),
      elevation: 10.r,
      shadowColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMapSection(),
          _buildDataSection(),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final entries = controller.locations.entries.toList();
    final markerPositions = entries
        .map((entry) => ll.LatLng(entry.value.latitude, entry.value.longitude))
        .toList();

    final markerData = entries.map((entry) {
      final dynamic live = controller.liveData[entry.key];
      final predictedValue =
          live is Map<String, dynamic> ? live['predicted_count'] : live;
      final count = _resolvePredictedCount(predictedValue);
      final level = controller.getLevel(count);

      return {
        'markerType': 'cctv',
        'location': entry.key,
        'predicted_count': count,
        'level': level,
        'latitude': entry.value.latitude,
        'longitude': entry.value.longitude,
      };
    }).toList();

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Container(
        height: 250.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 5.r, spreadRadius: 2.r),
          ],
        ),
        child: MapboxReusableMap(
          accessToken: MapboxConfig.accessToken,
          styleUri: MapboxStyles.MAPBOX_STREETS,
          initialLocation: ll.LatLng(-6.2000, 106.8167),
          markers: markerPositions,
          markerData: markerData,
          userLocation: null,
          routePoints: null,
          onMarkerDataTap: _showCrowdDetails,
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level Kerumunan',
            style: GoogleFonts.publicSans(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          _buildLiveData(),
          const SizedBox(height: 16),
          // _buildHistoricalData(),
        ],
      ),
    );
  }

  Widget _buildLiveData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kerumunan Hari Ini",
          style: GoogleFonts.publicSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        _buildCrowdList(controller.liveData),
      ],
    );
  }

  // Widget _buildHistoricalData() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Kerumunan Kemarin",
  //         style: GoogleFonts.publicSans(
  //           fontSize: 20,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       // _buildCrowdList(controller.yesterdayCrowd),
  //     ],
  //   );
  // }

  Widget _buildCrowdList(dynamic data) {
    final items = data is Map<String, dynamic>
        ? controller.locations.keys
            .map((location) => _mapLiveData(location))
            .toList()
        : data;

    return Column(
      children: (items as List)
          .map<Widget>((item) => CrowdListItem(item: item))
          .toList(),
    );
  }

  Map<String, dynamic> _mapLiveData(String location) {
    final rawValue = controller.liveData[location]?['predicted_count'];
    final countValue = _resolvePredictedCount(rawValue);
    return {
      'location': location,
      'count': countValue.toString(),
      'level': controller.getLevel(countValue),
    };
  }

  void _showCrowdDetails(Map<String, dynamic> data) {
    final location = data['location']?.toString() ?? 'Lokasi';
    final countValue = _resolvePredictedCount(data['predicted_count']);
    final level = data['level']?.toString() ?? controller.getLevel(countValue);
    final latitude = data['latitude'];
    final longitude = data['longitude'];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detail Kerumunan',
              style: GoogleFonts.publicSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF45557B),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x1145557B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on, color: Color(0xFF45557B)),
              ),
              title: Text(
                location,
                style: GoogleFonts.publicSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: (latitude is num && longitude is num)
                  ? Text(
                      'Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}',
                      style: GoogleFonts.publicSans(fontSize: 12.sp),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: controller.getLevelColor(level),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  level,
                  style: GoogleFonts.publicSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: controller.getLevelColor(level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$countValue Orang',
              style: GoogleFonts.publicSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: Get.back,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF45557B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.publicSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  int _resolvePredictedCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class CrowdListItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const CrowdListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CrowdController>();

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xffF0F2F5),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Icon(
          Icons.location_on_outlined,
          color: Color(0xff121417),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['location'],
            style: GoogleFonts.publicSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: controller.getLevelColor(item['level']),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                item['level'],
                style: GoogleFonts.publicSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Text(
        '${item['count']} Orang',
        style: GoogleFonts.publicSans(
          fontSize: 18.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}

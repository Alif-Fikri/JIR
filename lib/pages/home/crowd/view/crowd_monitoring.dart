import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:JIR/pages/home/crowd/controller/crowd_controller.dart';
import 'package:JIR/helper/map.dart';
import 'package:JIR/pages/home/crowd/widget/crowd_marker.dart';

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
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Container(
        height: 250.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.r,
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: ReusableMap(
          initialLocation: const LatLng(-6.2000, 106.8167),
          markers: _buildMarkers(),
          userLocation: null,
          destination: null,
          routePoints: null,
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return controller.locations.entries.map((entry) {
      final data = controller.liveData[entry.key] ?? {'predicted_count': 0};
      final count = data['predicted_count']?.toString() ?? '0';
      final level = controller.getLevel(int.tryParse(count) ?? 0);

      return Marker(
        point: entry.value,
        width: 60.w,
        height: 60.h,
        child: CrowdMarker(
          count: count,
          level: level,
          color: controller.getLevelColor(level),
        ),
      );
    }).toList();
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
    final count =
        controller.liveData[location]?['predicted_count']?.toString() ?? '0';
    return {
      'location': location,
      'count': count,
      'level': controller.getLevel(int.parse(count)),
    };
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

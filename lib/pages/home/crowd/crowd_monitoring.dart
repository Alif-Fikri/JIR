import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartcitys/app/controllers/crowd_controller.dart';
import 'package:smartcitys/helper/map.dart';
import 'package:smartcitys/pages/home/crowd/crowd_marker.dart';

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
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: const Color(0xFF45557B),
      elevation: 10,
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
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 2,
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
        width: 60,
        height: 60,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level Kerumunan',
            style: GoogleFonts.publicSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
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
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xffF0F2F5),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
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
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: controller.getLevelColor(item['level']),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item['level'],
                style: GoogleFonts.publicSans(
                  fontSize: 12,
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
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}

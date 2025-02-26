import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartcitys/helper/map.dart';

class CrowdMonitoringPage extends StatelessWidget {
  final List<Map<String, dynamic>> todayCrowd = [
    {'location': 'Union Square', 'level': 'High', 'count': '2.5k'},
    {'location': 'Westfield Centre', 'level': 'Medium', 'count': '1.8k'},
    {'location': 'Ferry Building', 'level': 'Low', 'count': '700'},
  ];

  final List<Map<String, dynamic>> yesterdayCrowd = [
    {'location': 'Union Square', 'level': 'High', 'count': '3.2k'},
    {'location': 'Westfield Centre', 'level': 'Medium', 'count': '2.3k'},
    {'location': 'Ferry Building', 'level': 'Low', 'count': '700'},
  ];

  CrowdMonitoringPage({super.key});
  final List<Marker> crowdmarkers = [
    Marker(
      point: LatLng(-6.2088, 106.8456), 
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            '2.5k',
            style: GoogleFonts.inter(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
    Marker(
      point: LatLng(-6.1945, 106.8229),
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            '1.8k',
            style: GoogleFonts.inter(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
    Marker(
      point: LatLng(-6.1754, 106.8273),
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            '700',
            style: GoogleFonts.inter(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  ];

  Color _getCrowdLevelColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Kerumunan',
            style: GoogleFonts.inter(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF45557B),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ReusableMap(
                  initialLocation: LatLng(-6.2000, 106.8167),
                  markers: crowdmarkers,
                  userLocation: null,
                  destination: null,
                  routePoints: null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level Kerumunan',
                      style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Kerumunan hari ini",
                      style: GoogleFonts.inter(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildCrowdList(todayCrowd),
                    const SizedBox(height: 16),
                    const Text(
                      "Kerumunan kemarin",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildCrowdList(yesterdayCrowd),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }

  Widget _buildCrowdList(List<Map<String, dynamic>> crowdData) {
    return Column(
      children: crowdData.map((data) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.rectangle,
            ),
            child: const Icon(Icons.location_on, color: Colors.black),
          ),
          title: Text(data['location']),
          titleTextStyle:
              GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400),
          subtitle: Text(
            data['level'],
            style: GoogleFonts.inter(
              color: _getCrowdLevelColor(data['level']),
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(data['count']),
          leadingAndTrailingTextStyle:
              GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400),
        );
      }).toList(),
    );
  }
}

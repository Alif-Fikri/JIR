import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/pages/home/cctv/cctv_webview.dart';
import 'package:latlong2/latlong.dart';
import 'package:JIR/helper/map.dart';
import 'package:google_fonts/google_fonts.dart';

class CCTVPage extends StatelessWidget {
  final List<CCTVLocation> cctvLocations = [
    CCTVLocation(
      name: "DPR",
      url:
          "https://cctv.balitower.co.id/Bendungan-Hilir-003-700014_1/embed.html",
      coordinates: const LatLng(-6.2096, 106.8005),
    ),
    CCTVLocation(
      name: "Bundaran HI",
      url: "https://cctv.balitower.co.id/Menteng-001-700123_5/embed.html",
      coordinates: const LatLng(-6.1945, 106.8229),
    ),
    CCTVLocation(
      name: "Monas",
      url: "https://cctv.balitower.co.id/Monas-Barat-009-506632_2/embed.html",
      coordinates: const LatLng(-6.1754, 106.8273),
    ),
    CCTVLocation(
      name: "Patung Kuda",
      url: "https://cctv.balitower.co.id/JPO-Merdeka-Barat-507357_9/embed.html",
      coordinates: const LatLng(-6.1715, 106.8343),
    ),
  ];

  CCTVPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cctvMarkers = cctvLocations.map((location) {
      return Marker(
        point: location.coordinates,
        width: 40.w,
        height: 40.w,
        child: GestureDetector(
          onTap: () => _navigateToCCTV(context, location.url),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF45557B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.w),
            ),
            child: Icon(Icons.videocam, color: Colors.white, size: 20.sp),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("CCTV",
            style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        backgroundColor: const Color(0xFF45557B),
        elevation: 10,
        shadowColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
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
                markers: cctvMarkers,
                userLocation: null,
                destination: null,
                routePoints: null,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Ayo Pantau !",
                  style: GoogleFonts.inter(
                      fontSize: 20.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: _buildLocationGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.2,
      ),
      itemCount: cctvLocations.length,
      itemBuilder: (context, index) {
        final location = cctvLocations[index];
        return GestureDetector(
          onTap: () => _navigateToCCTV(context, location.url),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.asset(
                    "assets/images/${location.name.toLowerCase().replaceAll(' ', '_')}.jpg",
                    height: 80.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(location.name, style: GoogleFonts.inter(fontSize: 14.sp)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToCCTV(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CCTVWebView(url: url),
      ),
    );
  }
}

class CCTVLocation {
  final String name;
  final String url;
  final LatLng coordinates;

  CCTVLocation({
    required this.name,
    required this.url,
    required this.coordinates,
  });
}

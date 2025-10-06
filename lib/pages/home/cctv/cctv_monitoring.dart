import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/helper/map.dart';
import 'package:JIR/helper/mapbox_config.dart';
import 'package:JIR/pages/home/cctv/cctv_webview.dart';
import 'package:JIR/pages/home/cctv/model/cctv_location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class CCTVPage extends StatelessWidget {
  final List<CCTVLocation> cctvLocations =
      List<CCTVLocation>.from(defaultCctvLocations);

  CCTVPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cctvPositions = cctvLocations.map((loc) => loc.coordinates).toList();

    final markerData = cctvLocations
        .map((loc) => {
              'markerType': 'cctv',
              'name': loc.name,
              'url': loc.url,
              'latitude': loc.coordinates.latitude,
              'longitude': loc.coordinates.longitude,
            })
        .toList();
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: MapboxReusableMap(
                  accessToken: MapboxConfig.accessToken,
                  styleUri: MapboxStyles.MAPBOX_STREETS,
                  initialLocation: ll.LatLng(-6.2000, 106.8167),
                  markers: cctvPositions,
                  markerData: markerData,
                  userLocation: null,
                  routePoints: null,
                ),
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

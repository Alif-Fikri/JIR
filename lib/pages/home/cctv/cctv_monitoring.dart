import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:smartcitys/pages/home/cctv/cctv_webview.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartcitys/helper/map.dart';
import 'package:google_fonts/google_fonts.dart';

class CCTVPage extends StatelessWidget {
  final List<CCTVLocation> cctvLocations = [
    CCTVLocation(
      name: "DPR",
      url:
          "https://cctv.balitower.co.id/Bendungan-Hilir-003-700014_1/embed.html",
      coordinates: LatLng(-6.2096, 106.8005), // Koordinat DPR
    ),
    CCTVLocation(
      name: "Bundaran HI",
      url: "https://cctv.balitower.co.id/Menteng-001-700123_5/embed.html",
      coordinates: LatLng(-6.1945, 106.8229),
    ),
    CCTVLocation(
      name: "Monas",
      url: "https://cctv.balitower.co.id/Monas-Barat-009-506632_2/embed.html",
      coordinates: LatLng(-6.1754, 106.8273),
    ),
    CCTVLocation(
      name: "Patung Kuda",
      url: "https://cctv.balitower.co.id/JPO-Merdeka-Barat-507357_9/embed.html",
      coordinates: LatLng(-6.1715, 106.8343),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cctvMarkers = cctvLocations.map((location) {
      return Marker(
        point: location.coordinates,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _navigateToCCTV(context, location.url),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF45557B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.videocam, color: Colors.white, size: 20),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("CCTV",
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        backgroundColor: const Color(0xFF45557B),
        elevation: 10,
        shadowColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
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
                markers: cctvMarkers,
                userLocation: null,
                destination: null,
                routePoints: null,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Ayo Pantau !",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.bold)),
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
      padding: EdgeInsets.symmetric(horizontal: 15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: cctvLocations.length,
      itemBuilder: (context, index) {
        final location = cctvLocations[index];
        return GestureDetector(
          onTap: () => _navigateToCCTV(context, location.url),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/${location.name.toLowerCase().replaceAll(' ', '_')}.jpg",
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(location.name, style: GoogleFonts.inter(fontSize: 14)),
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

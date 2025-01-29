import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:smartcitys/pages/home/flood/flood_item_data.dart';

class FloodMonitoringPage extends StatefulWidget {
  @override
  _FloodMonitoringPageState createState() => _FloodMonitoringPageState();
}

class _FloodMonitoringPageState extends State<FloodMonitoringPage> {
  LatLng? currentLocation;
  final MapController _mapController = MapController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(currentLocation!, 15.0);
    });
  }

  Future<void> _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        LatLng searchedLocation = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _mapController.move(searchedLocation, 15.0);
        });
      }
    } catch (e) {
      print("Lokasi tidak ditemukan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi tidak ditemukan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banjir'),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        backgroundColor: Color(0xff45557B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? LatLng(-6.200000, 106.816666),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search . . .',
                        hintStyle: GoogleFonts.inter(
                            color: Colors.black, fontStyle: FontStyle.italic),
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  mini: true,
                  child: Icon(Icons.my_location, color: Colors.black),
                ),
              ],
            ),
          ),
          FloodInfoBottomSheet(
            status: "Siaga",
            statusIconPath: "assets/images/siaga.png",
            waterHeight: 500,
            waterIconPath: "assets/images/ketinggian.png",
            location: "Jakarta",
            locationIconPath: "assets/images/lokasi.png",
          ),
        ],
      ),
    );
  }
}

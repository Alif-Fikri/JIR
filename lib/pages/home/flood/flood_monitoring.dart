import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:smartcitys/pages/home/flood/flood_item_data.dart';
import 'package:smartcitys/services/flood_service/flood_service.dart';

class FloodMonitoringPage extends StatefulWidget {
  @override
  _FloodMonitoringPageState createState() => _FloodMonitoringPageState();
}

class _FloodMonitoringPageState extends State<FloodMonitoringPage> {
  LatLng? currentLocation;
  final MapController _mapController = MapController();
  TextEditingController _searchController = TextEditingController();
  List<Marker> _floodMarkers = [];
  List<Map<String, dynamic>> floodData = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchFloodData();
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

  Future<void> _fetchFloodData() async {
    try {
      final service = FloodService();
      final data = await service.fetchFloodData();

      setState(() {
        floodData = data;
        _floodMarkers = floodData.map((item) {
          double lat = double.tryParse(item["LATITUDE"].toString()) ?? 0.0;
          double lng = double.tryParse(item["LONGITUDE"].toString()) ?? 0.0;
          String status = item["STATUS_SIAGA"] ?? "Unknown";

          return Marker(
            point: LatLng(lat, lng),
            child: Icon(
              Icons.location_on,
              color: status == "Siaga" ? Colors.red : Colors.orange,
              size: 40,
            ),
          );
        }).toList();
      });
    } catch (e) {
      print("Error fetching flood data: $e");
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
              MarkerLayer(
                markers: _floodMarkers,
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
            status:
                floodData.isNotEmpty ? floodData[0]["STATUS_SIAGA"] : "Unknown",
            statusIconPath: "assets/images/siaga.png",
            waterHeight: floodData.isNotEmpty
                ? int.tryParse(floodData[0]["TINGGI_AIR"].toString()) ?? 0
                : 0,
            waterIconPath: "assets/images/ketinggian.png",
            location:
                floodData.isNotEmpty ? floodData[0]["NAMA_PINTU_AIR"] : "N/A",
            locationIconPath: "assets/images/lokasi.png",
            floodData: floodData,
          ),
        ],
      ),
    );
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
}

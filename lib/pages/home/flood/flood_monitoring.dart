import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:smartcitys/helper/radar_map.dart';
import 'package:smartcitys/pages/home/flood/flood_item_data.dart';
import 'package:smartcitys/services/flood_service/flood_api_service.dart';
import 'package:smartcitys/helper/map.dart';
import 'package:smartcitys/services/location_service/location_permission.dart';
import 'package:latlong2/latlong.dart';

class FloodMonitoringPage extends StatefulWidget {
  const FloodMonitoringPage({super.key});

  @override
  _FloodMonitoringPageState createState() => _FloodMonitoringPageState();
}

class _FloodMonitoringPageState extends State<FloodMonitoringPage> {
  LatLng? currentLocation;
  final TextEditingController _searchController = TextEditingController();
  List<Marker> _floodMarkers = [];
  List<Map<String, dynamic>> floodData = [];
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchFloodData();
  }

  Future<void> _initializeLocation() async {
    final location = await LocationService.getCurrentLocation();
    setState(() {
      currentLocation = location ?? const LatLng(-6.200000, 106.816666);
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

          return Marker(
            point: LatLng(lat, lng),
            child: GestureDetector(
              onTap: () {
                _showFloodInfoBottomSheet(
                  status: item["STATUS_SIAGA"] ?? "Unknown",
                  waterHeight: int.tryParse(item["TINGGI_AIR"].toString()) ?? 0,
                  location: item["NAMA_PINTU_AIR"] ?? "N/A",
                );
              },
              child: const RadarMarker(color: Colors.red),
            ),
          );
        }).toList();
      });
    } catch (e) {
      print("Error fetching flood data: $e");
    }
  }

  void _showFloodInfoBottomSheet({
    required String status,
    required int waterHeight,
    required String location,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FloodInfoBottomSheet(
          status: status,
          statusIconPath: "assets/images/siaga.png",
          waterHeight: waterHeight,
          waterIconPath: "assets/images/ketinggian.png",
          location: location,
          locationIconPath: "assets/images/lokasi.png",
          floodData: floodData,
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (location != null) {
      _mapController.move(location, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banjir'),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (currentLocation != null)
            ReusableMap(
              initialLocation: currentLocation!,
              markers: _floodMarkers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
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
                      boxShadow: const [
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
                        prefixIcon: const Icon(Icons.search, color: Colors.black),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
              ],
            ),
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
        _mapController.move(searchedLocation, 15.0);
      }
    } catch (e) {
      print("Lokasi tidak ditemukan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi tidak ditemukan')),
      );
    }
  }
}

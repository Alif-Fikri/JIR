import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/helper/map.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/services/flood_service/flood_api_service.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class MapMonitoring extends StatefulWidget {
  const MapMonitoring({super.key});

  @override
  State<MapMonitoring> createState() => _MapMonitoringState();
}

class _MapMonitoringState extends State<MapMonitoring> {
  final FloodService _floodService = FloodService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _floodData = [];
  List<LatLng> _routePoints = [];
  LatLng? _userLocation;
  LatLng? _destination;

  @override
  void initState() {
    super.initState();
    _loadFloodData();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _searchLocation(String query) async {
    String url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json";
    try {
      dio.Response response = await Dio().get(url);
      if (response.data.isNotEmpty) {
        double lat = double.parse(response.data[0]["lat"]);
        double lon = double.parse(response.data[0]["lon"]);
        setState(() {
          _destination = LatLng(lat, lon);
        });
        _fetchRoute();
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _fetchRoute() async {
    if (_userLocation == null || _destination == null) return;

    String url =
        "http://router.project-osrm.org/route/v1/driving/${_userLocation!.longitude},${_userLocation!.latitude};${_destination!.longitude},${_destination!.latitude}?overview=simplified&geometries=geojson";

    try {
      dio.Response response = await Dio().get(url);
      List coordinates = response.data["routes"][0]["geometry"]["coordinates"];
      setState(() {
        _routePoints =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
      });
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  Future<void> _loadFloodData() async {
    final data = await _floodService.fetchFloodData();

    // Perbaiki cara membersihkan "Status: "
    final cleanedData = data.map((item) {
      return {
        ...item,
        "STATUS_SIAGA": item["STATUS_SIAGA"]
            .toString()
            .replaceAll(RegExp(r"Status\s*:\s*"), ""),
      };
    }).toList();

    print("Data API setelah dibersihkan: $cleanedData"); // Debugging

    setState(() {
      _floodData = cleanedData;
    });

    if (mounted && _floodData.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFloodMonitoringBottomSheet(context);
      });
    }
  }

  void _showFloodMonitoringBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.2,
          maxChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return FloodMonitoringBottomSheet(
              floodData: _floodData,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = _floodData.map((item) {
      final latitude = double.tryParse(item['LATITUDE'].toString()) ?? 0.0;
      final longitude = double.tryParse(item['LONGITUDE'].toString()) ?? 0.0;
      return Marker(
        point: LatLng(latitude, longitude),
        child: GestureDetector(
          onTap: () => _showDisasterDetails(context, item),
          child: Icon(Icons.radio_button_checked, color: Colors.red, size: 30),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Peta',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: _userLocation ?? const LatLng(-6.2088, 106.8456),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      child: const Icon(Icons.person_pin_circle,
                          color: Colors.blue, size: 40),
                    ),
                  ],
                ),
              if (_destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _destination!,
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 40),
                    ),
                  ],
                ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
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
                        hintText: 'Masukkan tujuan...',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.black,
                          fontStyle: FontStyle.italic,
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.black),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: () {
                            _searchLocation(_searchController.text);
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDisasterDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DisasterBottomSheet(
        location: item['NAMA_PINTU_AIR'] ?? 'Lokasi Tidak Diketahui',
        status: item['STATUS_SIAGA'] ?? 'N/A',
        onViewLocation: () => _navigateToFloodMonitoring(context, item),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _navigateToFloodMonitoring(
      BuildContext context, Map<String, dynamic> item) {
    final latStr = item['LATITUDE'].toString();
    final lngStr = item['LONGITUDE'].toString();

    final latitude = double.tryParse(latStr);
    final longitude = double.tryParse(lngStr);

    if (latitude == null || longitude == null) {
      Get.snackbar("Error", "Koordinat tidak valid: ($latStr, $lngStr)");
      return;
    }

    Get.to(() => FloodMonitoringPage(
          initialLocation: LatLng(latitude, longitude),
        ));
  }
}

class DisasterBottomSheet extends StatelessWidget {
  final String location;
  final String status;
  final VoidCallback onViewLocation;

  const DisasterBottomSheet({
    super.key,
    required this.location,
    required this.status,
    required this.onViewLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
          Text('Detail Lokasi',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.location_on,
            label: 'Lokasi',
            value: location,
          ),
          _DetailRow(
            icon: Icons.warning,
            label: 'Status Siaga',
            value: status,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF45557B),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Lihat Lokasi di Peta',
                  style: GoogleFonts.inter(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF45557B), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class FloodMonitoringBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> floodData;
  final ScrollController scrollController;

  const FloodMonitoringBottomSheet({
    Key? key,
    required this.floodData,
    required this.scrollController,
  }) : super(key: key);

  @override
  _FloodMonitoringBottomSheetState createState() =>
      _FloodMonitoringBottomSheetState();
}

class _FloodMonitoringBottomSheetState
    extends State<FloodMonitoringBottomSheet> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    // Dibataskan jumlah data yang ditampilkan jika showAll = false
    List<Map<String, dynamic>> displayedData = showAll
        ? widget.floodData
        : widget.floodData.take(5).toList(); // Tampilkan hanya 5 pertama

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Pantauan Hari Ini",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff45557B)),
            ),
          ),
          const SizedBox(height: 10),
          Text('Daftar Banjir',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff45557B))),
          const Divider(),
          // Daftar banjir dengan bullet warna
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: displayedData.length,
              itemBuilder: (context, index) {
                final item = displayedData[index];
                return ListTile(
                  title:
                      Text(item["NAMA_PINTU_AIR"] ?? "Lokasi Tidak Diketahui"),
                  titleTextStyle: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                  trailing: _statusIndicator(item["STATUS_SIAGA"] ?? "N/A"),
                  leadingAndTrailingTextStyle: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  onTap: () {
                    final latitude =
                        double.tryParse(item['LATITUDE'].toString()) ?? 0.0;
                    final longitude =
                        double.tryParse(item['LONGITUDE'].toString()) ?? 0.0;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FloodMonitoringPage(
                          initialLocation: LatLng(latitude, longitude),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (!showAll)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAll = true;
                  });
                },
                child: Text(
                  "Selengkapnya",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, color: Color(0xff45557B)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Bullet indikator siaga
  Widget _statusIndicator(String status) {
    String cleanedStatus = status.replaceAll("Status: ", "");

    Color statusColor;
    switch (cleanedStatus) {
      case "Siaga 3":
        statusColor = Colors.red;
        break;
      case "Siaga 2":
        statusColor = Colors.orange;
        break;
      case "Siaga 1":
        statusColor = Colors.orange;
        break;
      case "Sedang":
        statusColor = Colors.orange;
        break;
      case "Normal":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: statusColor, size: 11),
        const SizedBox(width: 5),
        Text(cleanedStatus,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

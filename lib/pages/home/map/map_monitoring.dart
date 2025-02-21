import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/helper/map.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/pages/home/map/detail_flood.dart';
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
  List<Map<String, dynamic>> _searchSuggestions = [];
  List<Map<String, dynamic>> _routeSteps = [];
  LatLng? _userLocation;
  LatLng? _destination;
  Timer? _debounceTimer;
  bool _showRouteInstructions = false;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _loadFloodData();
    _getUserLocation();
    _startLocationUpdates();
  }

  // Method saran lokasi
  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _searchSuggestions = []);
      return;
    }

    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1";
    try {
      final response = await Dio().get(url);
      setState(() {
        _searchSuggestions = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  Widget _buildSearchSuggestions() {
    return Visibility(
      visible: _searchSuggestions.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(top: 70, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: _searchSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _searchSuggestions[index];
            return ListTile(
              leading: const Icon(Icons.location_on, size: 20),
              title: Text(suggestion['display_name'] ?? 'Unknown location'),
              onTap: () {
                final lat = double.parse(suggestion['lat']);
                final lon = double.parse(suggestion['lon']);
                setState(() {
                  _destination = LatLng(lat, lon);
                  _searchController.text = suggestion['display_name'];
                  _searchSuggestions = [];
                });
                _fetchRoute();
              },
            );
          },
        ),
      ),
    );
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

    String url = "http://router.project-osrm.org/route/v1/driving/"
        "${_userLocation!.longitude},${_userLocation!.latitude};"
        "${_destination!.longitude},${_destination!.latitude}"
        "?overview=full&steps=true&geometries=geojson";

    try {
      final response = await Dio().get(url);
      final data = response.data;

      List coordinates = data["routes"][0]["geometry"]["coordinates"];
      List<LatLng> newRoutePoints =
          coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

      List<Map<String, dynamic>> steps = [];
      final legs = data["routes"][0]["legs"];
      if (legs != null && legs.isNotEmpty) {
        final leg = legs[0];
        steps = List<Map<String, dynamic>>.from(leg["steps"].map((step) {
          return {
            'instruction': step['maneuver']['instruction'],
            'name': step['name'],
            'distance': step['distance'],
          };
        }));
      }

      setState(() {
        _routePoints = newRoutePoints;
        _routeSteps = steps;
        _showRouteInstructions = true;
      });

      _showRouteInstructionsBottomSheet(context);
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  Future<void> _loadFloodData() async {
    final data = await _floodService.fetchFloodData();

    // clean "Status: "
    final cleanedData = data.map((item) {
      return {
        ...item,
        "STATUS_SIAGA": item["STATUS_SIAGA"]
            .toString()
            .replaceAll(RegExp(r"Status\s*:\s*"), ""),
      };
    }).toList();

    print("Data API setelah dibersihkan: $cleanedData");

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

  void _showRouteInstructionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Petunjuk Arah",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchRoute,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _routeSteps.length,
                  itemBuilder: (context, index) {
                    final step = _routeSteps[index];
                    return ListTile(
                      leading: const Icon(Icons.directions),
                      title: Text(
                        step['instruction']
                            .toString()
                            .replaceAll(RegExp(r'<[^>]*>'), ''),
                      ),
                      subtitle: Text(
                        "Jalan: ${step['name'] ?? 'Tidak diketahui'}\n"
                        "Jarak: ${(step['distance'] as num).toStringAsFixed(0)} meter",
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
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
          ReusableMap(
            initialLocation: const LatLng(-6.2088, 106.8456), // Default Jakarta
            markers: markers,
            userLocation: _userLocation,
            destination: _destination,
            routePoints: _routePoints,
          ),

          // Search Bar dan Suggestions
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
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
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchSuggestions = []);
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (query) {
                            if (_debounceTimer?.isActive ?? false) {
                              _debounceTimer!.cancel();
                            }
                            _debounceTimer =
                                Timer(const Duration(milliseconds: 500), () {
                              _fetchSearchSuggestions(query);
                            });
                          },
                          onSubmitted: (query) => _searchLocation(query),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildSearchSuggestions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _floodData = [];
  List<LatLng> _routePoints = [];
  List<Map<String, dynamic>> _searchSuggestions = [];
  List<Map<String, dynamic>> _routeSteps = [];
  LatLng? _userLocation;
  LatLng? _destination;
  LatLng? _currentUserLocation;
  Timer? _debounceTimer;
  bool _showRouteInstructions = false;
  bool _isRouteVisible = false;
  StreamSubscription<Position>? _positionStream;
  String _selectedVehicle = 'motorcycle';

  @override
  void initState() {
    super.initState();
    _loadFloodData();
    _getUserLocation();
    _startLocationUpdates();
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _searchSuggestions = []);
      return;
    }
    print("Memulai pencarian: $query");

    String url = "https://nominatim.openstreetmap.org/search?q=$query"
        "&format=json&addressdetails=1"
        "&countrycodes=id"
        "&bounded=1&viewbox=106.4,-6.4,107.0,-6.0"; // Batasan area Jakarta (west, south, east, north)
    try {
      final response = await Dio().get(url);
      print("Response API: ${response.statusCode}");
      print("Data API: ${response.data}");

      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(response.data);
      print("Jumlah hasil mentah: ${results.length}");

      if (_currentUserLocation != null) {
        results.sort((a, b) {
          final distA = _calculateDistance(_currentUserLocation!,
              LatLng(double.parse(a['lat']), double.parse(a['lon'])));
          final distB = _calculateDistance(_currentUserLocation!,
              LatLng(double.parse(b['lat']), double.parse(b['lon'])));
          return distA.compareTo(distB);
        });
      }

      setState(() {
        _searchSuggestions = results.take(5).toList();
        print("Hasil setelah sorting: $_searchSuggestions");
      });
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  // Method hitung jarak
  double _calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance(start, end);
  }

  Widget _buildSearchSuggestions() {
    return Visibility(
      visible: _searchSuggestions.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 2),
              )
            ]),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: _searchSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _searchSuggestions[index];
            try {
              final lat = double.tryParse(suggestion['lat']?.toString() ?? '');
              final lon = double.tryParse(suggestion['lon']?.toString() ?? '');
              if (lat == null || lon == null) {
                throw FormatException("Invalid coordinate format");
              }
              double? distanceKm;
              if (_currentUserLocation != null) {
                distanceKm = _calculateDistance(
                      _currentUserLocation!,
                      LatLng(lat, lon),
                    ) /
                    1000;
              }
              return ListTile(
                leading: const Icon(Icons.location_on, size: 20),
                title: Text(suggestion['display_name'] ?? 'Lokasi'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (distanceKm != null)
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km dari lokasi Anda',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    Text(
                      _getLocationType(suggestion['type']),
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _destination = LatLng(lat, lon);
                    _searchController.text = suggestion['display_name'];
                    _searchSuggestions = [];
                  });
                  _fetchRoute();
                },
              );
            } catch (e) {
              print("Error parsing suggestion: $e");
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

// Helper method untuk tipe lokasi
  String _getLocationType(String type) {
    const typeTranslations = {
      'administrative': 'Wilayah Administratif',
      'city': 'Kota',
      'village': 'Desa',
      'road': 'Jalan',
      'shop': 'Toko',
      'amenity': 'Fasilitas Umum',
    };
    return typeTranslations[type] ?? 'Lokasi Umum';
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      print("Lokasi pengguna: ${position.latitude}, ${position.longitude}");

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _currentUserLocation = _userLocation;
        });
      }
    } catch (e) {
      print("Error mendapatkan lokasi: $e");
      Get.snackbar("Peringatan", "Tidak bisa mendapatkan lokasi saat ini",
          backgroundColor: Colors.orange);
    }
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

    setState(() {
      _routePoints = [];
      _routeSteps = [];
    });

    try {
      final profile = _selectedVehicle == 'motorcycle' ? 'bike' : 'car';
      final url = "http://router.project-osrm.org/route/v1/$profile/"
          "${_userLocation!.longitude},${_userLocation!.latitude};"
          "${_destination!.longitude},${_destination!.latitude}"
          "?overview=full&steps=true&geometries=geojson";

      final response = await Dio().get(url);

      if (response.statusCode != 200) {
        throw Exception('Gagal mendapatkan rute');
      }

      final data = response.data;

      // 3. Validasi respons API
      if (data['routes'] == null || data['routes'].isEmpty) {
        throw Exception('Tidak ada rute ditemukan');
      }

      List coordinates = data["routes"][0]["geometry"]["coordinates"];
      List<LatLng> newRoutePoints =
          coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

      List<Map<String, dynamic>> steps = [];
      final legs = data["routes"][0]["legs"];
      if (legs != null && legs.isNotEmpty) {
        final leg = legs[0];
        steps = List<Map<String, dynamic>>.from(leg["steps"].map((step) {
          final maneuver = step['maneuver'];
          final instruction = _parseManeuver(maneuver);
          final roadName = step['name'] ?? 'Jalan tanpa nama';

          return {
            'instruction': instruction,
            'name': roadName,
            'distance': step['distance'],
            'type': maneuver?['type'],
            'modifier': maneuver?['modifier'],
          };
        }));
      }
      if (mounted) {
        setState(() {
          _routePoints = _parseRoutePoints(data);
          _routeSteps = _parseRouteSteps(data);
          _showRouteInstructions = true;
          _isRouteVisible = true;
        });
      }

      _showRouteInstructionsBottomSheet(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isRouteVisible = false);
      }
      Get.snackbar("Error", "Tidak dapat menampilkan rute untuk kendaraan ini",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  List<LatLng> _parseRoutePoints(Map<String, dynamic> data) {
    try {
      return (data['routes'][0]['geometry']['coordinates'] as List)
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } catch (e) {
      throw Exception('Format data koordinat tidak valid');
    }
  }

  List<Map<String, dynamic>> _parseRouteSteps(Map<String, dynamic> data) {
    try {
      final leg = data['routes'][0]['legs'][0];
      return List<Map<String, dynamic>>.from(leg["steps"].map((step) {
        final maneuver = step['maneuver'];
        return {
          'instruction': _parseManeuver(maneuver),
          'name': step['name'] ?? 'Jalan',
          'distance': step['distance'] ?? 0,
          'exit': maneuver?['exit'],
        };
      }));
    } catch (e) {
      throw Exception('Format data petunjuk tidak valid');
    }
  }

  String _parseManeuver(Map<String, dynamic>? maneuver) {
    if (maneuver == null) return 'Lanjutkan perjalanan';

    final type = maneuver['type'];
    final modifier = maneuver['modifier'];
    final exit = maneuver['keluar'];
    final roadName = maneuver['name'] ?? '';

    // Fungsi konversi angka ke urutan (1 -> pertama, 2 -> kedua, dst)
    String _exitIndonesian(int? exitNum) {
      if (exitNum == null) return '';
      switch (exitNum) {
        case 1:
          return 'pertama';
        case 2:
          return 'kedua';
        case 3:
          return 'ketiga';
        case 4:
          return 'keempat';
        default:
          return 'ke-$exitNum';
      }
    }

    switch (type) {
      case 'depart':
        return 'Mulai perjalanan dari lokasi ini';
      case 'arrive':
        return 'Anda telah tiba di tujuan';
      case 'turn':
        switch (modifier) {
          case 'left':
            return 'Belok ke kiri';
          case 'right':
            return 'Belok ke kanan';
          case 'sharp left':
            return 'Belok tajam ke kiri';
          case 'sharp right':
            return 'Belok tajam ke kanan';
          case 'slight left':
            return 'Belok pelan ke kiri';
          case 'slight right':
            return 'Belok pelan ke kanan';
          default:
            return 'Belok';
        }
      case 'new name':
        return 'Teruskan lurus menuju $roadName';
      case 'roundabout':
        return 'Masuk bundaran dan ambil keluar ${_exitIndonesian(exit)}';
      case 'rotary':
        return 'Masuk lingkaran lalu keluar di keluar ${_exitIndonesian(exit)}';
      case 'fork':
        return 'Ambil percabangan ${_translateModifier(modifier)}';
      case 'merge':
        return 'Bergabung ke jalur ${_translateModifier(modifier)}';
      case 'on ramp':
        return 'Masuk jalan tol ${_translateModifier(modifier)}';
      case 'off ramp':
        return 'Keluar melalui jalan tol ${_translateModifier(modifier)}';
      default:
        return 'Teruskan mengikuti jalan';
    }
  }

  String _translateModifier(String? modifier) {
    switch (modifier) {
      case 'left':
        return 'sebelah kiri';
      case 'right':
        return 'sebelah kanan';
      case 'straight':
        return 'lurus';
      case 'slight left':
        return 'sedikit ke kiri';
      case 'slight right':
        return 'sedikit ke kanan';
      default:
        return '';
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
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Petunjuk Arah",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _VehicleOption(
                        icon: Icons.motorcycle,
                        label: "Motor",
                        isSelected: _selectedVehicle == 'motorcycle',
                        onTap: () async {
                          setSheetState(() {});
                          await _updateVehicle('motorcycle', setSheetState);
                        },
                      ),
                      _VehicleOption(
                        icon: Icons.directions_car,
                        label: "Mobil",
                        isSelected: _selectedVehicle == 'car',
                        onTap: () async {
                          setSheetState(() {});
                          await _updateVehicle('car', setSheetState);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: _routeFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }
                        return _buildRouteList();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRouteList() {
    return ListView.separated(
      itemCount: _routeSteps.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final step = _routeSteps[index];
        return ListTile(
          leading: _getManeuverIcon(step['type'], step['modifier']),
          title: Text(
            step['instruction'],
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jalan: ${step['name']}",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                _formatDistance(step['distance']),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateVehicle(String vehicle, StateSetter setSheetState) async {
    setSheetState(() {
      _selectedVehicle = vehicle;
      _routeFuture = _fetchRoute();
    });

    try {
      await _routeFuture;
    } catch (e) {
      Get.snackbar("Gagal", "Tidak dapat memperbarui rute");
    }
  }

  Widget _getManeuverIcon(String? type, String? modifier) {
    const defaultIcon = Icon(Icons.directions, color: Colors.blue);

    switch (type) {
      case 'turn':
        switch (modifier) {
          case 'left':
            return const Icon(Icons.turn_left, color: Colors.blue);
          case 'right':
            return const Icon(Icons.turn_right, color: Colors.blue);
          case 'sharp left':
            return const Icon(Icons.u_turn_left, color: Colors.blue);
          case 'sharp right':
            return const Icon(Icons.u_turn_right, color: Colors.blue);
          default:
            return defaultIcon;
        }
      case 'roundabout':
        return const Icon(Icons.alt_route, color: Colors.orange);
      case 'depart':
        return const Icon(Icons.location_on, color: Colors.green);
      case 'arrive':
        return const Icon(Icons.flag, color: Colors.red);
      case 'fork':
        return Transform.rotate(
          angle: modifier == 'left' ? 0.3 : -0.3,
          child: const Icon(Icons.fork_left, color: Colors.blue),
        );
      default:
        return defaultIcon;
    }
  }

  String _exitIndonesian(dynamic exitNum) {
    if (exitNum == null) return '';
    final number = int.tryParse(exitNum.toString()) ?? 0;

    if (number == 0) return '';

    switch (number) {
      case 1:
        return 'pertama';
      case 2:
        return 'kedua';
      case 3:
        return 'ketiga';
      case 4:
        return 'keempat';
      default:
        return 'ke-$number';
    }
  }

  String _formatDistance(num distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} meter'; // 850 -> 850 meter
    }
    return '${(distance / 1000).toStringAsFixed(1)} km'; // 1250 -> 1.3 km
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
                                Timer(const Duration(milliseconds: 300), () {
                              if (query.isNotEmpty) {
                                _fetchSearchSuggestions(query);
                              } else {
                                setState(() => _searchSuggestions = []);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                _buildSearchSuggestions(),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Visibility(
              visible: _routeSteps.isNotEmpty,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.directions, color: Colors.white),
                onPressed: () {
                  if (_routeSteps.isNotEmpty) {
                    _showRouteInstructionsBottomSheet(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

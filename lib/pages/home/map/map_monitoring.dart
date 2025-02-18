import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/services/flood_service/flood_api_service.dart';

class MapMonitoring extends StatefulWidget {
  const MapMonitoring({super.key});

  @override
  State<MapMonitoring> createState() => _MapMonitoringState();
}

class _MapMonitoringState extends State<MapMonitoring> {
  final FloodService _floodService = FloodService();
  List<Map<String, dynamic>> _floodData = [];

  @override
  void initState() {
    super.initState();
    _loadFloodData();
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
          initialChildSize: 0.4,
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
        title: Text('Pantau Banjir',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF45557B),
      ),
      body: ReusableMap(
        initialLocation: LatLng(-6.2088, 106.8456), // Default Jakarta
        markers: markers,
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
    final latitude = double.tryParse(item['LATITUDE'].toString()) ?? 0.0;
    final longitude = double.tryParse(item['LONGITUDE'].toString()) ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloodMonitoringPage(
          initialLocation: LatLng(latitude, longitude),
        ),
      ),
    );
  }
}

class ReusableMap extends StatefulWidget {
  final LatLng initialLocation;
  final List<Marker> markers;

  const ReusableMap(
      {super.key, required this.initialLocation, required this.markers});

  @override
  _ReusableMapState createState() => _ReusableMapState();
}

class _ReusableMapState extends State<ReusableMap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialLocation,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: widget.markers),
      ],
    );
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          const SizedBox(height: 10),

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
                  trailing: _statusIndicator(item["STATUS_SIAGA"] ?? "N/A"),
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
                child: const Text(
                  "Selengkapnya",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
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

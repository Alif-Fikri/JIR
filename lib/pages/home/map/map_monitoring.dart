import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
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
    setState(() => _floodData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantau Bencana',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF45557B),
      ),
      body: _buildDisasterList(),
    );
  }

  Widget _buildDisasterList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _floodData.length,
      itemBuilder: (context, index) {
        final item = _floodData[index];
        return _DisasterListItem(
          location: item['NAMA_PINTU_AIR'] ?? 'Lokasi Tidak Diketahui',
          status: item['STATUS_SIAGA'] ?? 'N/A',
          latitude: double.tryParse(item['LATITUDE'].toString()) ?? 0.0,
          longitude: double.tryParse(item['LONGITUDE'].toString()) ?? 0.0,
        );
      },
    );
  }
}

class _DisasterListItem extends StatelessWidget {
  final String location;
  final String status;
  final double latitude;
  final double longitude;

  const _DisasterListItem({
    required this.location,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _StatusIndicator(status: status),
        title: Text(location,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        subtitle: Text('Status: $status',
            style: GoogleFonts.inter(color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showDisasterDetails(context),
      ),
    );
  }

  void _showDisasterDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DisasterBottomSheet(
        location: location,
        status: status,
        onViewLocation: () => _navigateToFloodMonitoring(context),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _navigateToFloodMonitoring(BuildContext context) {
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

class _StatusIndicator extends StatelessWidget {
  final String status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    switch (status.toLowerCase()) {
      case 'siaga':
        indicatorColor = Colors.orange;
        break;
      case 'sedang':
        indicatorColor = Colors.yellow;
        break;
      case 'normal':
        indicatorColor = Colors.green;
        break;
      default:
        indicatorColor = Colors.grey;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
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
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.bold)),
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
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey[600])),
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
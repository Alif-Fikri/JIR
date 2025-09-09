import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:JIR/pages/home/flood/view/flood_monitoring.dart';

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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Sedang':
        return Colors.yellow[700]!;
      case 'Siaga 1':
        return Colors.orange[700]!;
      case 'Siaga 2':
        return Colors.orange[700]!;
      case 'Siaga 3':
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Normal':
        return 'Normal (Aman)';
      case 'Sedang':
        return 'Sedang (Aman)';
      case 'Siaga 1':
        return 'Siaga 1 (Waspada)';
      case 'Siaga 2':
        return 'Siaga 2 (Bahaya)';
      case 'Siaga 3':
        return 'Siaga 3 (Darurat)';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
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
            Text('Detail Lokasi Banjir',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF45557B))),
            const SizedBox(height: 16),
            DetailRow(
              icon: Icons.location_on,
              iconColor: const Color(0xFF45557B),
              label: 'Lokasi',
              value: location,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Siaga',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700])),
                        Text(statusText,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statusColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF45557B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text('Lihat Lokasi di Peta',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.icon,
    this.iconColor = Colors.grey,
    required this.label,
    required this.value,
  });
   
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700])),
              const SizedBox(height: 4),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}

class FloodMonitoringBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> floodData;
  final ScrollController scrollController;

  const FloodMonitoringBottomSheet({
    super.key,
    required this.floodData,
    required this.scrollController,
  });

  @override
  _FloodMonitoringBottomSheetState createState() =>
      _FloodMonitoringBottomSheetState();
}

class _FloodMonitoringBottomSheetState
    extends State<FloodMonitoringBottomSheet> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedData =
        showAll ? widget.floodData : widget.floodData.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
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
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff45557B)),
                ),
              ),
            ),
        ],
      ),
    );
  }

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

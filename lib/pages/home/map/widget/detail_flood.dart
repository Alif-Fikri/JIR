import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartcitys/pages/home/flood/view/flood_monitoring.dart';

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
          DetailRow(
            icon: Icons.location_on,
            label: 'Lokasi',
            value: location,
          ),
          DetailRow(
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

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow({super.key, 
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
    // Dibataskan jumlah data yang ditampilkan jika showAll = false
    List<Map<String, dynamic>> displayedData = showAll
        ? widget.floodData
        : widget.floodData.take(5).toList(); // Tampilkan hanya 5 pertama

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
                      fontWeight: FontWeight.bold, color: const Color(0xff45557B)),
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

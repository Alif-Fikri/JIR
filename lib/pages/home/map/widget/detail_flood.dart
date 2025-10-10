import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/map/controller/flood_controller.dart';

enum _FloodStatusLevel { normal, caution, alert, danger, unknown }

class _FloodStatusHelper {
  static _FloodStatusLevel classify(String rawStatus) {
    final cleaned = rawStatus
        .replaceAll(RegExp(r'status\s*:?', caseSensitive: false), '')
        .trim()
        .toLowerCase();
    if (cleaned.isEmpty || cleaned == 'n/a') {
      return _FloodStatusLevel.normal;
    }
    if (_containsAny(cleaned, ['siaga 1', 'merah', 'bahaya'])) {
      return _FloodStatusLevel.danger;
    }
    if (_containsAny(cleaned, ['siaga 2', 'jingga', 'orange', 'sedang'])) {
      return _FloodStatusLevel.alert;
    }
    if (_containsAny(cleaned, ['siaga 3', 'kuning', 'yellow'])) {
      return _FloodStatusLevel.caution;
    }
    if (_containsAny(cleaned, ['normal', 'hijau', 'green', 'aman'])) {
      return _FloodStatusLevel.normal;
    }
    return _FloodStatusLevel.unknown;
  }

  static Color color(String rawStatus) {
    switch (classify(rawStatus)) {
      case _FloodStatusLevel.danger:
        return const Color(0xFFD32F2F);
      case _FloodStatusLevel.alert:
        return const Color(0xFFFF9800);
      case _FloodStatusLevel.caution:
        return const Color(0xFFFFC107);
      case _FloodStatusLevel.normal:
        return const Color(0xFF4CAF50);
      case _FloodStatusLevel.unknown:
        return const Color(0xFFE53935);
    }
  }

  static String detailLabel(String rawStatus) {
    switch (classify(rawStatus)) {
      case _FloodStatusLevel.danger:
        return 'Siaga 1 (Bahaya)';
      case _FloodStatusLevel.alert:
        return 'Siaga 2 (Siaga Tinggi)';
      case _FloodStatusLevel.caution:
        return 'Siaga 3 (Waspada)';
      case _FloodStatusLevel.normal:
        return 'Normal (Aman)';
      case _FloodStatusLevel.unknown:
        return 'Status Tidak Diketahui';
    }
  }

  static String shortLabel(String rawStatus) {
    switch (classify(rawStatus)) {
      case _FloodStatusLevel.danger:
        return 'Siaga 1';
      case _FloodStatusLevel.alert:
        return 'Siaga 2';
      case _FloodStatusLevel.caution:
        return 'Siaga 3';
      case _FloodStatusLevel.normal:
        return 'Normal';
      case _FloodStatusLevel.unknown:
        return 'Tidak Diketahui';
    }
  }

  static bool _containsAny(String source, List<String> keywords) {
    for (final keyword in keywords) {
      if (source.contains(keyword)) return true;
    }
    return false;
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
    final statusColor = _FloodStatusHelper.color(status);
    final statusText = _FloodStatusHelper.detailLabel(status);

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
                color: statusColor.withAlpha(26),
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
  State<FloodMonitoringBottomSheet> createState() =>
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
                    Navigator.pop(context);
                    final floodController = Get.find<FloodController>();
                    floodController.navigateToFloodMonitoring(
                      context,
                      item,
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
    final statusColor = _FloodStatusHelper.color(status);
    final displayText = _FloodStatusHelper.shortLabel(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: statusColor, size: 11),
        const SizedBox(width: 5),
        Text(displayText, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

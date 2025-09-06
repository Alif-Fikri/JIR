import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class FloodInfoBottomSheet extends StatelessWidget {
  final String status;
  final String statusIconPath;
  final int waterHeight;
  final String waterIconPath;
  final String location;
  final String locationIconPath;
  final List<Map<String, dynamic>> floodData;

  const FloodInfoBottomSheet({
    super.key,
    required this.status,
    required this.statusIconPath,
    required this.waterHeight,
    required this.waterIconPath,
    required this.location,
    required this.locationIconPath,
    required this.floodData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _infoItem(statusIconPath, status, 'Siaga'),
                  const SizedBox(width: 16),
                  _infoItem(waterIconPath, '$waterHeight cm', 'Tinggi Air'),
                  const SizedBox(width: 16),
                  _infoItem(locationIconPath, location, 'Lokasi'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildWaterLevelChart(),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String iconPath, String value, String label) {
    return Row(
      children: [
        Image.asset(iconPath, width: 39, height: 39),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xff355469),
                    fontWeight: FontWeight.bold)),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff355469))),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterLevelChart() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey, width: 1),
        color: const Color(0xffE7EEFD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xff45557B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                "Perubahan Ketinggian Air",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: GoogleFonts.inter(fontSize: 10),
                        ),
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: GoogleFonts.inter(fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade400, width: 0.5),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: floodData.isNotEmpty
                          ? floodData
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                  entry.key.toDouble(),
                                  double.tryParse(entry.value["TINGGI_AIR"]
                                          .toString()) ??
                                      0.0))
                              .toList()
                          : [const FlSpot(0, 0)],
                      isCurved: true,
                      color: const Color(0xff576A97),
                      belowBarData:
                           BarAreaData(show: true, color: const Color(0xff576A97)),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              child: Text(
                "* Tinggi air saat ini berada di $waterHeight cm, meningkat dibandingkan 2 jam terakhir.",
                style: GoogleFonts.inter(fontSize: 10, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

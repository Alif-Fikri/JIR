import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FloodInfoBottomSheet extends StatelessWidget {
  final String status;
  final String statusIconPath;
  final int waterHeight;
  final String waterIconPath;
  final String location;
  final String locationIconPath;

  FloodInfoBottomSheet({
    required this.status,
    required this.statusIconPath,
    required this.waterHeight,
    required this.waterIconPath,
    required this.location,
    required this.locationIconPath,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.1,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2)
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(height: 25),

                  // Info Status, Tinggi Air, Lokasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoItem(statusIconPath, status, 'Siaga'),
                      _infoItem(waterIconPath, '$waterHeight cm', 'Tinggi Air'),
                      _infoItem(locationIconPath, location, 'Lokasi'),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Grafik Perubahan Ketinggian Air
                  Text("Perubahan Ketinggian Air",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildWaterLevelChart(),

                  SizedBox(height: 10),
                  Text(
                    "* Tinggi air saat ini berada di $waterHeight cm, meningkat dibandingkan 2 jam terakhir.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget untuk menampilkan informasi Status, Tinggi Air, dan Lokasi
  Widget _infoItem(String iconPath, String value, String label) {
    return Row(
      children: [
        Image.asset(iconPath, width: 39, height: 39),
        SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff355469),
                    fontWeight: FontWeight.bold)),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff355469))),
          ],
        ),
      ],
    );
  }

  // Widget untuk menampilkan Grafik Perubahan Ketinggian Air
  Widget _buildWaterLevelChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) =>
                    Text('${value.toInt()} cm', style: TextStyle(fontSize: 10)),
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 100),
                FlSpot(1, 300),
                FlSpot(2, 600),
                FlSpot(3, 800),
                FlSpot(4, 400),
                FlSpot(5, 500),
                FlSpot(6, 700),
                FlSpot(7, 900),
                FlSpot(8, 1000),
              ],
              isCurved: true,
              color: Colors.blue,
              belowBarData:
                  BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

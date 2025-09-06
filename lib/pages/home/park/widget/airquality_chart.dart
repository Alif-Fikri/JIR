import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AirQualityChart extends StatelessWidget {
  const AirQualityChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
                maxY: 300,
                barGroups: _generateBarGroups(),
                borderData: FlBorderData(
                  border: const Border(
                    bottom: BorderSide(color: Colors.black, width: 1),
                    left: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % 50 == 0) {
                          return Text('${value.toInt()}',
                              style: GoogleFonts.inter(fontSize: 10));
                        }
                        return Container();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        DateTime now = DateTime.now();
                        DateFormat dateFormat = DateFormat('dd');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dateFormat.format(now
                                .subtract(Duration(days: 20 - value.toInt()))),
                            style: GoogleFonts.inter(
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.grey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                        rod.toY.toInt().toString(),
                        GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white));
                  },
                ))),
          ),
        ),
        const SizedBox(height: 10),
        _buildLegend(),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    Random random = Random();
    List<Color> colors = [
      const Color(0xff4F983E),
      const Color(0xffF9D94A),
      const Color(0xffF4A73D),
      const Color(0xffC2281C),
      Colors.black
    ];

    return List.generate(20, (index) {
      double value = random.nextDouble() * 300; 
      Color barColor = value < 50
          ? colors[0]
          : value < 100
              ? colors[1]
              : value < 150
                  ? colors[2]
                  : value < 200
                      ? colors[3]
                      : colors[4];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
              toY: value,
              color: barColor,
              width: 12.5,
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: Colors.black)),
        ],
      );
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem(const Color(0xff4F983E), "Baik"),
        _legendItem(const Color(0xffF9D94A), "Sedang"),
        _legendItem(const Color(0xffF4A73D), "Tidak Sehat"),
        _legendItem(const Color(0xffC2281C), "Sangat Tidak Sehat"),
        _legendItem(Colors.black, "Berbahaya"),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(text,
              style: GoogleFonts.inter(
                  fontSize: 6.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
        ],
      ),
    );
  }
}

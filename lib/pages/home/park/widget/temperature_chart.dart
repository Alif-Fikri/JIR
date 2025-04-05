import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TemperatureChart extends StatelessWidget {
  final double chartThickness;

  const TemperatureChart({super.key, this.chartThickness = 3.0});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
          minY: 10,
          maxY: 40,
          backgroundColor: Colors.white,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            border: const Border(
              left: BorderSide(color: Colors.black, width: 1),
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value % 10 == 0) {
                    return Text('${value.toInt()}°',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black));
                  }
                  return Container();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  DateTime now =
                      DateTime.now().add(Duration(hours: value.toInt()));
                  String hour = DateFormat('HH:00').format(now);
                  String day = DateFormat('EEEE', 'id_ID').format(now);

                  return Column(
                    children: [
                      Text(hour,
                          style: GoogleFonts.inter(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Text(day,
                              style: GoogleFonts.inter(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)),
                        ),
                      ),
                    ],
                  );
                },
                interval: 1,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _generateTemperatureData(),
              isCurved: false,
              color: Colors.blue[800],
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: _backgroundSections(),
          )),
    );
  }

  List<FlSpot> _generateTemperatureData() {
    List<double> temperatures = [
      30,
      35,
      28,
      32,
      27,
      33,
      29,
      31,
      26,
      30
    ]; // Data dummy
    return List.generate(10, (index) {
      return FlSpot(index.toDouble(), temperatures[index]);
    });
  }

  List<HorizontalLine> _backgroundSections() {
    return [
      HorizontalLine(
        y: 10,
        color: Colors.green.withOpacity(0.4),
        strokeWidth: 38,
      ),
      HorizontalLine(
        y: 18.6,
        color: Colors.orange.withOpacity(0.4),
        strokeWidth: 38,
      ),
      HorizontalLine(
        y: 27.3,
        color: Colors.red.withOpacity(0.4),
        strokeWidth: 38,
      ),
      HorizontalLine(
        y: 35.8,
        color: Colors.grey.withOpacity(0.4),
        strokeWidth: 38,
      ),
    ];
  }
}

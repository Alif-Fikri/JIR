import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PMTableWidget extends StatefulWidget {
  const PMTableWidget({super.key});

  @override
  State<PMTableWidget> createState() => _PMTableWidgetState();
}

class _PMTableWidgetState extends State<PMTableWidget> {
  bool _showTable = false; 

  List<Map<String, String>> _generatePMData() {
    List<Map<String, String>> data = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 10; i++) {
      DateTime time = now.subtract(Duration(hours: i));
      data.add({
        'time': DateFormat('HH:00').format(time),
        'pm': '39.1', 
      });
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> pmData = _generatePMData();

    return Column(
      children: [
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _showTable = !_showTable;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff45557B),
            ),
            child: Column(
              children: [
                Text(
                  _showTable ? 'Kecilkan' : 'Selengkapnya',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _showTable
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _showTable
            ? Card(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DataTable(
                  columnSpacing: 90,
                  headingRowColor: WidgetStateColor.resolveWith(
                    (states) => const Color(0xff45557B),
                  ),
                  headingTextStyle: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  columns: const [
                    DataColumn(
                      label: Center(
                        child: Text('Waktu', textAlign: TextAlign.center),
                      ),
                    ),
                    DataColumn(
                      label: Center(
                        child:
                            Text('Konsentrasi PM', textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                  rows: pmData
                      .map(
                        (item) => DataRow(
                          color: WidgetStateColor.resolveWith(
                            (states) => pmData.indexOf(item) % 2 == 0
                                ? Colors.white
                                : Colors.grey[200]!,
                          ),
                          cells: [
                            DataCell(
                              Center(
                                child: Text(
                                  item['time']!,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  item['pm']!,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ))
            : const SizedBox(),
      ],
    );
  }
}

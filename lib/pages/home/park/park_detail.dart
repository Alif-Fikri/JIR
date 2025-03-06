import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ParkDetail extends StatelessWidget {
  const ParkDetail({super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("dd MMMM yyyy").format(DateTime.now());

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Taman Cattleya'),
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          backgroundColor: const Color(0xff45557B),
          elevation: 10,
          shadowColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]),
              ),
              const SizedBox(height: 20),
              Text(
                formattedDate,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              _buildWeatherInfo(),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  // side: const BorderSide(color: Color(0xff45557B)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lokasi",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.map_outlined, color: Colors.black54),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              "Jl. Letjen S. Parman, RT.15/RW.1, Kemanggisan, Kec. Palmerah, Jakarta Barat",
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff45557B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.map),
                        label: const Text("Lihat Peta"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff45557B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          'Kualitas udara',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 136,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  border: Border.all(
                                    color: const Color(0xff45557B),
                                    width: 1.0, // Ketebalan border
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
              const SizedBox(height: 15),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Selengkapnya',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff45557B),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Color(0xff45557B),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff45557B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          'Grafik suhu',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 136,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  border: const Border(
                                    top: BorderSide(
                                        color: Color(0xff45557B), width: 1.0),
                                    left: BorderSide(
                                        color: Color(0xff45557B), width: 1.0),
                                    right: BorderSide(
                                        color: Color(0xff45557B), width: 1.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
              )
            ])));
  }

  Widget _buildWeatherInfo() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xff45557B), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(Icons.water_drop, "Kelembaban", "90%"),
            _buildVerticalDivider(),
            _buildInfoItem(Icons.air, "Udara", "1.016,00"),
            _buildVerticalDivider(),
            _buildInfoItem(Icons.thermostat, "Suhu", "27°C"),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1.5,
      color: Colors.grey[400],
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: const Color(0xff45557B)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xff45557B),
                  fontWeight: FontWeight.w400,
                )),
            Text(value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff45557B),
                )),
          ],
        ),
      ],
    );
  }
}

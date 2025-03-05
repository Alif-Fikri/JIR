import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParkPage extends StatefulWidget {
  const ParkPage({super.key});

  @override
  State<ParkPage> createState() => _ParkPageState();
}

class _ParkPageState extends State<ParkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(
            children: [
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/park.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'GoGreen',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 150,
                left: 30,
                right: 30,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(50),
                  shadowColor: Colors.grey.withOpacity(0.5),
                  child: TextField(
                    style: GoogleFonts.inter(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search . . .',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 15.0,
                          color: Colors.black,
                          fontStyle: FontStyle.italic),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 5.0, top: 5.0, left: 18.0, right: 15.0),
                        child: Image.asset(
                          'assets/images/search.png',
                          height: 25,
                          width: 25,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFEDEDED),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff45557B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TEKS HEADER
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 20),
                    child: Text(
                      'Yuk, Cari Udara Segar',
                      style: GoogleFonts.inter(
                        fontSize: 10,
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
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, bottom: 30, top: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/park.png',
                              width: 163,
                              height: 53,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Image.asset(
                            'assets/images/icon_park.png',
                            width: 143,
                            height: 122,
                          ),
                        ),
                        Positioned(
                          left: 15,
                          bottom: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xff45557B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Jl. Raya, No.12, Meruya Selatan',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                _buildSectionTitle('Rekomendasi Taman Terdekat'),
                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildNearbyPark(
                          'Taman Cattleya', '6 KM', 'assets/images/park.png'),
                      _buildNearbyPark(
                          'Taman Srengseng', '7 KM', 'assets/images/park.png'),
                      _buildNearbyPark('Taman Ayodya - Barito', '9 KM',
                          'assets/images/park.png'),
                    ],
                  ),
                ),
                _buildSectionTitle('Rekomendasi Taman Lainnya'),
                _buildOtherParks(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyPark(String name, String distance, String imagePath) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(imagePath,
                width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 80,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xff45557B),
              ),
            ),
          ),
          Text(
            distance,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xff45557B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherParks() {
    List<_ParkItem> parks = [
      _ParkItem('Taman Langsat', '9 km', 'Jl. Barito, Kebayoran Baru'),
      _ParkItem('Taman Puring', '10 km', 'Jl. Kyai Maja, Kebayoran'),
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: parks.length,
      itemBuilder: (context, index) {
        final park = parks[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xff45557B)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(park.name,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff45557B))),
                    const SizedBox(height: 4),
                    Text(park.distance,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: const Color(0xff45557B))),
                    const SizedBox(height: 2),
                    Text(park.address,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParkItem {
  final String name;
  final String distance;
  final String address;

  _ParkItem(this.name, this.distance, this.address);
}

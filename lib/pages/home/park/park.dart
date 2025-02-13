import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
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

                    // STACK UNTUK LATAR BELAKANG & KONTEN
                    Stack(
                      children: [
                        // BACKGROUND CONTAINER YANG MENUTUPI FULL AREA
                        Positioned.fill(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xff9FA8BE),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                            ),
                          ),
                        ),

                        // KONTEN DI ATAS BACKGROUND
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 30),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/park.png',
                                  width: 163,
                                  height: 53,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Spacer(),
                              Image.asset(
                                'assets/images/park.png',
                                width: 143,
                                height: 122,
                              ),
                            ],
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
                  ],
                ),
              ),
            ),
            _buildSectionTitle('Rekomendasi Taman Terdekat'),
            SizedBox(
              height: 120,
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
            _buildParkList([
              _ParkItem('Taman Langsat', '9 km', 'Jl. Barito, Kebayoran Baru',
                  'assets/taman_langsat.jpg'),
              _ParkItem('Taman Puring', '10 km', 'Jl. Kyai Maja, Kebayoran',
                  'assets/taman_puring.jpg'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
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
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(imagePath,
                width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(height: 5),
          Text(name,
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(distance,
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildParkList(List<_ParkItem> parks) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: parks.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final park = parks[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(park.image,
                width: 60, height: 60, fit: BoxFit.cover),
          ),
          title: Text(park.name,
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(park.distance,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.green)),
              Text(park.address,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}

class _ParkItem {
  final String name;
  final String distance;
  final String address;
  final String image;

  _ParkItem(this.name, this.distance, this.address, this.image);
}

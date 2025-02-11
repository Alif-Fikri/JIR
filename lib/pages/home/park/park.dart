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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/park.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  child: Text(
                    'GoGreen',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search . . .',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildSectionTitle('Rekomendasi Taman Terdekat'),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildNearbyPark(
                      'Taman Cattleya', '6 KM', 'assets/taman_cattleya.jpg'),
                  _buildNearbyPark(
                      'Taman Srengseng', '7 KM', 'assets/taman_srengseng.jpg'),
                  _buildNearbyPark('Taman Ayodya - Barito', '9 KM',
                      'assets/taman_ayodya.jpg'),
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
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNearbyPark(String name, String distance, String imagePath) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath,
                width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(height: 5),
          Text(name,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12)),
          Text(distance,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.green)),
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

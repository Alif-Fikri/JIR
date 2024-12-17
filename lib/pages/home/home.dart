import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:smartcitys/pages/home/chat/chatbot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Konten halaman
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(87),
                    bottomRight: Radius.circular(87),
                  ),
                  child: Container(
                    height: 308.0,
                    color: const Color(0xFF45557B),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25.0, left: 25.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "JIR APPLICATION",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -170),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 250.0,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/cerah.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/cerah_berawan.png',
                                  width: 50,
                                  height: 37,
                                ),
                                Text(
                                  "Cerah Berawan",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "32°",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Jakarta Barat",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -30.0,
                          right: -10.0,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              'assets/images/path.png',
                              width: 45,
                              height: 45,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -140),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                ),
                Transform.translate(
                  offset: const Offset(0, -110.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 30.0,
                      children: [
                        featureIcon(
                          onPressed: () => print('Navigating to Pantau Banjir'),
                          imagePath: 'assets/images/pantau_banjir.png',
                          label: 'Pantau Banjir',
                        ),
                        featureIcon(
                          onPressed: () =>
                              print('Navigating to Pantau Kerumunan'),
                          imagePath: 'assets/images/pantau_kerumunan.png',
                          label: 'Pantau Kerumunan',
                        ),
                        featureIcon(
                          onPressed: () => print('Navigating to Taman'),
                          imagePath: 'assets/images/laporan.png',
                          label: 'Laporan',
                        ),
                        featureIcon(
                          onPressed: () => print('Navigating to Taman'),
                          imagePath: 'assets/images/taman.png',
                          label: 'Taman',
                        ),
                        featureIcon(
                          onPressed: () => print('Navigating to Lokasi'),
                          imagePath: 'assets/images/location.png',
                          label: 'Lokasi',
                        ),
                        featureIcon(
                          onPressed: () => print('Navigating to CCTV'),
                          imagePath: 'assets/images/cctv.png',
                          label: 'CCTV',
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -100),
                  child: Container(
                    child: Image.asset('assets/images/line2.png'),
                  ),
                ),
                const SizedBox(height: 16),
                Transform.translate(
                  offset: const Offset(0, -80),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          "WARNING",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        warningBox("Curah Hujan Tinggi Berpotensi Banjir"),
                        warningBox("Aksi Demo Para Demonstran"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_animationController]),
            builder: (context, child) {
              double bounce =
                  math.sin(_animationController.value * 2 * math.pi) * 5;
              return Positioned(
                bottom: 50 + bounce,
                right: 25,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatbotOpeningPage(),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/robot.png',
                    width: 70,
                    height: 70,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget featureIcon(
      {required VoidCallback onPressed,
      String? imagePath,
      IconData? icon,
      required String label}) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30),
            shadowColor: Colors.grey.withOpacity(1.0),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFEAEFF3),
              child: imagePath != null
                  ? Image.asset(imagePath, width: 30, height: 30)
                  : Icon(icon, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 70),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF355469)),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget warningBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD205),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

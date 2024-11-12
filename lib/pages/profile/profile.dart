import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header dengan gambar latar belakang dan informasi profil
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Color(0xFF3B5998),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: Text(
                  'Hi, Smoggy !',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: 20,
                child: Text(
                  'smoggy.mail@gmail.com',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 47,
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150'), // Ganti URL ini dengan URL foto profil pengguna
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 60),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: [
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/settings.png', width: 24),
                    text: "Settings",
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/about.png', width: 24),
                    text: "About JIR",
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/privacypolicy.png',
                        width: 24),
                    text: "Privacy Policy",
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/termsofservice.png',
                        width: 24),
                    text: "Terms Of Service",
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/logout.png', width: 24),
                    text: "Logout",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final Widget icon;
  final String text;

  const ProfileMenuItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: icon,
          title: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF435482),
            ),
          ),
          onTap: () {
            // Tambahkan navigasi atau logika lainnya di sini
          },
        ),
        Divider(color: Color(0xffDEDEDE)),
      ],
    );
  }
}

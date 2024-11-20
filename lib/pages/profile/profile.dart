import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/profile/about.dart';
import 'package:smartcitys/pages/profile/privacy_policy.dart';
import 'package:smartcitys/pages/profile/settings/settings_page.dart';
import 'package:smartcitys/pages/profile/terms_of_service.dart';

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/about.png', width: 24),
                    text: "About JIR",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutPage(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/privacypolicy.png',
                        width: 24),
                    text: "Privacy Policy",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicy(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/termsofservice.png',
                        width: 24),
                    text: "Terms Of Service",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsOfService(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/logout.png', width: 24),
                    text: "Logout",
                    onTap: () {
                      // Tambahkan logika logout di sini
                    },
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
  final VoidCallback onTap; // Tambahkan callback untuk navigasi

  const ProfileMenuItem({
    required this.icon,
    required this.text,
    required this.onTap, // Wajib untuk fungsi navigasi
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap, // Gunakan GestureDetector untuk menangani klik
          child: ListTile(
            leading: icon,
            title: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF435482),
              ),
            ),
          ),
        ),
        Divider(color: Color(0xffDEDEDE)),
      ],
    );
  }
}


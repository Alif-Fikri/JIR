import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/home/home.dart';
import 'package:smartcitys/pages/profile/profile.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 3;

  final List<Widget> _pages = [
    HomePage(),
    AktivitasPage(),
    NotifikasiPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted), label: 'Aktivitas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xffE45835),
        unselectedItemColor: Color(0xff1A1A1A),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}

// Contoh halaman AktivitasPage
class AktivitasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Halaman Aktivitas",
        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Contoh halaman NotifikasiPage
class NotifikasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Halaman Notifikasi",
        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

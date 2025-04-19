import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/main/view/home.dart';
import 'package:JIR/pages/notifications/notification.dart';
import 'package:JIR/pages/profile/profile.dart';
import 'package:JIR/pages/activity/activity.dart';
import 'package:hive/hive.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = Get.arguments ?? 0;
  bool isLoggedIn = false;

  final List<Widget> _pages = [
    HomePage(),
    ActivityPage(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    var box = await Hive.openBox('authBox');
    final token = box.get('token');
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  void _onItemTapped(int index) {
    if ((index == 1 || index == 3) && !isLoggedIn) {
      _showLoginDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Login Diperlukan',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Text(
              'Untuk mengakses fitur ini, Anda perlu memiliki akun terlebih dahulu.',
              style: GoogleFonts.inter()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.toNamed('/signup');
              },
              child: Text('Register',
                  style: GoogleFonts.inter(color: Color(0xffE45835))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.toNamed('/login');
              },
              child: Text('Login',
                  style: GoogleFonts.inter(color: Color(0xffE45835))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.white),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.format_list_bulleted), label: 'Aktivitas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifikasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xffE45835),
          unselectedItemColor: const Color(0xff1A1A1A),
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

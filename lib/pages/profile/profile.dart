import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/auth/login.dart';
import 'package:smartcitys/pages/profile/about.dart';
import 'package:smartcitys/pages/profile/privacy_policy.dart';
import 'package:smartcitys/pages/profile/settings/settings_page.dart';
import 'package:smartcitys/pages/profile/terms_of_service.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> handleLogout(BuildContext context) async {
    try {
      final box = Hive.box('authBox');
      final token = box.get('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No token found. Please log in again.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await box.delete('token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to logout. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 320,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/group_38.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Smoggy !',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'smoggy.mail@gmail.com',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 50,
                bottom: 15,
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 74,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                          builder: (context) => const SettingsPage(),
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
                          builder: (context) => const AboutPage(),
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
                          builder: (context) => const PrivacyPolicy(),
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
                          builder: (context) => const TermsOfService(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/logout.png', width: 24),
                    text: "Logout",
                    onTap: () {
                      LogoutDialog.show(context, handleLogout);
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
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ListTile(
            leading: icon,
            title: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF435482),
              ),
            ),
          ),
        ),
        const Divider(color: Color(0xffDEDEDE)),
      ],
    );
  }
}

class LogoutDialog {
  static void show(
      BuildContext context, Future<void> Function(BuildContext) onLogout) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Log Out?',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure want to logout?',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          actions: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xff4B5C82)),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: FittedBox(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: const Color(0xff4B5C82), width: 1.5)),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await onLogout(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF435482),
                        ),
                        child: FittedBox(
                          child: Text(
                            'Log Out',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

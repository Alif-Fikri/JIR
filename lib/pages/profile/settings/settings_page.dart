import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/profile/settings/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        titleTextStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 24),
        backgroundColor: const Color(0xff45557B),
                leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: ListView(
          children: [
            ListTile(
              leading: Image.asset(
                'assets/images/delete.png',
                height: 26,
                width: 26,
              ),
              title: Text('Delete Account',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff45557B))),
              onTap: () => _showDeleteAccountDialog(context),
            ),
            const Divider(color: Color(0xffDEDEDE)),
            ListTile(
              leading: Image.asset(
                'assets/images/change.png',
                height: 26,
                width: 26,
              ),
              title: Text('Change Password',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff45557B))),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage()));
              },
            ),
            const Divider(color: Color(0xffDEDEDE)),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'DELETE ACCOUNT',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Please insert your Password',
                    labelStyle: GoogleFonts.inter(
                        fontSize: 14, fontStyle: FontStyle.italic),
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible =
                              !_isPasswordVisible; // Toggle visibilitas
                        });
                      },
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    border: const OutlineInputBorder()),
                obscureText: !_isPasswordVisible, // Atur visibilitas teks
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    height: 35.0,
                    width: 280.0,
                    color: const Color(0xffFFE3E3),
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 20),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            "You're about to delete your account. This action cannot be \nundone. All data will be lost.",
                            style: GoogleFonts.inter(
                                color: Colors.black, fontSize: 8),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff323232)),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: const Color(0xffE62525)),
              onPressed: () {
                // Tambahkan logika penghapusan akun di sini
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}

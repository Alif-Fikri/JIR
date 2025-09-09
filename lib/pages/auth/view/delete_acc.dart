import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/auth/controller/delete_acc_controller.dart';
import 'package:JIR/pages/auth/view/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _passwordController = TextEditingController();
  final DeleteAccountController _deleteController =
      Get.put(DeleteAccountController());

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
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
              title: Text('Hapus Akun',
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
              title: Text('Ubah Kata Sandi',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff45557B))),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ChangePasswordPage(),
                );
              },
            ),
            const Divider(color: Color(0xffDEDEDE)),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    bool isPasswordVisible = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'HAPUS AKUN',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      hintText: 'Masukkan kata sandi Anda',
                      labelStyle: GoogleFonts.inter(
                          fontSize: 14, fontStyle: FontStyle.italic),
                      hintStyle: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w500),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xffFFE3E3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Anda akan menghapus akun secara permanen. "
                          "Tindakan ini tidak dapat dibatalkan. "
                          "Semua data, riwayat, dan informasi pribadi Anda akan hilang selamanya.",
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          softWrap: true,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (_deleteController.isLoading.value)
                const CircularProgressIndicator(),
              TextButton(
                onPressed: _deleteController.isLoading.value
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff323232)),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffE62525)),
                onPressed: _deleteController.isLoading.value
                    ? null
                    : () async {
                        await _deleteController
                            .deleteAccount(_passwordController.text);
                        if (mounted) Navigator.of(context).pop();
                      },
                child: Text(
                  'Hapus',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kebijakan Layanan'),
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: ListView(
          children: [
            _buildTitle("Syarat dan Ketentuan Layanan Penggunaan JIR"),
            SizedBox(height: 15.h),
            _buildUpdate("Terakhir diperbarui: 12 Januari 2025"),
            SizedBox(height: 20.h),
            _buildParagraph(
              "Dengan menggunakan aplikasi JIR, Anda setuju untuk mematuhi syarat dan ketentuan berikut:",
            ),
            SizedBox(height: 20.h),
            _buildTitle("1. PENGGUNAAN LAYANAN"),
            SizedBox(height: 15.h),
            _buildParagraph(
              "Kami dapat mengumpulkan informasi berikut untuk menyediakan layanan yang lebih baik:\n"
              "• Aplikasi JIR hanya boleh digunakan untuk tujuan pemantauan banjir, kerumunan, dan kebakaran.\n"
              "• Pengguna dilarang menyalahgunakan layanan untuk tujuan yang melanggar hukum atau mengganggu keamanan publik.",
            ),
            SizedBox(height: 20.h),
            _buildSubtitle("2. HAK DAN KEWAJIBAN PENGGUNA"),
            SizedBox(height: 15.h),
            _buildParagraph(
              "• Pengguna bertanggung jawab atas kebenaran data yang diberikan.\n"
              "• Pengguna wajib menjaga kerahasiaan akun dan kata sandi mereka.\n"
              "• Pengguna dilarang mengunggah konten yang melanggar hukum atau hak pihak ketiga.",
            ),
            SizedBox(height: 20.h),
            _buildSubtitle("3. BATASAN TANGGUNG JAWAB"),
            SizedBox(height: 15.h),
            _buildParagraph(
              "• Aplikasi JIR tidak bertanggung jawab atas kesalahan data atau keterlambatan informasi dari pihak ketiga.\n"
              "• Kami tidak bertanggung jawab atas kehilangan atau kerusakan yang diakibatkan oleh penggunaan aplikasi ini.",
            ),
            SizedBox(height: 20.h),
            _buildTitle("4. PENGHENTIAN LAYANAN"),
            SizedBox(height: 15.h),
            _buildParagraph(
              "Kami berhak menghentikan akses pengguna yang melanggar kebijakan ini tanpa pemberitahuan sebelumnya.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdate(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10.sp,
        fontWeight: FontWeight.w300,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w300,
        color: Colors.black,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
          fontSize: 13.sp,
          height: 1.5,
          color: Colors.black,
          fontWeight: FontWeight.w300),
      textAlign: TextAlign.justify,
    );
  }
}

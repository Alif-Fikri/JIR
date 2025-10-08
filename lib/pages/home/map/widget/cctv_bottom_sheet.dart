import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/cctv/cctv_webview.dart';
import 'package:JIR/pages/home/cctv/model/cctv_location.dart';

class CctvBottomSheet extends StatelessWidget {
  const CctvBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar CCTV Kota',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff45557B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pilih lokasi untuk melihat streaming langsung.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xff6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xff6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: defaultCctvLocations.length,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final location = defaultCctvLocations[index];
                  return ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xffE8EDFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Color(0xff45557B),
                      ),
                    ),
                    title: Text(
                      location.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff111827),
                      ),
                    ),
                    subtitle: Text(
                      'Lat: ${location.coordinates.latitude.toStringAsFixed(4)}, '
                      'Lon: ${location.coordinates.longitude.toStringAsFixed(4)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xff94A3B8),
                    ),
                    onTap: () {
                      Get.back();
                      Get.to(() => CCTVWebView(url: location.url));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

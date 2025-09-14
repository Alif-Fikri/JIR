import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:JIR/pages/home/report/widget/url_network.dart';

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;
  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd MMM yyyy • HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: InteractiveViewer(
          child: imageUrl.startsWith('http')
              ? Image.network(imageUrl, fit: BoxFit.contain)
              : Image.file(File(imageUrl), fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF45557B))),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          maxLines: 1,
          style: GoogleFonts.inter(color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabled: false,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox({double height = 16, double radius = 8, double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final imageUrl =
        (report['imagePath'] ?? report['image_path'] ?? '').toString();
    final title = (report['type'] ?? 'Laporan').toString();
    final desc = (report['description'] ?? '').toString();
    final name = (report['contactName'] ?? 'Anonim').toString();
    final phone = (report['contactPhone'] ?? '').toString();
    final date = (report['dateTime'] ?? '').toString();
    final address = (report['address'] ?? '').toString();
    final status = (report['status'] ?? 'Menunggu').toString();
    final severity = (report['severity'] ?? '').toString();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Detail Laporan',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        backgroundColor: const Color(0xFF45557B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 84),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: [
                          if (isLoading)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                            )
                          else if (imageUrl.isNotEmpty)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: GestureDetector(
                                onTap: () => _showFullImage(context, imageUrl),
                                child: buildReportImage(imageUrl,
                                    height: 200, fit: BoxFit.cover),
                              ),
                            )
                          else
                            Container(
                              height: 160,
                              color: Colors.grey[100],
                              child: Center(
                                child: Text('Tidak ada foto',
                                    style:
                                        GoogleFonts.inter(color: Colors.grey)),
                              ),
                            ),
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: isLoading
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _shimmerBox(height: 18, width: 120),
                                            const SizedBox(height: 6),
                                            _shimmerBox(height: 12, width: 80),
                                          ],
                                        )
                                      : Text(
                                          title,
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87),
                                        ),
                                ),
                                isLoading
                                    ? _shimmerBox(
                                        height: 28, width: 80, radius: 20)
                                    : Chip(
                                        label: Text(status,
                                            style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 12)),
                                        backgroundColor: status
                                                .toLowerCase()
                                                .contains('diterima')
                                            ? const Color(0xFF66BB6A)
                                            : status
                                                    .toLowerCase()
                                                    .contains('ditolak')
                                                ? const Color(0xFF45557B)
                                                : const Color(0xFFFFA726),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: isLoading
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            _shimmerBox(
                                                height: 36,
                                                width: double.infinity),
                                          ])
                                    : _buildField(
                                        'Waktu Kejadian', _formatDate(date)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: isLoading
                                    ? _shimmerBox(
                                        height: 36, width: double.infinity)
                                    : _buildField('Keparahan', severity),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          isLoading
                              ? _shimmerBox(height: 48, width: double.infinity)
                              : _buildField('Alamat / Lokasi',
                                  address.isNotEmpty ? address : '-'),
                          const SizedBox(height: 12),
                          isLoading
                              ? _shimmerBox(height: 48, width: double.infinity)
                              : _buildField('Pelapor',
                                  name + (phone.isNotEmpty ? ' • $phone' : '')),
                          const SizedBox(height: 12),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Deskripsi',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF45557B))),
                                const SizedBox(height: 6),
                                isLoading
                                    ? _shimmerBox(
                                        height: 80, width: double.infinity)
                                    : Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Text(
                                            desc.isNotEmpty ? desc : '-',
                                            style: GoogleFonts.inter(
                                                color: Colors.black87)),
                                      ),
                              ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: imageUrl.isNotEmpty && !isLoading
                          ? () => _showFullImage(context, imageUrl)
                          : null,
                      icon: const Icon(Icons.fullscreen,
                          color: Color(0xFF45557B)),
                      label: Text('Lihat Foto',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF45557B), fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF45557B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Kembali',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

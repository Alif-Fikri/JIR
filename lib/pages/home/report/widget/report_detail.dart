import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;
  const ReportDetailPage({super.key, required this.report});

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

  @override
  Widget build(BuildContext context) {
    final imageUrl = (report['imagePath'] ?? '').toString();
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
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
                    if (imageUrl.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imageUrl.startsWith('http')
                            ? Image.network(imageUrl, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                        child: Icon(Icons.broken_image)));
                              })
                            : Image.file(File(imageUrl), fit: BoxFit.cover),
                      )
                    else
                      Container(
                        height: 160,
                        color: Colors.grey[100],
                        child: Center(
                          child: Text('Tidak ada foto',
                              style: GoogleFonts.inter(color: Colors.grey)),
                        ),
                      ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87),
                            ),
                          ),
                          Chip(
                            label: Text(status,
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 12)),
                            backgroundColor:
                                status.toLowerCase().contains('selesai')
                                    ? const Color(0xFF66BB6A)
                                    : status.toLowerCase().contains('diproses')
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
                            child: _buildField(
                                'Waktu Kejadian', _formatDate(date))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Keparahan', severity)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                        'Alamat / Lokasi', address.isNotEmpty ? address : '-'),
                    const SizedBox(height: 12),
                    _buildField('Pelapor',
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(desc.isNotEmpty ? desc : '-',
                                style:
                                    GoogleFonts.inter(color: Colors.black87)),
                          ),
                        ]),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: imageUrl.isNotEmpty
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
            ],
          ),
        ),
      ),
    );
  }
}

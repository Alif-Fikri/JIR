import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final String status;
  final String description;
  final String imageUrl;
  final String dateTimeIso;
  final VoidCallback? onTap;
  final VoidCallback? onShowImage;

  const ReportCard({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.status,
    required this.description,
    required this.imageUrl,
    required this.dateTimeIso,
    this.onTap,
    this.onShowImage,
  });

  Widget _buildAvatar() {
    if (avatarUrl.isEmpty) {
      return const CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/images/default_avatar.png'));
    }
    if (avatarUrl.startsWith('http')) {
      return CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl));
    }
    if (avatarUrl.startsWith('/')) {
      final file = File(avatarUrl);
      if (file.existsSync()) {
        return CircleAvatar(backgroundImage: FileImage(file), radius: 20);
      }
    }
    return const CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/images/default_avatar.png'));
  }

  Color _statusColor(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('menunggu')) return const Color(0xFFFFA726); 
    if (lower.contains('diproses')) return const Color(0xFF45557B);
    if (lower.contains('selesai')) return const Color(0xFF66BB6A); 
    return Colors.grey;
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd MMM yyyy • HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: imageUrl.startsWith('http')
              ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink())
              : Image.file(File(imageUrl), fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(width: 0.2)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(username, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_formatDate(dateTimeIso), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                ]),
              ),
              Chip(
                label: Text(status, style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                backgroundColor: _statusColor(status),
              ),
            ]),
            const SizedBox(height: 12),
            Text(description, style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            if (imageUrl.isNotEmpty)
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.startsWith('http')
                      ? Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey[200]))
                      : Image.file(File(imageUrl), height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (onShowImage != null) {
                        onShowImage!();
                        return;
                      }
                      _showFullImage(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ]),
          ]),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  late Box box;
  bool _ready = false;
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      _openBox(),
      Future.delayed(const Duration(milliseconds: 700)),
    ]);
    if (mounted) {
      setState(() {
        _showShimmer = false;
      });
    }
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen('reports')) {
      await Hive.openBox('reports');
    }
    box = Hive.box('reports');
    if (mounted) {
      setState(() {
        _ready = true;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _showShimmer = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!Hive.isBoxOpen('reports')) {
      await Hive.openBox('reports');
    }
    box = Hive.box('reports');
    if (mounted) {
      setState(() {
        _showShimmer = false;
        _ready = true;
      });
    }
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.2, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 140, color: Colors.white),
                  ]),
            ),
            const SizedBox(width: 8),
            Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16))),
          ]),
          const SizedBox(height: 12),
          Container(height: 12, width: double.infinity, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 12, width: double.infinity, color: Colors.white),
          const SizedBox(height: 12),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                  height: 180, width: double.infinity, color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showShimmer) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: const Text('Laporan',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black87),
                onPressed: _onRefresh),
          ],
        ),
        body: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0xff45557B),
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => _buildShimmerItem(),
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final boxRef = Hive.box('reports');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text('Laporan',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: _onRefresh),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: boxRef.listenable(keys: ['list']),
        builder: (context, _, __) {
          final rawList = List<Map>.from(boxRef.get('list', defaultValue: []));
          if (rawList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("Belum ada laporan")),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: rawList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final m = Map<String, dynamic>.from(rawList[index]);
                final username = (m['username'] as String?) ?? '';
                final avatarUrl = (m['avatarUrl'] as String?) ?? '';
                final status = (m['status'] as String?) ?? '';
                final description = (m['description'] as String?) ?? '';
                final imageUrl = (m['imageUrl'] as String?) ?? '';
                final dateTimeIso = (m['dateTimeIso'] as String?) ?? '';
                return ReportCard(
                  username: username,
                  avatarUrl: avatarUrl,
                  status: status,
                  description: description,
                  imageUrl: imageUrl,
                  dateTimeIso: dateTimeIso,
                  onShowImage: () {
                    if (imageUrl.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(16),
                          child: InteractiveViewer(
                            child: imageUrl.startsWith('http')
                                ? Image.network(imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink())
                                : Image.file(File(imageUrl),
                                    fit: BoxFit.contain),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

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
      return const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/images/default_avatar.png'));
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
    return const CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage('assets/images/default_avatar.png'));
  }

  Color _statusColor(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('menunggu')) return const Color(0xFFFFA726);
    if (lower.contains('ditolak')) return const Color(0xFF45557B);
    if (lower.contains('diterima')) return const Color(0xFF66BB6A);
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
              ? Image.network(imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())
              : Image.file(File(imageUrl), fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(width: 0.2)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username,
                          style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_formatDate(dateTimeIso),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[600])),
                    ]),
              ),
              Chip(
                  label: Text(status,
                      style:
                          GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                  backgroundColor: _statusColor(status)),
            ]),
            const SizedBox(height: 12),
            Text(description, style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            if (imageUrl.isNotEmpty)
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.startsWith('http')
                      ? Image.network(imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(height: 200, color: Colors.grey[200]))
                      : Image.file(File(imageUrl),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover),
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
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.fullscreen,
                          color: Colors.white, size: 20),
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

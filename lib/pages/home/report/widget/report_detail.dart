import 'dart:io';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:JIR/pages/home/report/widget/url_network.dart';
import 'package:JIR/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;
  const ReportDetailPage({super.key, required this.report});
  get binding => null;

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
        insetPadding: EdgeInsets.all(12.w),
        child: InteractiveViewer(
          child: imageUrl.startsWith('http')
              ? Image.network(
                  Uri.encodeFull(imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black,
                    child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white)),
                  ),
                )
              : (() {
                  try {
                    final f = File(imageUrl);
                    if (f.existsSync()) {
                      return Image.file(f, fit: BoxFit.contain);
                    } else {
                      return Image.network(
                        Uri.encodeFull(imageUrl),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black,
                          child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white)),
                        ),
                      );
                    }
                  } catch (_) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white)),
                    );
                  }
                }()),
        ),
      ),
    );
  }

  String _resolveDocumentSource(Map<String, dynamic> report) {
    final candidates = [
      report['documentPath'],
      report['document_path'],
      report['documentUrl'],
      report['document_url'],
    ];
    for (final candidate in candidates) {
      final value = (candidate ?? '').toString();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  Future<void> _openDocumentAttachment(String source) async {
    if (source.isEmpty) return;

    if (source.startsWith('http')) {
      final uri = Uri.tryParse(source);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Lampiran', 'Tidak dapat membuka tautan dokumen',
            snackPosition: SnackPosition.BOTTOM);
      }
      return;
    }

    final file = resolveLocalFile(source);
    if (file != null) {
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        Get.snackbar('Lampiran', 'Gagal membuka dokumen: ${result.message}',
            snackPosition: SnackPosition.BOTTOM);
      }
      return;
    }

    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    Get.snackbar('Lampiran', 'Lampiran dokumen tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM);
  }

  String _documentDisplayName(String source) {
    try {
      return p.basename(source);
    } catch (_) {
      return 'Lampiran';
    }
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF45557B))),
        SizedBox(height: 6.h),
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
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
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
        height: height.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius.r),
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
    final severityLabel = ReportController.severityLabelForType(
        (report['type'] ?? '').toString());
    final customTypeDetail =
        (report['customTypeDetail'] ?? report['custom_type_detail'] ?? '')
            .toString();
    final documentSource = _resolveDocumentSource(report);
    final hasDocument = documentSource.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Detail Laporan',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp)),
        backgroundColor: const Color(0xFF45557B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 84.h),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
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
                              height: 160.h,
                              color: Colors.grey[100],
                              child: Center(
                                child: Text('Tidak ada foto',
                                    style:
                                        GoogleFonts.inter(color: Colors.grey)),
                              ),
                            ),
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
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
                                              fontSize: 16.sp,
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
                                                fontSize: 12.sp)),
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
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6.r,
                              offset: Offset(0, 2.h)),
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
                              SizedBox(width: 12.w),
                              Expanded(
                                child: isLoading
                                    ? _shimmerBox(
                                        height: 36, width: double.infinity)
                                    : _buildField(severityLabel,
                                        severity.isNotEmpty ? severity : '-'),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          isLoading
                              ? _shimmerBox(height: 48, width: double.infinity)
                              : _buildField('Alamat / Lokasi',
                                  address.isNotEmpty ? address : '-'),
                          SizedBox(height: 12.h),
                          isLoading
                              ? _shimmerBox(height: 48, width: double.infinity)
                              : _buildField('Pelapor',
                                  name + (phone.isNotEmpty ? ' • $phone' : '')),
                          SizedBox(height: 12.h),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Deskripsi',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF45557B))),
                                SizedBox(height: 6.h),
                                isLoading
                                    ? _shimmerBox(
                                        height: 80, width: double.infinity)
                                    : Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Text(
                                            desc.isNotEmpty ? desc : '-',
                                            style: GoogleFonts.inter(
                                                color: Colors.black87)),
                                      ),
                              ]),
                          SizedBox(height: 12.h),
                          if (!isLoading && customTypeDetail.isNotEmpty)
                            _buildField('Detail Laporan', customTypeDetail),
                          if (isLoading && hasDocument)
                            _shimmerBox(height: 48, width: double.infinity),
                          if (!isLoading && hasDocument)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lampiran Dokumen',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF45557B))),
                                SizedBox(height: 6.h),
                                GestureDetector(
                                  onTap: () =>
                                      _openDocumentAttachment(documentSource),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 14.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40.w,
                                          height: 40.w,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          child: Icon(Icons.insert_drive_file,
                                              color: const Color(0xFF45557B),
                                              size: 22.sp),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            _documentDisplayName(
                                                documentSource),
                                            style: GoogleFonts.inter(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(Icons.open_in_new,
                                            color: const Color(0xFF45557B),
                                            size: 20.sp),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: imageUrl.isNotEmpty && !isLoading
                          ? () => _showFullImage(context, imageUrl)
                          : null,
                      icon: Icon(Icons.fullscreen,
                          color: const Color(0xFF45557B), size: 20.sp),
                      label: Text('Lihat Foto',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF45557B), fontSize: 14.sp)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF45557B),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Kembali',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14.sp)),
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

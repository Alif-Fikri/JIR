import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

class ReportFormPage extends StatelessWidget {
  final ReportController controller = Get.find();

  ReportFormPage({super.key});

  void _showFullImage(BuildContext context) {
    final file = controller.imageFile.value;
    if (file == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: InteractiveViewer(
          child: Image.file(file, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final dt = controller.dateTime.value;

    final ThemeData pickerTheme = Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF45557B),
        onPrimary: Colors.white,
        secondary: Color(0xFFE45835),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF45557B),
        ),
      ),
    );

    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: dt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(data: pickerTheme, child: child!);
      },
    );
    if (d == null) return;

    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dt),
      builder: (context, child) {
        return Theme(
          data: pickerTheme.copyWith(
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: Colors.white,
              dialHandColor: const Color(0xFFE45835),
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF45557B);
                }
                return Colors.white;
              }),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF45557B);
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF45557B);
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF45557B);
                }
                return Colors.white;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (t == null) return;

    controller.setDateTime(DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Obx(() {
                final dt = controller.dateTime.value;
                final formatted = DateFormat('yyyy-MM-dd HH:mm').format(dt);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAttachmentsSection(context),
                    SizedBox(height: 16.h),
                    _buildTypeAndSeverity(),
                    SizedBox(height: 12.h),
                    _buildAddressSection(),
                    SizedBox(height: 12.h),
                    _buildDescriptionField(),
                    SizedBox(height: 12.h),
                    _buildContactSection(),
                    SizedBox(height: 12.h),
                    _buildDateTimeField(context, formatted),
                    SizedBox(height: 24.h),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: _buildSubmitButton(),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: Text('Laporan Baru',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                color: Colors.white)),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
            onPressed: () => Get.back()),
      );

  Widget _buildAttachmentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lampiran Foto',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        SizedBox(height: 6.h),
        _buildImagePreview(context),
        SizedBox(height: 12.h),
        Text('Lampiran Dokumen (opsional)',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        SizedBox(height: 6.h),
        _buildDocumentAttachment(),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final file = controller.imageFile.value;
    if (file == null) {
      return Container(
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child:
            Center(child: Text('Belum ada foto', style: GoogleFonts.inter())),
      );
    }
    return Column(children: [
      Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(file,
              width: double.infinity, height: 200.h, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showFullImage(context),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child:
                      Icon(Icons.fullscreen, color: Colors.white, size: 22.sp),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => controller.pickImage(picker.ImageSource.gallery),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: Icon(Icons.refresh, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
        ),
      ]),
      SizedBox(height: 8.h),
    ]);
  }

  Widget _buildDocumentAttachment() {
    return Obx(() {
      final file = controller.documentFile.value;
      if (file == null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: controller.pickDocument,
              icon: const Icon(Icons.attach_file),
              label: Text('Tambah Dokumen', style: GoogleFonts.inter()),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff45557B),
                side: const BorderSide(color: Color(0xff45557B)),
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
            SizedBox(height: 8.h),
            Text('Format yang didukung: PDF, Word, Excel, PPT, TXT',
                style:
                    GoogleFonts.inter(fontSize: 11.sp, color: Colors.black54)),
          ],
        );
      }
      final fileName = p.basename(file.path);
      return InkWell(
        onTap: () async {
          final result = await OpenFilex.open(file.path);
          if (result.type != ResultType.done) {
            Get.snackbar('Lampiran', 'Tidak dapat membuka dokumen');
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xffF5F7FB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xff45557B).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xff45557B),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.description, color: Colors.white),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14.sp)),
                    SizedBox(height: 4.h),
                    Text('Ketuk untuk membuka',
                        style: GoogleFonts.inter(
                            fontSize: 12.sp, color: Colors.black54)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black54,
                onPressed: controller.removeDocument,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTypeAndSeverity() {
    final showSeverity = controller.shouldShowSeverity;
    final severityOptions = controller.currentSeverityOptions;
    if (showSeverity && severityOptions.isNotEmpty) {
      final current = controller.severity.value;
      if (current.isEmpty || !severityOptions.contains(current)) {
        controller.severity.value = severityOptions.first;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipe Laporan',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: controller.reportType.value,
          items: controller.reportTypes
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: GoogleFonts.inter(
                            fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.onReportTypeSelected(v);
          },
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
        if (showSeverity) ...[
          SizedBox(height: 12.h),
          Text(controller.currentSeverityLabel,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: controller.severity.value.isEmpty
                ? severityOptions.first
                : controller.severity.value,
            items: severityOptions
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: GoogleFonts.inter(
                              fontSize: 14.sp, fontWeight: FontWeight.w500)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.severity.value = v;
            },
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          ),
        ],
        if (controller.reportType.value == 'Lainnya') ...[
          SizedBox(height: 12.h),
          Text('Detail Jenis Laporan',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          TextFormField(
            initialValue: controller.customTypeDetail.value,
            onChanged: (v) => controller.customTypeDetail.value = v,
            decoration: InputDecoration(
              hintText: 'Contoh: Kebisingan, fasilitas rusak, dsb.',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Alamat / Lokasi',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      SizedBox(height: 6.h),
      Row(children: [
        Expanded(
          child: TextFormField(
            initialValue: controller.address.value,
            onChanged: (v) => controller.address.value = v,
            decoration: InputDecoration(
              hintText: 'Masukkan alamat atau tekan ambil lokasi',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 48.w,
          height: 48.h,
          child: ElevatedButton(
            onPressed: controller.fillLocationFromGPS,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff45557B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.zero,
              minimumSize: Size(48.w, 48.h),
            ),
            child: Center(
                child:
                    Icon(Icons.my_location, color: Colors.white, size: 24.sp)),
          ),
        ),
      ]),
      SizedBox(height: 8.h),
      Text(
        'Koordinat: ${controller.latitude.value.toStringAsFixed(6)}, ${controller.longitude.value.toStringAsFixed(6)}',
        style: GoogleFonts.inter(fontSize: 12.sp),
      ),
    ]);
  }

  Widget _buildDescriptionField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Deskripsi', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      SizedBox(height: 6.h),
      TextFormField(
        initialValue: controller.description.value,
        onChanged: (v) => controller.description.value = v,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Jelaskan kronologi / detail',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding: EdgeInsets.all(12.w),
        ),
      ),
    ]);
  }

  Widget _buildContactSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child: Text('Nama',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(
            child: Text('No. Telepon',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
      ]),
      SizedBox(height: 6.h),
      Row(children: [
        Expanded(
          child: TextFormField(
            initialValue: controller.contactName.value,
            onChanged: (v) => controller.contactName.value = v,
            decoration: InputDecoration(
              hintText: 'Nama pelapor',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: TextFormField(
            initialValue: controller.contactPhone.value,
            onChanged: (v) => controller.contactPhone.value = v,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '0812xxxx',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ),
      ]),
      Row(children: [
        Checkbox(
            checkColor: Colors.black,
            activeColor: Colors.white,
            value: controller.isAnonymous.value,
            onChanged: (v) => controller.isAnonymous.value = v ?? false),
        Text('Laporkan sebagai anonim', style: GoogleFonts.inter()),
      ]),
    ]);
  }

  Widget _buildDateTimeField(BuildContext context, String formatted) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Waktu Kejadian',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      SizedBox(height: 6.h),
      InkWell(
        onTap: () => _pickDateTime(context),
        child: Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(child: Text(formatted, style: GoogleFonts.inter())),
              Icon(Icons.calendar_today, size: 18.sp, color: Colors.grey),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: controller.submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff45557B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: Text('Kirim Laporan',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

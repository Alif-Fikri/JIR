import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:intl/intl.dart';

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
        insetPadding: const EdgeInsets.all(16),
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
                borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                final dt = controller.dateTime.value;
                final formatted = DateFormat('yyyy-MM-dd HH:mm').format(dt);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePreview(context),
                    const SizedBox(height: 16),
                    _buildTypeAndSeverity(),
                    const SizedBox(height: 12),
                    _buildAddressSection(),
                    const SizedBox(height: 12),
                    _buildDescriptionField(),
                    const SizedBox(height: 12),
                    _buildContactSection(),
                    const SizedBox(height: 12),
                    _buildDateTimeField(context, formatted),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _buildSubmitButton(),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: Text('Laporan Baru',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back()),
      );

  Widget _buildImagePreview(BuildContext context) {
    final file = controller.imageFile.value;
    if (file == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file,
              width: double.infinity, height: 200, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showFullImage(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.fullscreen, color: Colors.white),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildTypeAndSeverity() {
    return Row(
      children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tipe Laporan',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: controller.reportType.value,
              items: [
                'Banjir',
                'Pohon Tumbang',
                'Kecelakaan',
                'Kebakaran',
                'Kerusakan Jalan',
                'Lainnya'
              ]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
              onChanged: (v) => controller.reportType.value =
                  v ?? controller.reportType.value,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Keparahan',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: controller.severity.value,
              items: ['Rendah', 'Sedang', 'Tinggi']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
              onChanged: (v) =>
                  controller.severity.value = v ?? controller.severity.value,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Alamat / Lokasi',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
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
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.fillLocationFromGPS,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff45557B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 48),
            ),
            child: const Center(
                child: Icon(Icons.my_location, color: Colors.white)),
          ),
        ),
      ]),
      const SizedBox(height: 8),
      Text(
        'Koordinat: ${controller.latitude.value.toStringAsFixed(6)}, ${controller.longitude.value.toStringAsFixed(6)}',
        style: GoogleFonts.inter(fontSize: 12),
      ),
    ]);
  }

  Widget _buildDescriptionField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Deskripsi', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextFormField(
        initialValue: controller.description.value,
        onChanged: (v) => controller.description.value = v,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Jelaskan kronologi / detail',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.all(12),
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
      const SizedBox(height: 6),
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
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
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
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      const SizedBox(height: 6),
      InkWell(
        onTap: () => _pickDateTime(context),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(child: Text(formatted, style: GoogleFonts.inter())),
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff45557B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text('Kirim Laporan',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';

class RouteBottomSheetWidget extends StatelessWidget {
  final RouteController controller = Get.find<RouteController>();

  RouteBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 80,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Petunjuk Arah',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff45557B),
                              ),
                            ),
                            Obx(() {
                              final stepCount = controller.routeSteps.length;
                              return Text(
                                stepCount > 0
                                    ? '$stepCount langkah'
                                    : '0 langkah',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final totalRaw =
                              controller.routeSteps.fold<double>(0.0, (sum, s) {
                            final raw = s['distance'];
                            if (raw == null) return sum;
                            if (raw is num) return sum + raw.toDouble();
                            if (raw is String)
                              return sum + (double.tryParse(raw) ?? 0.0);
                            return sum;
                          });

                          double maxStep = 0.0;
                          for (final s in controller.routeSteps) {
                            final raw = s['distance'];
                            if (raw == null) continue;
                            double v = 0.0;
                            if (raw is num) v = raw.toDouble();
                            if (raw is String) v = double.tryParse(raw) ?? 0.0;
                            if (v > maxStep) maxStep = v;
                          }

                          double totalMeters = totalRaw;
                          if (controller.routeSteps.isNotEmpty &&
                              maxStep <= 10) {
                            totalMeters = totalRaw * 1000.0;
                          }

                          if (totalMeters <= 0) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Text('Estimasi belum tersedia',
                                      style: GoogleFonts.inter(fontSize: 14)),
                                ),
                                Chip(
                                  label: Text('—',
                                      style: GoogleFonts.inter(
                                          color: Colors.black)),
                                  backgroundColor: Colors.grey[100],
                                ),
                              ],
                            );
                          }

                          const motorKmH = 30.0;
                          const carKmH = 40.0;
                          final selected = controller.selectedVehicle.value;
                          final kmh = selected == 'car' ? carKmH : motorKmH;
                          final metersPerMinute = (kmh * 1000.0) / 60.0;
                          final estimatedMinutes =
                              (totalMeters / metersPerMinute).ceil();
                          final distanceKm = totalMeters / 1000.0;

                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selected == 'car'
                                      ? 'Estimasi perjalanan dengan Mobil'
                                      : 'Estimasi perjalanan dengan Motor',
                                  style: GoogleFonts.inter(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                  icon: Icons.access_time,
                                  label: '$estimatedMinutes mnt',
                                  color: Colors.green[700]!),
                              const SizedBox(width: 8),
                              _InfoChip(
                                  icon: Icons.place,
                                  label: '${distanceKm.toStringAsFixed(2)} km',
                                  color: Colors.blueGrey),
                            ],
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() {
                          final selected = controller.selectedVehicle.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _VehicleOption(
                                iconAsset: 'assets/images/icon_motor.png',
                                label: 'Motor',
                                isSelected: selected == 'motorcycle',
                                onTap: () =>
                                    controller.updateVehicle('motorcycle'),
                              ),
                              const SizedBox(width: 12),
                              _VehicleOption(
                                iconAsset: 'assets/images/icon_car.png',
                                label: 'Mobil',
                                isSelected: selected == 'car',
                                onTap: () => controller.updateVehicle('car'),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rute yang dilalui',
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Rute tercepat lewat perumahan',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const SizedBox(
                                height: 180,
                                child:
                                    Center(child: CircularProgressIndicator()));
                          }
                          if (controller.routeSteps.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                  child: Text('Tidak ada langkah rute',
                                      style: GoogleFonts.inter(
                                          color: Colors.grey))),
                            );
                          }
                          return ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: controller.routeSteps.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final step = controller.routeSteps[index];
                              return _RouteStepItem(index: index, step: step);
                            },
                          );
                        }),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff45557B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(Get.context!),
                    child: Text('Tutup',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withOpacity(0.12),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _VehicleOption extends StatelessWidget {
  final String iconAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.iconAsset,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffEEF4FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xff45557B) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            AnimatedScale(
              scale: isSelected ? 1.06 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xff45557B) : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    iconAsset,
                    color: isSelected ? Colors.white : null,
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        isSelected ? const Color(0xff45557B) : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                if (isSelected)
                  Text(
                    'Direkomendasikan',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: Colors.green[700]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteStepItem extends StatelessWidget {
  final int index;
  final Map<String, dynamic> step;

  const _RouteStepItem({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    final instruction = step['instruction'] as String? ?? '';
    final name = step['name'] as String? ?? '';
    final raw = step['distance'];
    final distanceNum =
        raw is num ? raw : (raw is String ? double.tryParse(raw) ?? 0.0 : 0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
                width: 36,
                child: Center(
                    child: RouteController.getManeuverIcon(
                        step['type'], step['modifier']))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(instruction,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff45557B))),
                const SizedBox(height: 6),
                Text('Jalan: $name',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text(RouteController.formatDistance(distanceNum),
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.green[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

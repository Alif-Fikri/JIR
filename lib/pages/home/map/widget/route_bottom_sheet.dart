import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';

class _VehicleMode {
  const _VehicleMode(this.key, this.label, this.icon);

  final String key;
  final String label;
  final IconData icon;
}

class RouteBottomSheetWidget extends StatelessWidget {
  RouteBottomSheetWidget({super.key});

  final RouteController controller = Get.find<RouteController>();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      initialChildSize: 0.3,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        final mediaQuery = MediaQuery.of(context);
        final bottomPadding =
            mediaQuery.viewPadding.bottom + mediaQuery.viewInsets.bottom + 24;

        return SafeArea(
          top: false,
          bottom: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 58,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      bottomPadding,
                    ),
                    children: [
                      _buildDestinationRow(),
                      const SizedBox(height: 12),
                      _buildHeaderSection(),
                      const SizedBox(height: 16),
                      _buildVehicleSelector(),
                      const SizedBox(height: 18),
                      _buildRouteVariants(),
                      const SizedBox(height: 20),
                      const Divider(height: 32),
                      _buildSectionHeader(),
                      const SizedBox(height: 8),
                      _buildRouteList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationRow() {
    return Obx(() {
      final title = controller.destinationLabel.value.isNotEmpty
          ? controller.destinationLabel.value
          : 'Petunjuk arah';

      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff111827),
                  ),
                ),
                if (controller.destinationAddress.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      controller.destinationAddress.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(Get.context!),
            icon: const Icon(Icons.close, size: 20, color: Color(0xff6B7280)),
            tooltip: 'Tutup',
          ),
        ],
      );
    });
  }

  Widget _buildHeaderSection() {
    return Obx(() {
      final options = controller.routeOptions;
      final vehicleLabel =
          _vehicleDisplayName(controller.selectedVehicle.value);
      final title = controller.destinationLabel.value.isNotEmpty
          ? controller.destinationLabel.value
          : 'Petunjuk arah';

      if (options.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xffF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicleLabel,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xff6B7280),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Rute belum tersedia. Pilih tujuan untuk melihat estimasi perjalanan.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xff64748B),
                ),
              ),
            ],
          ),
        );
      }

      final selectedIndex =
          controller.selectedRouteIndex.value.clamp(0, options.length - 1);
      final selectedOption = options[selectedIndex];
      final adjustedDurationSeconds =
          controller.adjustedDuration(selectedOption.duration);
      final durationText = _formatDuration(adjustedDurationSeconds);
      final distanceText =
          RouteController.formatDistance(selectedOption.distance);
      final trafficDelayMinutes =
          controller.adjustedDuration(selectedOption.trafficDelay) / 60;
      final trafficLabel = trafficDelayMinutes > 0.4
          ? '+${trafficDelayMinutes.toStringAsFixed(1)} mnt kemacetan'
          : 'Lalu lintas lancar';

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleLabel,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xff6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  distanceText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildMetricBadge(
                  icon: Icons.schedule,
                  label: durationText,
                  accentColor: const Color(0xff1D4ED8),
                ),
                _buildMetricBadge(
                  icon: Icons.traffic,
                  label: trafficLabel,
                  accentColor: const Color(0xff0F766E),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVehicleSelector() {
    return Obx(() {
      final selected = controller.selectedVehicle.value.isEmpty
          ? 'motorcycle'
          : controller.selectedVehicle.value;
      const modes = [
        _VehicleMode('motorcycle', 'Motor', Icons.motorcycle),
        _VehicleMode('car', 'Mobil', Icons.directions_car),
      ];

      return Row(
        children: List.generate(modes.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const SizedBox(width: 12);
          }

          final mode = modes[index ~/ 2];
          final bool isSelected = selected == mode.key;
          return Expanded(
            child: _buildVehicleTile(
              vehicle: mode.key,
              label: mode.label,
              icon: mode.icon,
              selected: isSelected,
            ),
          );
        }),
      );
    });
  }

  Widget _buildVehicleTile({
    required String vehicle,
    required String label,
    required IconData icon,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => controller.updateVehicle(vehicle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xff1D4ED8) : const Color(0xffE2E8F0),
            width: selected ? 1.6 : 1.0,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x1A1D4ED8),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xff1F2937),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xff1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteVariants() {
    return Obx(() {
      final options = controller.routeOptions;
      if (options.isEmpty) {
        return const SizedBox.shrink();
      }

      final selectedIndex =
          controller.selectedRouteIndex.value.clamp(0, options.length - 1);
      final adjustedDurations = options
          .map((option) => controller.adjustedDuration(option.duration))
          .toList(growable: false);
      final double baseDuration = adjustedDurations
          .reduce((value, element) => math.min(value, element));

      return SizedBox(
        height: 184,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final bool isSelected = index == selectedIndex;
            final String title =
                index == 0 ? 'Rute tercepat' : 'Rute ${index + 1}';
            final double adjustedDurationSeconds = adjustedDurations[index];
            final String durationText =
                _formatDuration(adjustedDurationSeconds);
            final String distanceText =
                RouteController.formatDistance(option.distance);
            final String comparisonLabel = _formatDifferenceLabel(
              adjustedDurationSeconds,
              baseDuration,
              index,
            );
            final double trafficDelayMinutes =
                controller.adjustedDuration(option.trafficDelay) / 60;
            final String? trafficLabel = trafficDelayMinutes > 0.4
                ? 'Traffic +${trafficDelayMinutes.toStringAsFixed(1)} mnt'
                : null;

            return GestureDetector(
              onTap: () => controller.selectRouteByIndex(
                index,
                showFeedback: true,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 230,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xffEEF2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff1D4ED8)
                        : const Color(0xffE2E8F0),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                  boxShadow: [
                    if (isSelected)
                      const BoxShadow(
                        color: Color(0x1A1D4ED8),
                        blurRadius: 18,
                        offset: Offset(0, 12),
                      )
                    else
                      const BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff1F2937),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff1D4ED8).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Dipilih',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff1D4ED8),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      durationText,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      distanceText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xff4B5563),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (comparisonLabel.isNotEmpty)
                      Text(
                        comparisonLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xff6B7280),
                        ),
                      ),
                    if (trafficLabel != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            size: 16,
                            color: Color(0xffDC2626),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              trafficLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xffDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 12),
        ),
      );
    });
  }

  Widget _buildSectionHeader() {
    return Obx(() {
      final stepCount = controller.routeSteps.length;
      final nextInstruction = controller.nextInstruction.value;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Langkah perjalanan',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff111827),
                  ),
                ),
                if (nextInstruction.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      nextInstruction,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xff2563EB),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '$stepCount langkah',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xff6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRouteList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.routeSteps.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Tidak ada langkah rute',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
        );
      }

      final children = <Widget>[];

      for (var i = 0; i < controller.routeSteps.length; i++) {
        if (i != 0) {
          children.add(Divider(
            height: 1,
            color: Colors.grey.shade200,
          ));
        }
        children.add(_buildStepItem(controller.routeSteps[i], i));
      }

      return Column(children: children);
    });
  }

  Widget _buildStepItem(Map<String, dynamic> step, int index) {
    final instruction = step['instruction']?.toString() ?? '';
    final streetName = step['name']?.toString() ?? '';
    final distance = RouteController.formatDistance(
      (step['distance'] as num?)?.toDouble() ?? 0,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: index == 0 ? 4 : 12,
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xffE0E7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: RouteController.getManeuverIcon(
                step['type']?.toString(),
                step['modifier']?.toString(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff111827),
                  ),
                ),
                if (streetName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      streetName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xff6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    distance,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xff2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge({
    required IconData icon,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  String _vehicleDisplayName(String key) {
    switch (key) {
      case 'car':
        return 'Perjalanan Mobil';
      case 'motorcycle':
        return 'Perjalanan Motor';
      default:
        return 'Perjalanan';
    }
  }

  String _formatDuration(double seconds) {
    final totalMinutes = (seconds / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      if (minutes == 0) {
        return '$hours jam';
      }
      return '$hours jam $minutes menit';
    }

    return '$minutes menit';
  }

  String _formatDifferenceLabel(
    double routeDuration,
    double baseDuration,
    int index,
  ) {
    if (index == 0) {
      return '';
    }

    final diffSeconds = routeDuration - baseDuration;
    if (diffSeconds.abs() < 120) {
      return 'Perkiraan durasi serupa';
    }

    final diffMinutes = (diffSeconds.abs() / 60).round();
    if (diffSeconds > 0) {
      return 'Lebih lambat $diffMinutes menit';
    }
    return 'Lebih cepat $diffMinutes menit';
  }
}

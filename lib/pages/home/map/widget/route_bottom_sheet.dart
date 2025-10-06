import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';

class RouteBottomSheetWidget extends StatelessWidget {
  RouteBottomSheetWidget({super.key});

  final RouteController controller = Get.find<RouteController>();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      initialChildSize: 0.3,
      minChildSize: 0.2,
      builder: (context, scrollController) {
        final mediaQuery = MediaQuery.of(context);
        final bottomPadding =
            mediaQuery.viewPadding.bottom + mediaQuery.viewInsets.bottom + 24;

        return SafeArea(
          top: false,
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
                      _buildSummaryCard(),
                      const SizedBox(height: 12),
                      _buildVehicleSelector(),
                      const SizedBox(height: 8),
                      _buildRouteChoices(),
                      const SizedBox(height: 12),
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

  Widget _buildSummaryCard() {
    return Obx(() {
      final durationSeconds = controller.totalRouteDuration.value;
      final distanceMeters = controller.totalRouteDistance.value;
      final remaining = controller.remainingRouteDuration.value;
      final isActive = controller.routeActive.value;
      final durationText =
          durationSeconds > 0 ? _formatDuration(durationSeconds) : '-';
      final distanceText = distanceMeters > 0
          ? RouteController.formatDistance(distanceMeters)
          : '-';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xffEEF2FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff1D4ED8).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color(0xff1D4ED8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Rute diperbarui',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    durationText,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff1D4ED8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perjalanan $distanceText',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xff4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xffE0E7FF)),
              ),
              child: Text(
                remaining <= 0
                    ? 'Sedang di lokasi'
                    : 'Sisa ${_formatDuration(remaining)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xff1D4ED8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVehicleSelector() {
    return Obx(() {
      final selected = controller.selectedVehicle.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildVehicleChip(
            vehicle: 'motorcycle',
            icon: Icons.motorcycle,
            label: 'Motor',
            selected: selected == 'motorcycle' || selected.isEmpty,
          ),
          const SizedBox(width: 12),
          _buildVehicleChip(
            vehicle: 'car',
            icon: Icons.directions_car,
            label: 'Mobil',
            selected: selected == 'car',
          ),
        ],
      );
    });
  }

  Widget _buildVehicleChip({
    required String vehicle,
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : const Color(0xff1F2937),
          ),
          const SizedBox(width: 6),
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
      pressElevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      shape: const StadiumBorder(),
      selected: selected,
      selectedColor: const Color(0xff1D4ED8),
      backgroundColor: const Color(0xffF3F4F6),
      side: BorderSide(
        color: selected ? const Color(0xff1D4ED8) : Colors.transparent,
      ),
      onSelected: (_) => controller.updateVehicle(vehicle),
    );
  }

  Widget _buildRouteChoices() {
    return Obx(() {
      final options = controller.routeOptions;
      if (options.length <= 1) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 68,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 50),
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = controller.selectedRouteIndex.value == index;
            final label = index == 0 ? 'Tercepat' : 'Rute ${index + 1}';
            final subtitle = _formatDifferenceLabel(
              option.duration,
              options.first.duration,
              index,
            );

            return GestureDetector(
              onTap: () =>
                  controller.selectRouteByIndex(index, showFeedback: true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xffE0ECFF) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff3B82F6)
                        : const Color(0xffE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: Color(0x263B82F6),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xff1D4ED8)
                            : const Color(0xff1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDuration(option.duration)} • ${RouteController.formatDistance(option.distance)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xff4B5563),
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xff6B7280),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
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
    if (diffSeconds.abs() < 30) {
      return 'Perkiraan sama';
    }

    final diffMinutes = (diffSeconds.abs() / 60).round();
    final sign = diffSeconds > 0 ? '+' : '-';
    return '$sign$diffMinutes menit dari tercepat';
  }
}

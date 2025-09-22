import 'package:flutter/material.dart';

class RadarMarker extends StatefulWidget {
  final Color? color;
  final String? status;
  final double size;

  const RadarMarker({super.key, this.color, this.status, this.size = 24.0});

  @override
  _RadarMarkerState createState() => _RadarMarkerState();
}

class _RadarMarkerState extends State<RadarMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorForStatus(String? status) {
    if (status == null) return Colors.red;
    final s = status.toString().trim().toLowerCase();
    if (s.contains('siaga 3') || s == '3') return Colors.red;
    if (s.contains('siaga 2') || s == '2') return Colors.orange;
    if (s.contains('siaga 1') || s == '1') return Colors.orange;
    if (s.contains('sedang')) return Colors.orange;
    if (s.contains('normal') || s.isEmpty || s == 'n/a') return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? _colorForStatus(widget.status);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1 + _controller.value * 0.5;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: effectiveColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

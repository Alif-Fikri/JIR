import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;

class RouteLineConfig {
  RouteLineConfig({
    required this.id,
    required this.points,
    required this.color,
    required this.width,
    this.opacity,
  });

  final String id;
  final List<ll.LatLng> points;
  final Color color;
  final double width;
  final double? opacity;
}

class JirMapView extends StatefulWidget {
  const JirMapView({
    super.key,
    this.initialLocation,
    this.initialZoom = 14,
    this.userLocation,
    this.userHeading,
    this.markers,
    this.markerData,
    this.routeLines,
    this.waypoints,
    this.destination,
    this.navigationMode = false,
    this.onMarkerTap,
    this.onMarkerDataTap,
    this.onRouteTap,
    this.onMapCreated,
    this.enableMyLocation = false,
    this.autoFitBounds = true,
  });

  final ll.LatLng? initialLocation;
  final double initialZoom;
  final ll.LatLng? userLocation;
  final double? userHeading;
  final List<ll.LatLng>? markers;
  final List<Map<String, dynamic>>? markerData;
  final List<RouteLineConfig>? routeLines;
  final List<ll.LatLng>? waypoints;
  final ll.LatLng? destination;
  final bool navigationMode;
  final void Function(int index)? onMarkerTap;
  final void Function(Map<String, dynamic> data)? onMarkerDataTap;
  final ValueChanged<String>? onRouteTap;
  final void Function(GoogleMapController controller)? onMapCreated;
  final bool enableMyLocation;
  final bool autoFitBounds;

  @override
  State<JirMapView> createState() => _JirMapViewState();
}

class _JirMapViewState extends State<JirMapView> with TickerProviderStateMixin {
  GoogleMapController? _controller;
  Timer? _radarTimer;
  int _radarTick = 0;
  BitmapDescriptor? _cctvIcon;
  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? _userIcon;
  final Map<String, BitmapDescriptor> _cachedMarkerIcons = {};
  final Set<String> _generatingMarkerIcons = {};
  final Map<String, int> _markerIndex = {};
  final Map<String, Map<String, dynamic>> _markerDataById = {};

  static const ll.LatLng _fallbackLocation = ll.LatLng(-6.2000, 106.8167);
  static const double _defaultRadarRadius = 160;
  static const List<double> _radarPhases = [0.15, 0.45, 0.75, 1.0];
  static const double _navigationTiltDefault = 55.0;
  static const double _navigationMinZoom = 16.0;

  @override
  void initState() {
    super.initState();
    _startOrStopRadar();
    _loadDefaultIcons();
  }

  @override
  void didUpdateWidget(covariant JirMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startOrStopRadar();
    final bool navModeChanged =
        widget.navigationMode != oldWidget.navigationMode;
    final bool headingChanged =
        (widget.userHeading ?? 0) != (oldWidget.userHeading ?? 0);
    final bool locationChanged = oldWidget.userLocation != widget.userLocation;

    if (widget.userLocation != null &&
        (navModeChanged ||
            (widget.navigationMode && (headingChanged || locationChanged)))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _moveCameraToUser();
      });
    }

    final bool shouldAutoFit = widget.autoFitBounds && !widget.navigationMode;
    if (shouldAutoFit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.userLocation != null) {
          if (locationChanged) {
            _moveCameraToUser();
          }
        } else {
          _fitToBounds();
        }
      });
    }
  }

  @override
  void dispose() {
    _radarTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _startOrStopRadar() {
    final hasFloodMarkers = (widget.markerData ?? [])
        .any((data) => _markerTypeOf(data) == _MarkerType.flood);
    if (hasFloodMarkers) {
      if (_radarTimer == null || !_radarTimer!.isActive) {
        _radarTimer?.cancel();
        _radarTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
          if (!mounted) return;
          setState(() {
            _radarTick = (_radarTick + 1) % _radarPhases.length;
          });
        });
      }
    } else {
      _radarTimer?.cancel();
      _radarTimer = null;
      _radarTick = 0;
    }
  }

  Future<void> _loadDefaultIcons() async {
    try {
      _cctvIcon = await _createCctvMarkerIcon();
    } catch (_) {
      _cctvIcon = await _loadAssetIcon('assets/images/cctv.png', size: 110);
    }
    try {
      _destinationIcon = await _createDestinationMarkerIcon();
    } catch (_) {
      _destinationIcon =
          await _loadAssetIcon('assets/images/location.png', size: 88);
    }
    try {
      _userIcon = await _createUserMarkerIcon();
    } catch (_) {
      _userIcon =
          await _loadAssetIcon('assets/images/icon_motor.png', size: 120);
    }
    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> _createUserMarkerIcon() async {
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    final haloPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.25, haloPaint);

    final pointerPath = Path()
      ..moveTo(center.dx, center.dy - size * 0.38)
      ..lineTo(center.dx - size * 0.18, center.dy - size * 0.08)
      ..lineTo(center.dx + size * 0.18, center.dy - size * 0.08)
      ..close();

    final pointerShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pointerPath.shift(const Offset(0, 2)), pointerShadowPaint);

    final pointerPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pointerPath, pointerPaint);

    final coreShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        center.translate(0, size * 0.05), size * 0.15, coreShadowPaint);

    final corePaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.25, corePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.045;
    canvas.drawCircle(center, size * 0.25, borderPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createCctvMarkerIcon() async {
    const size = 104.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    final outerPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size * 0.55,
        [const Color(0xFF0D47A1), const Color(0xFF42A5F5)],
      );
    canvas.drawCircle(center, size * 0.46, outerPaint);

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06;
    canvas.drawCircle(center, size * 0.46, strokePaint);

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.32, innerPaint);

    final icon = Icons.videocam_rounded;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size * 0.40,
          color: Colors.white,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createDestinationMarkerIcon() async {
    const size = 120.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2.4);

    final shadowPath = Path()
      ..moveTo(center.dx, size * 0.95)
      ..quadraticBezierTo(center.dx + size * 0.18, size * 0.82,
          center.dx + size * 0.08, center.dy)
      ..arcToPoint(
        Offset(center.dx - size * 0.08, center.dy),
        radius: Radius.circular(size * 0.28),
        clockwise: false,
      )
      ..quadraticBezierTo(
          center.dx - size * 0.18, size * 0.82, center.dx, size * 0.95)
      ..close();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath.shift(const Offset(0, 2)), shadowPaint);

    final pointerPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx, size * 0.15),
        Offset(center.dx, size * 0.9),
        [
          const ui.Color.fromARGB(255, 148, 0, 0),
          const ui.Color.fromARGB(255, 185, 28, 28)
        ],
      );
    canvas.drawPath(shadowPath, pointerPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.045;
    canvas.drawPath(shadowPath, borderPaint);

    final innerCircleCenter = Offset(center.dx, size * 0.38);
    final innerShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(innerCircleCenter.translate(0, size * 0.05), size * 0.18,
        innerShadowPaint);

    final innerCirclePaint = Paint()
      ..shader = ui.Gradient.radial(
        innerCircleCenter,
        size * 0.22,
        [const ui.Color.fromARGB(255, 148, 0, 0), Colors.white],
      );
    canvas.drawCircle(innerCircleCenter, size * 0.22, innerCirclePaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  BitmapDescriptor? _generateStatusCircleIcon(String cacheKey, Color color) {
    final cached = _cachedMarkerIcons[cacheKey];
    if (cached != null) return cached;
    if (_generatingMarkerIcons.contains(cacheKey)) return null;
    _generatingMarkerIcons.add(cacheKey);
    _createStatusMarkerIcon(color).then((descriptor) {
      if (!mounted) return;
      setState(() {
        _cachedMarkerIcons[cacheKey] = descriptor;
      });
    }).whenComplete(() => _generatingMarkerIcons.remove(cacheKey));
    return null;
  }

  Future<BitmapDescriptor> _createStatusMarkerIcon(Color color) async {
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center.translate(0, 3), size * 0.32, shadowPaint);

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.08;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final radius = size * 0.32;
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, strokePaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _loadAssetIcon(String asset, {int size = 96}) async {
    try {
      final descriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size.square(120)),
        asset,
      );
      return descriptor;
    } catch (_) {
      try {
        final image = await _loadImage(asset, size: size);
        return BitmapDescriptor.fromBytes(image);
      } catch (_) {
        return BitmapDescriptor.defaultMarker;
      }
    }
  }

  Future<Uint8List> _loadImage(String asset, {int size = 96}) async {
    final data = await DefaultAssetBundle.of(context).load(asset);
    final list = Uint8List.view(data.buffer);
    final codec = await ui.instantiateImageCodec(
      list,
      targetHeight: size,
      targetWidth: size,
    );
    final frame = await codec.getNextFrame();
    final bytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw Exception('Failed to encode marker image');
    }
    return bytes.buffer.asUint8List();
  }

  LatLng _toLatLng(ll.LatLng value) => LatLng(value.latitude, value.longitude);

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final markerPositions = widget.markers ?? const [];
    final markerData = widget.markerData ?? const [];
    _markerIndex.clear();
    _markerDataById.clear();

    for (var i = 0; i < markerPositions.length; i++) {
      final position = markerPositions[i];
      final markerId = 'poi_$i';
      _markerIndex[markerId] = i;
      Map<String, dynamic>? data;
      if (i < markerData.length) {
        data = markerData[i];
        _markerDataById[markerId] = data;
      }
      markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: _toLatLng(position),
          icon: _iconForData(data),
          onTap: () => _handleMarkerTap(markerId),
        ),
      );
    }

    for (var i = 0; i < (widget.waypoints?.length ?? 0); i++) {
      final wp = widget.waypoints![i];
      markers.add(
        Marker(
          markerId: MarkerId('waypoint_$i'),
          position: _toLatLng(wp),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    final dest = widget.destination;
    if (dest != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _toLatLng(dest),
          icon: _destinationIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 0.92),
        ),
      );
    }

    final user = widget.userLocation;
    if (user != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _toLatLng(user),
          icon: _userIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          rotation: widget.userHeading ?? 0,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    return markers;
  }

  void _handleMarkerTap(String markerId) {
    final data = _markerDataById[markerId];
    if (data != null && widget.onMarkerDataTap != null) {
      widget.onMarkerDataTap!(data);
      return;
    }
    final index = _markerIndex[markerId];
    if (index != null && widget.onMarkerTap != null) {
      widget.onMarkerTap!(index);
    }
  }

  BitmapDescriptor _iconForData(Map<String, dynamic>? data) {
    if (data == null) {
      return BitmapDescriptor.defaultMarker;
    }
    final type = _markerTypeOf(data);
    switch (type) {
      case _MarkerType.cctv:
        return _cctvIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case _MarkerType.flood:
        final color = _resolveMarkerColor(data);
        final cacheKey = 'flood_${color.value}';
        final cached = _cachedMarkerIcons[cacheKey];
        if (cached != null) return cached;
        final existing = _generateStatusCircleIcon(cacheKey, color);
        return existing ??
            BitmapDescriptor.defaultMarkerWithHue(
              _colorToHue(color),
            );
      case _MarkerType.other:
        final color = _resolveMarkerColor(data);
        final cacheKey = 'status_${color.value}';
        final cached = _cachedMarkerIcons[cacheKey];
        if (cached != null) return cached;
        final generated = _generateStatusCircleIcon(cacheKey, color);
        return generated ??
            BitmapDescriptor.defaultMarkerWithHue(
              _colorToHue(color),
            );
    }
  }

  _MarkerType _markerTypeOf(Map<String, dynamic> data) {
    final type = data['markerType']?.toString().toLowerCase();
    if (type == 'cctv') return _MarkerType.cctv;
    if (type == 'flood' || data.containsKey('STATUS_SIAGA')) {
      return _MarkerType.flood;
    }
    return _MarkerType.other;
  }

  double _colorToHue(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.hue;
  }

  Set<Polyline> _buildPolylines() {
    final lines = widget.routeLines ?? const [];
    return lines.map((config) {
      final polylineColor = config.opacity != null
          ? config.color.withOpacity(config.opacity!.clamp(0, 1))
          : config.color;
      return Polyline(
        polylineId: PolylineId(config.id),
        points: config.points.map(_toLatLng).toList(growable: false),
        width: config.width.round().clamp(1, 12),
        color: polylineColor,
        consumeTapEvents: widget.onRouteTap != null,
        onTap: widget.onRouteTap != null
            ? () => widget.onRouteTap!(config.id)
            : null,
      );
    }).toSet();
  }

  Set<Circle> _buildRadarCircles() {
    final data = widget.markerData ?? const [];
    if (data.isEmpty || _radarTimer == null) {
      return const <Circle>{};
    }

    final circles = <Circle>{};
    final baseMarkers = widget.markers ?? const [];
    final phase = _radarPhases[_radarTick];
    for (var i = 0; i < data.length && i < baseMarkers.length; i++) {
      final markerData = data[i];
      if (_markerTypeOf(markerData) != _MarkerType.flood) continue;
      final color = _resolveMarkerColor(markerData);
      final latLng = baseMarkers[i];
      final growth = 1.0 + 0.7 * phase;
      final radius = _defaultRadarRadius * growth;
      final opacityTail = (1.0 - phase).clamp(0.1, 0.9);
      circles.add(
        Circle(
          circleId: CircleId('radar_$i'),
          center: _toLatLng(latLng),
          radius: radius,
          fillColor: color.withOpacity(0.16 * opacityTail),
          strokeColor: color.withOpacity(0.45 * opacityTail),
          strokeWidth: 1,
        ),
      );
    }
    return circles;
  }

  Color _resolveMarkerColor(Map<String, dynamic>? data) {
    if (data == null) return const Color(0xFFE53935);
    final statusRaw = data['STATUS_SIAGA']?.toString() ?? '';
    final status = statusRaw.toLowerCase().trim();
    if (status.isEmpty) return const Color(0xFF4CAF50);

    if (_statusContains(status, const ['siaga 1', 'merah', 'bahaya'])) {
      return const Color(0xFFD32F2F);
    }
    if (_statusContains(status, const ['siaga 2', 'jingga', 'orange'])) {
      return const Color(0xFFFF9800);
    }
    if (_statusContains(status, const ['siaga 3', 'kuning', 'yellow'])) {
      return const Color(0xFFFFC107);
    }
    if (_statusContains(status, const ['normal', 'hijau', 'green'])) {
      return const Color(0xFF4CAF50);
    }
    return const Color(0xFFE53935);
  }

  bool _statusContains(String status, List<String> keywords) {
    for (final keyword in keywords) {
      if (status.contains(keyword)) return true;
    }
    return false;
  }

  CameraPosition _initialCamera() {
    final target = widget.initialLocation ??
        widget.userLocation ??
        widget.destination ??
        _fallbackLocation;
    final double bearing =
        widget.navigationMode ? _normalizeBearing(widget.userHeading ?? 0) : 0;
    final double tilt = widget.navigationMode ? _navigationTiltDefault : 0;
    return CameraPosition(
      target: _toLatLng(target),
      zoom: widget.initialZoom,
      bearing: bearing,
      tilt: tilt,
    );
  }

  Future<void> _fitToBounds() async {
    final controller = _controller;
    if (controller == null) return;

    final boundsPoints = <LatLng>[];
    void addPoint(ll.LatLng? point) {
      if (point != null) boundsPoints.add(_toLatLng(point));
    }

    for (final p in widget.routeLines ?? const []) {
      boundsPoints.addAll(p.points.map(_toLatLng));
    }
    for (final p in widget.markers ?? const []) {
      addPoint(p);
    }
    addPoint(widget.userLocation);
    addPoint(widget.destination);
    for (final wp in widget.waypoints ?? const []) {
      addPoint(wp);
    }

    if (boundsPoints.isEmpty) return;

    LatLngBounds bounds = _boundsFor(points: boundsPoints);
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 60);
    try {
      await controller.animateCamera(cameraUpdate);
    } catch (_) {
      await controller.moveCamera(cameraUpdate);
    }
  }

  LatLngBounds _boundsFor({required List<LatLng> points}) {
    double? minLat, maxLat, minLng, maxLng;
    for (final latLng in points) {
      minLat = math.min(minLat ?? latLng.latitude, latLng.latitude);
      maxLat = math.max(maxLat ?? latLng.latitude, latLng.latitude);
      minLng = math.min(minLng ?? latLng.longitude, latLng.longitude);
      maxLng = math.max(maxLng ?? latLng.longitude, latLng.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();
    final polylines = _buildPolylines();
    final circles = _buildRadarCircles();

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCamera(),
          myLocationEnabled:
              widget.enableMyLocation && widget.userLocation == null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          tiltGesturesEnabled: true,
          mapToolbarEnabled: false,
          markers: markers,
          polylines: polylines,
          circles: circles,
          onMapCreated: (controller) {
            _controller = controller;
            widget.onMapCreated?.call(controller);
            if (widget.autoFitBounds) {
              if (widget.userLocation != null) {
                _moveCameraToUser(useInitialZoom: true);
              } else {
                _fitToBounds();
              }
            }
          },
        ),
        Positioned(
          right: 16,
          bottom: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.enableMyLocation)
                _MapControlButton(
                  icon: Icons.my_location,
                  onPressed: _goToUserLocation,
                ),
              if (widget.enableMyLocation) const SizedBox(height: 12),
              _ZoomControls(
                onZoomIn: () => _zoomBy(1),
                onZoomOut: () => _zoomBy(-1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _zoomBy(double delta) async {
    final controller = _controller;
    if (controller == null) return;
    final update = delta > 0 ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut();
    try {
      await controller.animateCamera(update);
    } catch (_) {
      await controller.moveCamera(update);
    }
  }

  Future<void> _goToUserLocation() async {
    await _moveCameraToUser();
  }

  Future<void> _moveCameraToUser({bool useInitialZoom = false}) async {
    final controller = _controller;
    final user = widget.userLocation;
    if (controller == null || user == null) return;

    double zoomLevel = widget.initialZoom;
    if (!useInitialZoom) {
      try {
        final currentZoom = await controller.getZoomLevel();
        if (currentZoom.isFinite) {
          zoomLevel = currentZoom.clamp(12.0, 20.0).toDouble();
        }
      } catch (_) {
        zoomLevel = widget.initialZoom;
      }
    }

    if (widget.navigationMode && zoomLevel < _navigationMinZoom) {
      zoomLevel = _navigationMinZoom;
    }

    zoomLevel = zoomLevel.clamp(12.0, 20.0).toDouble();

    double bearing = 0;
    double tilt = 0;
    if (widget.navigationMode) {
      bearing = _normalizeBearing(widget.userHeading ?? 0);
      tilt = _navigationTiltDefault;
    }

    final update = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _toLatLng(user),
        zoom: zoomLevel.toDouble(),
        bearing: bearing,
        tilt: tilt,
      ),
    );
    try {
      await controller.animateCamera(update);
    } catch (_) {
      await controller.moveCamera(update);
    }
  }

  double _normalizeBearing(double value) {
    double bearing = value % 360;
    if (bearing < 0) {
      bearing += 360;
    }
    return bearing;
  }
}

enum _MarkerType { flood, cctv, other }

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapControlButton(
          icon: Icons.add,
          onPressed: onZoomIn,
        ),
        const SizedBox(height: 8),
        _MapControlButton(
          icon: Icons.remove,
          onPressed: onZoomOut,
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          height: 48,
          width: 48,
          child: Icon(
            icon,
            size: 26,
            color: const Color(0xFF424242),
          ),
        ),
      ),
    );
  }
}

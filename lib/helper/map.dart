import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;

import 'package:smartcitys/pages/home/map/route_controller.dart';

class ReusableMap extends StatefulWidget {
  final LatLng initialLocation;
  final List<Marker> markers;
  final LatLng? userLocation;
  final LatLng? destination;
  final List<LatLng>? routePoints;
  final Function(MapController)? onMapCreated;
  final double? userHeading;

  const ReusableMap({
    super.key,
    required this.initialLocation,
    required this.markers,
    this.onMapCreated,
    this.userLocation,
    this.destination,
    this.routePoints,
    this.userHeading,
  });

  @override
  ReusableMapState createState() => ReusableMapState();
}

class ReusableMapState extends State<ReusableMap>
    with AutomaticKeepAliveClientMixin {
  late final MapController _mapController;
  LatLng? _lastUserLocation;
  bool _shouldUpdateMap = true;
  bool _isRouteInitialized = false;
  List<LatLng>? _lastRoutePoints;
  final distance = const Distance();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initMapPosition();
  }

  void _initMapPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(widget.initialLocation, 15.0);
    });
  }

  @override
  void didUpdateWidget(ReusableMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.userLocation != null && _lastUserLocation != null) {
      final dist = distance(widget.userLocation!, _lastUserLocation!);
      if (dist > 10) {
        _shouldUpdateMap = true;
        _lastUserLocation = widget.userLocation;

        _filterPassedRoutePoints();
        _checkIfDestinationReached();
      }
    }

    if (!_isRouteInitialized ||
        !_areRoutesEqual(widget.routePoints, _lastRoutePoints)) {
      _lastRoutePoints = widget.routePoints;
      _updateMapBounds();
      _isRouteInitialized = true;
    }
  }

  bool _areRoutesEqual(List<LatLng>? a, List<LatLng>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _updateMapBounds() {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(widget.routePoints!);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(100),
          maxZoom: 17.0,
        ),
      );
    });
  }

  void _updateMapPosition() {
    if (widget.userLocation != null) {
      _mapController.move(widget.userLocation!, _mapController.camera.zoom);
    }
  }

  void _filterPassedRoutePoints() {
    if (widget.userLocation == null || widget.routePoints == null) return;

    // Jarak minimum agar dianggap "sudah dilewati" (misal: 10 meter)
    const double thresholdDistance = 10.0;

    setState(() {
      widget.routePoints!.removeWhere((point) {
        return distance(widget.userLocation!, point) < thresholdDistance;
      });
    });
  }

  void _checkIfDestinationReached() {
    if (widget.userLocation == null || widget.destination == null) return;

    // Jarak agar dianggap "sampai tujuan" (misal: 20 meter)
    const double destinationThreshold = 20.0;

    if (distance(widget.userLocation!, widget.destination!) <
        destinationThreshold) {
      setState(() {
        widget.routePoints!.clear(); // Hapus semua rute
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_shouldUpdateMap && widget.userLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMapPosition();
        _shouldUpdateMap = false;
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag |
                    InteractiveFlag.flingAnimation |
                    InteractiveFlag.pinchMove |
                    InteractiveFlag.pinchZoom,
              ),
            ),
            children: [
              _buildTileLayer(),
              _buildMarkers(),
              _buildRouteLayer(),
            ],
          ),
        );
      },
    );
  }

  TileLayer _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c'],
      tileBuilder: (context, tileWidget, tile) {
        return AnimatedOpacity(
          opacity: 0.9,
          duration: const Duration(milliseconds: 300),
          child: tileWidget,
        );
      },
    );
  }

  MarkerLayer _buildMarkers() {
    final markers = [
      ...widget.markers,
      if (widget.userLocation != null)
        Marker(
          point: widget.userLocation!,
          width: 48,
          height: 48,
          child: const _UserLocationMarker(),
        ),
      if (widget.destination != null)
        Marker(
          point: widget.destination!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
          ),
        ),
    ];

    return MarkerLayer(
      markers: markers,
      rotate: false,
    );
  }

  Widget _buildRouteLayer() {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) {
      return const SizedBox.shrink();
    }

    return PolylineLayer(
      polylines: [
        Polyline(
          points: widget.routePoints!,
          strokeWidth: 4.0,
          color: Colors.blue,
          borderColor: Colors.blue.withOpacity(0.5),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentHeading = Get.find<RouteController>().userHeading.value;
      return Stack(
        alignment: Alignment.center,
        children: [
          // Arah mata angin
          Transform.rotate(
            angle: (currentHeading * (pi / 180)),
            child: CustomPaint(
              size: const Size(48, 48),
              painter: _DirectionLightPainter(),
            ),
          ),
          // Icon tengah
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      );
    });
  }
}

class _DirectionLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    size = const Size(48, 48);

    final path = ui.Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

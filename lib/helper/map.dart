import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
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

    if (widget.userLocation != null &&
        _lastUserLocation != null &&
        distance(widget.userLocation!, _lastUserLocation!) > 10) {
      _shouldUpdateMap = true;
      _lastUserLocation = widget.userLocation;
    }

    if (widget.routePoints != _lastRoutePoints) {
      _lastRoutePoints = widget.routePoints;
      _updateMapBounds();
    }
  }

  void _updateMapBounds() {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(widget.routePoints!);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  void _updateMapPosition() {
    if (widget.userLocation != null) {
      _mapController.move(widget.userLocation!, _mapController.camera.zoom);
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
      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
          child: _UserLocationMarker(
          ),
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
          Transform.rotate(
            angle: currentHeading * (pi / 180) - pi/2,
            child: CustomPaint(
              size: const Size(48, 48),
              painter: _DirectionLightPainter(),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const Icon(
              Icons.navigation,
              color: Colors.white,
              size: 16,
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
      ..shader = RadialGradient(
        colors: [
          Colors.blue.withOpacity(0.15),
          Colors.blue.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));

    final path = ui.Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ),
        -pi / 2 - pi / 12,
        pi / 6,
        true,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

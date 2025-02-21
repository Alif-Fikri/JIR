import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReusableMap extends StatefulWidget {
  final LatLng initialLocation;
  final List<Marker> markers;
  final LatLng? userLocation;
  final LatLng? destination;
  final List<LatLng>? routePoints;
  final Function(MapController)? onMapCreated;

  const ReusableMap({
    super.key,
    required this.initialLocation,
    required this.markers,
    this.onMapCreated,
    this.userLocation,
    this.destination,
    this.routePoints,
  });

  @override
  _ReusableMapState createState() => _ReusableMapState();
}

class _ReusableMapState extends State<ReusableMap> {
  late final MapController _mapController;
  LatLng? _lastUserLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    widget.onMapCreated?.call(_mapController);
    _initMapPosition();
  }

  void _initMapPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetLocation = widget.userLocation ?? widget.initialLocation;
      _mapController.move(targetLocation, 13.0);
    });
  }

  @override
  void didUpdateWidget(ReusableMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userLocation != _lastUserLocation) {
      _updateMapPosition();
      _lastUserLocation = widget.userLocation;
    }
  }

  void _updateMapPosition() {
    if (widget.userLocation != null) {
      _mapController.move(widget.userLocation!, _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.initialLocation,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
          ),
          MarkerLayer(
            markers: [
              ...widget.markers,
              if (widget.userLocation != null)
                Marker(
                  point: widget.userLocation!,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              if (widget.destination != null)
                Marker(
                  point: widget.destination!,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
            ],
          ),
          if (widget.routePoints?.isNotEmpty ?? false)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: widget.routePoints!,
                  strokeWidth: 4.0,
                  color: Colors.blue.withOpacity(0.7),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

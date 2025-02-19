import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReusableMap extends StatefulWidget {
  final LatLng initialLocation;
  final List<Marker> markers;
  final Function(LatLng)? onLocationChanged;
  final Function(MapController)? onMapCreated;

  const ReusableMap({
    super.key,
    required this.initialLocation,
    required this.markers,
    this.onLocationChanged,
    this.onMapCreated,
  });

  @override
  _ReusableMapState createState() => _ReusableMapState();
}

class _ReusableMapState extends State<ReusableMap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialLocation,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: widget.markers),
      ],
    );
  }
}

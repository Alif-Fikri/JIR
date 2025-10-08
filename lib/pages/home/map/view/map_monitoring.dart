import 'package:JIR/helper/map.dart';
import 'package:JIR/helper/mapbox_config.dart';
import 'package:JIR/pages/home/cctv/cctv_webview.dart';
import 'package:JIR/pages/home/cctv/model/cctv_location.dart';
import 'package:JIR/pages/home/map/controller/flood_controller.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';
import 'package:JIR/pages/home/map/widget/detail_flood.dart';
import 'package:JIR/pages/home/map/widget/menu_map_monitoring.dart';
import 'package:JIR/pages/home/map/widget/route_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

class MapMonitoring extends StatelessWidget {
  final RouteController _routeController = Get.put(RouteController());
  final TextEditingController _searchController = TextEditingController();
  final FloodController controller = Get.find<FloodController>();
  final FocusNode _searchFocusNode = FocusNode();
  final List<CCTVLocation> _cctvLocations =
      List<CCTVLocation>.from(defaultCctvLocations);

  MapMonitoring({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Peta',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildSearchSection(),
          _buildFloatingButton(),
          _buildFloodMonitoringButton(),
          _buildOptimizedRouteInfo(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GetX<FloodController>(
      builder: (floodController) {
        if (floodController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final floodDataList = floodController.floodData.toList();
        final floodPositions = floodDataList.map((item) {
          final lat =
              double.tryParse(item['LATITUDE']?.toString() ?? '0.0') ?? 0.0;
          final lng =
              double.tryParse(item['LONGITUDE']?.toString() ?? '0.0') ?? 0.0;
          return ll.LatLng(lat, lng);
        }).toList();

        final cctvPositions =
            _cctvLocations.map((loc) => loc.coordinates).toList();

        final floodMarkerData = floodDataList.map((item) {
          final copy = Map<String, dynamic>.from(item);
          copy['markerType'] = 'flood';
          return copy;
        }).toList();

        final cctvMarkerData = _cctvLocations
            .map((loc) => {
                  'markerType': 'cctv',
                  'name': loc.name,
                  'url': loc.url,
                  'latitude': loc.coordinates.latitude,
                  'longitude': loc.coordinates.longitude,
                })
            .toList();

        final combinedMarkers = [...floodPositions, ...cctvPositions];
        final combinedMarkerData = [...floodMarkerData, ...cctvMarkerData];

        return GetX<RouteController>(
          builder: (routeController) {
            final routePoints = routeController.routePoints
                .map((point) => ll.LatLng(point.latitude, point.longitude))
                .toList();
            final routeOptions = routeController.routeOptions;
            final selectedRouteIndex = routeController.selectedRouteIndex.value;
            final trimmedActivePolyline = routeController.activeRoutePolyline
                .map((point) => ll.LatLng(point.latitude, point.longitude))
                .toList();
            final List<RouteLineConfig> routeLines = [];
            const Color selectedRouteColor = Color(0xFF2563EB);
            const Color alternativeRouteColor = Color(0xFFF97316);

            for (var i = 0; i < routeOptions.length; i++) {
              final option = routeOptions[i];
              final isSelected = i == selectedRouteIndex;
              final optionPoints = option.points
                  .map((point) => ll.LatLng(point.latitude, point.longitude))
                  .toList();
              final pointsForRender =
                  isSelected && trimmedActivePolyline.length >= 2
                      ? trimmedActivePolyline
                      : optionPoints;

              final config = RouteLineConfig(
                id: option.id,
                points: pointsForRender,
                color: isSelected ? selectedRouteColor : alternativeRouteColor,
                width: isSelected ? 6.5 : 4.5,
                opacity: isSelected ? 0.95 : 0.65,
              );

              if (isSelected) {
                routeLines.add(config);
              } else {
                routeLines.insert(0, config);
              }
            }

            final waypointPositions = routeController.optimizedWaypoints
                .map((point) => ll.LatLng(point.latitude, point.longitude))
                .toList();
            final userLoc = routeController.userLocation.value;
            final userPosition = userLoc != null
                ? ll.LatLng(userLoc.latitude, userLoc.longitude)
                : null;
            final dest = routeController.destination.value;
            final destinationPoint =
                dest != null ? ll.LatLng(dest.latitude, dest.longitude) : null;

            return MapboxReusableMap(
              accessToken: MapboxConfig.accessToken,
              styleUri: mb.MapboxStyles.MAPBOX_STREETS,
              initialLocation: userPosition,
              markers: combinedMarkers,
              markerData: combinedMarkerData,
              userLocation: userPosition,
              routePoints: routePoints,
              routeLines: routeLines,
              waypoints: waypointPositions,
              destination: destinationPoint,
              onMarkerDataTap: _handleMarkerDataTap,
              onRouteTap: (routeId) => routeController.selectRouteById(
                routeId,
                showFeedback: true,
              ),
              enable3DBuildings: true,
              autoPitchOnRoute: true,
              navigationPitch: 45,
              navigationZoom: 15.5,
            );
          },
        );
      },
    );
  }

  Widget _buildOptimizedRouteInfo() {
    return Positioned(
      top: 80,
      right: 16,
      child: GetX<RouteController>(
        builder: (controller) {
          if (controller.optimizedWaypoints.isEmpty) {
            return const SizedBox();
          }

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rute Dioptimalkan',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.optimizedWaypoints.length} waypoint',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          _buildSearchBar(),
          Obx(() => _buildSearchSuggestions()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Masukkan tujuan...',
          hintStyle: GoogleFonts.inter(
            color: Colors.black,
            fontStyle: FontStyle.italic,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (_, value, __) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                onPressed: () {
                  _clearSearch();
                  _searchFocusNode.unfocus();
                },
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        onTap: () {
          if (_searchController.text.isEmpty) {
            _searchFocusNode.requestFocus();
          }
        },
        onChanged: (value) {
          if (value.isEmpty) {
            _routeController.clearRoute();
            _searchFocusNode.unfocus();
          }
          _routeController.handleSearch(value);
        },
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Visibility(
      visible: _routeController.searchSuggestions.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: _routeController.searchSuggestions.length,
          itemBuilder: (context, index) => _buildSuggestionItem(index),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(int index) {
    final suggestion = _routeController.searchSuggestions[index];
    final lat = double.tryParse(suggestion['lat']?.toString() ?? '');
    final lon = double.tryParse(suggestion['lon']?.toString() ?? '');

    return ListTile(
      leading: const Icon(Icons.location_on, size: 20),
      title: Text(suggestion['display_name'] ?? 'Lokasi'),
      subtitle: _buildSuggestionSubtitle(lat, lon, suggestion),
      onTap: () => _handleSuggestionTap(lat, lon, suggestion),
    );
  }

  Widget _buildSuggestionSubtitle(
      double? lat, double? lon, dynamic suggestion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((suggestion['place_name'] ?? '').toString().isNotEmpty)
          Text(
            suggestion['place_name'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        if (lat != null && lon != null)
          Builder(
            builder: (context) {
              final distance = _routeController.userLocation.value != null
                  ? RouteController.calculateDistance(
                        _routeController.userLocation.value!,
                        ll.LatLng(lat, lon),
                      ) /
                      1000
                  : null;

              return distance != null
                  ? Text(
                      '${distance.toStringAsFixed(1)} km dari lokasi Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        Text(
          RouteController.getLocationType(suggestion['type']),
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  void _handleSuggestionTap(double? lat, double? lon, dynamic suggestion) {
    if (lat == null || lon == null) return;

    _searchController.text = suggestion['display_name'] ?? '';
    _routeController.searchSuggestions.clear();
    _routeController.selectDestinationSuggestion(suggestion);
    _searchFocusNode.unfocus();
  }

  Widget _buildFloatingButton() {
    return Positioned(
      left: 28,
      bottom: 120,
      child: GetX<RouteController>(
        builder: (controller) {
          return Visibility(
            visible: controller.routeSteps.isNotEmpty,
            child: FloatingActionButton(
              heroTag: 'route-directions-fab',
              backgroundColor: const Color(0xff45557B),
              child: const Icon(Icons.directions, color: Colors.white),
              onPressed: () => Get.bottomSheet(
                RouteBottomSheetWidget(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                isDismissible: false,
                enableDrag: false,
                barrierColor: Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloodMonitoringButton() {
    return const Positioned(bottom: 50, left: 20, child: AnimatedMenuButton());
  }

  void _clearSearch() {
    _searchController.clear();
    _routeController.searchSuggestions.clear();
    _routeController.clearRoute();
  }

  void _handleMarkerDataTap(Map<String, dynamic> item) {
    final markerType = item['markerType']?.toString().toLowerCase();
    if (markerType == 'cctv') {
      _showCctvDetails(item);
      return;
    }
    _showDisasterDetails(item);
  }

  void _showDisasterDetails(Map<String, dynamic> item) {
    final lat = double.tryParse(item['LATITUDE'].toString());
    final lng = double.tryParse(item['LONGITUDE'].toString());

    if (lat == null || lng == null) {
      Get.snackbar("Error", "Koordinat tidak valid");
      return;
    }

    Get.bottomSheet(
      DisasterBottomSheet(
        location: item['NAMA_PINTU_AIR'] ?? 'Lokasi Tidak Diketahui',
        status: item['STATUS_SIAGA']?.toString() ?? 'N/A',
        onViewLocation: () {
          Get.back();
          final context = Get.context;
          if (context != null) {
            controller.navigateToFloodMonitoring(context, item);
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCctvDetails(Map<String, dynamic> item) {
    final name = (item['name'] ?? 'CCTV').toString();
    final url = item['url']?.toString();
    final latitude = item['latitude'];
    final longitude = item['longitude'];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Detail CCTV',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff45557B),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.videocam,
                  color: Color(0xff45557B), size: 28),
              title: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: (latitude is num && longitude is num)
                  ? Text(
                      'Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}',
                      style: GoogleFonts.inter(fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: url == null
                    ? null
                    : () {
                        Get.back();
                        Get.to(() => CCTVWebView(url: url));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff45557B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_new),
                label: Text(
                  'Buka CCTV',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

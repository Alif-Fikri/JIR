import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartcitys/helper/map.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/pages/home/map/detail_flood.dart';
import 'package:smartcitys/pages/home/map/flood_controller.dart';
import 'package:smartcitys/pages/home/map/route_controller.dart';
import 'package:smartcitys/services/flood_service/flood_api_service.dart';

class MapMonitoring extends StatelessWidget {
  final RouteController _routeController = Get.put(RouteController());
  final TextEditingController _searchController = TextEditingController();

  MapMonitoring({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ],
      ),
    );
  }

  Widget _buildMap() {
    final FloodController controller =
        Get.find<FloodController>();
return Obx(() {
  final floodData = controller.floodData;
  print("Flood Data Loaded: ${floodData.length} items");

  if (floodData.isEmpty) {
    return const Center(child: CircularProgressIndicator());
  }


      final markers = floodData.map((item) {
        final lat =
            double.tryParse(item['LATITUDE']?.toString() ?? '0.0') ?? 0.0;
        final lng =
            double.tryParse(item['LONGITUDE']?.toString() ?? '0.0') ?? 0.0;

        return Marker(
          point: LatLng(lat, lng),
          child: GestureDetector(
            onTap: () => controller.showDisasterDetails(Get.context!, item),
            child: const Icon(
              Icons.radio_button_checked,
              color: Colors.red,
              size: 30,
            ),
          ),
        );
      }).toList();

      return ReusableMap(
        initialLocation: const LatLng(-6.2088, 106.8456),
        markers: markers,
        userLocation: _routeController.userLocation.value,
        userHeading: _routeController.userHeading.value,
        destination: _routeController.destination.value,
        routePoints: _routeController.routePoints,
      );
    });
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
        decoration: InputDecoration(
          hintText: 'Masukkan tujuan...',
          hintStyle: GoogleFonts.inter(
            color: Colors.black,
            fontStyle: FontStyle.italic,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          suffixIcon: Obx(() {
            if (_routeController.searchSuggestions.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        onChanged: _routeController.handleSearch,
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
        if (lat != null && lon != null)
          Obx(() {
            final distance = _routeController.userLocation.value != null
                ? RouteController.calculateDistance(
                      _routeController.userLocation.value!,
                      LatLng(lat, lon),
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
          }),
        Text(
          RouteController.getLocationType(suggestion['type']),
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  void _handleSuggestionTap(double? lat, double? lon, dynamic suggestion) {
    if (lat == null || lon == null) return;

    _routeController.destination(LatLng(lat, lon));
    _searchController.text = suggestion['display_name'] ?? '';
    _routeController.searchSuggestions.clear();
    _routeController.fetchRoute();
  }

  Widget _buildFloatingButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Obx(() => Visibility(
            visible: _routeController.routeSteps.isNotEmpty,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              child: const Icon(Icons.directions, color: Colors.white),
              onPressed: () => Get.bottomSheet(RouteBottomSheetContent()),
            ),
          )),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _routeController.searchSuggestions.clear();
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
        status: item['STATUS_SIAGA'] ?? 'N/A',
        onViewLocation: () => Get.to(
            () => FloodMonitoringPage(initialLocation: LatLng(lat, lng))),
      ),
      isScrollControlled: true,
    );
  }
}

class _VehicleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteBottomSheetContent extends StatelessWidget {
  final RouteController controller = Get.find<RouteController>();

  RouteBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildVehicleSelector(),
          _buildRouteList(),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Petunjuk Arah",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(Get.context!),
        ),
      ],
    );
  }

  Widget _buildVehicleSelector() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _VehicleOption(
            icon: Icons.motorcycle,
            label: "Motor",
            isSelected: controller.selectedVehicle.value == 'motorcycle',
            onTap: () => controller.updateVehicle('motorcycle'),
          ),
          _VehicleOption(
            icon: Icons.directions_car,
            label: "Mobil",
            isSelected: controller.selectedVehicle.value == 'car',
            onTap: () => controller.updateVehicle('car'),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteList() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          itemCount: controller.routeSteps.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) =>
              _buildStepItem(controller.routeSteps[index]),
        );
      }),
    );
  }

  Widget _buildStepItem(Map<String, dynamic> step) {
    return ListTile(
      leading: RouteController.getManeuverIcon(step['type'], step['modifier']),
      title: Text(
        step['instruction'],
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue[800],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Jalan: ${step['name']}",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          Text(
            RouteController.formatDistance(step['distance']),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () => Navigator.pop(Get.context!),
        child: Text(
          'Tutup',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

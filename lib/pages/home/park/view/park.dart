import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/home/park/controller/park_controller.dart';

class ParkPage extends StatefulWidget {
  const ParkPage({super.key});

  @override
  State<ParkPage> createState() => _ParkPageState();
}

class _ParkPageState extends State<ParkPage> {
  final ParksController _controller = Get.put(ParksController());
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  late Timer _timer;
  int _currentPage = 0;
  bool _isScrollingForward = true;

  @override
  void initState() {
    super.initState();
    _controller.getUserLocation();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isScrollingForward) {
        if (_currentPage < _controller.nearbyParks.length - 1) {
          _currentPage++;
        } else {
          _isScrollingForward = false;
          _currentPage--;
        }
      } else {
        if (_currentPage > 0) {
          _currentPage--;
        } else {
          _isScrollingForward = true;
          _currentPage++;
        }
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage.isNotEmpty) {
            return Center(child: Text(_controller.errorMessage.value));
          }
          return SingleChildScrollView(
            child: Column(children: [
              Stack(
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/park.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'GoGreen',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 150,
                    left: 30,
                    right: 30,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(50),
                      shadowColor: Colors.grey.withOpacity(0.5),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _filterParks(value),
                        style: GoogleFonts.inter(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search . . .',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontStyle: FontStyle.italic),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 5.0, top: 5.0, left: 18.0, right: 15.0),
                            child: Image.asset(
                              'assets/images/search.png',
                              height: 25,
                              width: 25,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEDEDED),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff45557B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 20),
                        child: Text(
                          'Yuk, Cari Udara Segar',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 136,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  border: Border.all(
                                    color: const Color(0xff45557B),
                                    width: 1.0, 
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, bottom: 30, top: 20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/park.png',
                                  width: 163,
                                  height: 53,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Image.asset(
                                'assets/images/icon_park.png',
                                width: 143,
                                height: 122,
                              ),
                            ),
                            Positioned(
                              left: 15,
                              bottom: 15,
                              child: Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff45557B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.white, size: 14),
                                        const SizedBox(width: 6),
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            _controller.currentAddress.value,
                                            style: GoogleFonts.inter(
                                              fontSize: 8,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSectionTitle('Rekomendasi Taman Terdekat'),
                    _buildNearbyParks(),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildSectionTitle('Rekomendasi Taman Lainnya'),
                    _buildOtherParks(),
                  ],
                ),
              ),
            ]),
          );
        }));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 30),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyParks() {
    return SizedBox(
      height: 180,
      child: Obx(
        () => _controller.nearbyParks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : PageView.builder(
                controller: _pageController,
                itemCount: _controller.nearbyParks.length,
                itemBuilder: (context, index) {
                  final park = _controller.nearbyParks[index];
                  final distance = _controller.calculateDistanceInMeters(
                      park.latitude, park.longitude);

                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                      }

                      return Opacity(
                        opacity: value.clamp(0.5, 1.0),
                        child: Transform.scale(
                          scale: value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildParkItem(
                      park.name,
                      _controller.formatDistance(distance),
                      park.street ?? 'Alamat tidak tersedia',
                      park.latitude,
                      park.longitude,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildParkItem(
      String name, String distance, String address, double lat, double lon) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.parkdetail, arguments: {
        'name': name,
        'distance': distance,
        'address': address,
        'lat': lat,
        'lon': lon,
      }),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/park.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    distance,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherParks() {
    return Obx(
      () => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _controller.otherParks.take(20).length,
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        itemBuilder: (context, index) {
          final park = _controller.otherParks[index];
          final distance = _controller.calculateDistanceInMeters(
              park.latitude, park.longitude);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xff45557B)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/park.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(park.name,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff45557B))),
                        const SizedBox(height: 4),
                        Text(_controller.formatDistance(distance),
                            style: GoogleFonts.inter(
                                fontSize: 10, color: const Color(0xff45557B))),
                        const SizedBox(height: 2),
                        Text(park.street ?? 'Alamat tidak tersedia',
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _filterParks(String query) {}
}

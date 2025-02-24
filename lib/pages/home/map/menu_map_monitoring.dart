import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartcitys/pages/home/map/flood_controller.dart';

class AnimatedMenuButton extends StatefulWidget {
  const AnimatedMenuButton({super.key});

  @override
  State<AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.water,
      'label': 'Status Banjir',
      'onPressed': () => Get.find<FloodController>().showFloodMonitoringSheet(),
    },
    {
      'icon': Icons.history,
      'label': 'testing',
      'onPressed': () => print('Riwayat diklik'),
    },
    {
      'icon': Icons.history,
      'label': 'testing',
      'onPressed': () => print('Pengaturan diklik'),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70 + (_menuItems.length * 65).toDouble(),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ..._menuItems.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _isExpanded ? (70 + (index * 60)) : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isExpanded ? 1.0 : 0.0,
                child: FloatingActionButton(
                  heroTag: null,
                  mini: false,
                  backgroundColor: Colors.grey[400],
                  onPressed: () {
                    _toggleMenu();
                    item['onPressed']();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'],
                        color: Colors.black,
                        size: 18,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['label'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          // Main Button
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * (pi / 2),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: const Color(0xff45557B),
                        onPressed: _toggleMenu,
                        child: Icon(
                          _isExpanded ? Icons.close : Icons.menu,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

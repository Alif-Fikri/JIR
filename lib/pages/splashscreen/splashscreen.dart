import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool showBlueBackground = false;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        if (_waveController.value >= 0.5 && mounted) {
          setState(() {});
        }
      });

    _startSplashSequence();
  }

  void _startSplashSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    _waveController.forward();
    setState(() => showBlueBackground = true);
    await Future.delayed(const Duration(seconds: 2));
    Get.off(() => AppRoutes.home);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_waveController.value < 0.5)
            Center(
              child: Image.asset(
                'assets/images/jir_logo.png',
                width: 200,
                height: 200,
              ),
            ),
          if (showBlueBackground)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Positioned(
                  right: -screenSize.width * 0.5,
                  bottom: -screenSize.height * 0.5,
                  child: Transform.rotate(
                    angle: 9.0,
                    child: ClipPath(
                      clipper: ComplexWaveClipper(_waveController.value),
                      child: Container(
                        width: screenSize.width * 2,
                        height: screenSize.height * 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0.0, 0.76],
                            colors: [
                              Color(0xFFA0CFEE),
                              Color(0xFF004E92),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          if (_waveController.value >= 0.5)
            Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/jir_logo2.png',
                    width: 200,
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'JIR',
                      style: GoogleFonts.koHo(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class ComplexWaveClipper extends CustomClipper<Path> {
  final double progress;

  ComplexWaveClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final heightProgress = size.height * progress;

    path.lineTo(0, heightProgress - 80);

    path.cubicTo(
      size.width * 0.1,
      heightProgress + 20,
      size.width * 0.2,
      heightProgress - 100,
      size.width * 0.3,
      heightProgress - 20,
    );

    path.cubicTo(
      size.width * 0.4,
      heightProgress + 60,
      size.width * 0.5,
      heightProgress - 100,
      size.width * 0.6,
      heightProgress - 10,
    );

    path.cubicTo(
      size.width * 0.7,
      heightProgress + 40,
      size.width * 0.8,
      heightProgress - 120,
      size.width,
      heightProgress - 40,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(ComplexWaveClipper oldClipper) =>
      oldClipper.progress != progress;
}

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

  late final AnimationController _waveController;
  late final Animation<double> firstLogoOpacity;
  late final Animation<double> secondLogoOpacity;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    firstLogoOpacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    secondLogoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => showBlueBackground = true);
    await _waveController.forward();
    await Future.delayed(const Duration(seconds: 2));
    Get.offNamed(AppRoutes.home);
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
          FadeTransition(
            opacity: firstLogoOpacity,
            child: Center(
              child: Image.asset(
                'assets/images/jir_logo7.png',
                width: 200,
                height: 200,
              ),
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
          FadeTransition(
            opacity: secondLogoOpacity,
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/jir_logo2.png',
                    width: 200,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
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
    final h = size.height * progress;

    path.lineTo(0, h - 80);
    path.cubicTo(size.width * 0.1, h + 20, size.width * 0.2, h - 100,
        size.width * 0.3, h - 20);
    path.cubicTo(size.width * 0.4, h + 60, size.width * 0.5, h - 100,
        size.width * 0.6, h - 10);
    path.cubicTo(size.width * 0.7, h + 40, size.width * 0.8, h - 120,
        size.width, h - 40);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(ComplexWaveClipper old) => old.progress != progress;
}

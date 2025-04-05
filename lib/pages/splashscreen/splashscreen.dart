import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartcitys/app/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showSecondSplash = false;

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  void _startSplashSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      showSecondSplash = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    Get.off(() => AppRoutes.home);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: showSecondSplash ? const Color(0xFF0069C0) : Colors.white,
    body: AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: showSecondSplash
          ? Stack(
              key: const ValueKey(2),
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
            )
          : Center(
              key: const ValueKey(1),
              child: Image.asset(
                'assets/images/jir_logo.png',
                width: 200,
                height: 200,
              ),
            ),
    ),
  );
}
}
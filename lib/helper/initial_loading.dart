import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smartcitys/app/routes/app_routes.dart';
import 'package:smartcitys/helper/no_connection.dart';
import 'package:smartcitys/services/internet_service/internet_service.dart';


class InitialLoadingPage extends StatefulWidget {
  const InitialLoadingPage({super.key});

  @override
  State<InitialLoadingPage> createState() => _InitialLoadingPageState();
}

class _InitialLoadingPageState extends State<InitialLoadingPage> {
  final InternetService _internetService = Get.find();

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
  }

  void _checkInitialConnection() async {
    await Future.delayed(const Duration(seconds: 2));
    final isConnected = await _internetService.checkConnection();

    if (isConnected) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      _internetService.lastRoute = AppRoutes.home;
      Get.offAll(() => const NoInternetPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset('assets/lottie/loading.json'),
      ),
    );
  }
}

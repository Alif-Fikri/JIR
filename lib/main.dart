import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartcitys/app/routes/app_routes.dart';
import 'package:smartcitys/bindings/auth_binding.dart';
import 'package:smartcitys/bindings/initial_binding.dart';
import 'package:smartcitys/bindings/report_binding.dart';
import 'package:smartcitys/pages/auth/login.dart';
import 'package:smartcitys/pages/auth/signup.dart';
import 'package:smartcitys/pages/home/chat/chatbot.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/pages/home/home.dart';
import 'package:smartcitys/pages/home/park/park.dart';
import 'package:smartcitys/pages/profile/profile.dart';
import 'package:smartcitys/helper/loading.dart';
import 'package:smartcitys/services/internet_service/internet_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
  Get.put(InternetService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JIR App',
      theme: ThemeData(),
      initialRoute: AppRoutes.initial,
      initialBinding: InitialBinding(),
      getPages: AppRoutes.getPages,
      unknownRoute: GetPage(
        name: '/home',
        page: () => const HomePage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/bindings/initial_binding.dart';
import 'package:JIR/services/internet_service/internet_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
  // Get.put(InternetService());
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
    );
  }
}

import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/bindings/initial_binding.dart';
import 'package:JIR/services/notification_service/background_handler.dart';
import 'package:JIR/services/notification_service/notification_service.dart';
import 'package:JIR/services/notification_service/workmanager_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await Hive.openBox('notifications');
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await NotificationService.I.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    "floodTaskUnique",
    floodTaskName,
    frequency: const Duration(minutes: 15), 
    initialDelay: const Duration(seconds: 10),
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JIR App',
      theme: ThemeData(),
      initialRoute: AppRoutes.initial,
      initialBinding: InitialBinding(),
      getPages: AppRoutes.getPages,
      navigatorKey: Get.key,
    );
  }
}

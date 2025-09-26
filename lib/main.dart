import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; 
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/bindings/initial_binding.dart';
import 'package:JIR/services/notification_service/background_handler.dart';
import 'package:JIR/services/notification_service/notification_service.dart';
import 'package:JIR/services/notification_service/workmanager_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  debugPrint('Starting app - platform: ${TargetPlatform.values}');
  FirebaseApp? app;
  try {
    debugPrint('Initializing Firebase (using DefaultFirebaseOptions)...');
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized: ${app.options.projectId}');
  } catch (e, st) {
    debugPrint('Firebase.initializeApp error: $e');
    debugPrint('$st');
    runApp(_FirebaseErrorApp(error: e.toString()));
    return;
  }

  debugPrint('Continuing init: opening Hive boxes and registering services');
  await Hive.openBox('authBox');
  await Hive.openBox('notifications');
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await NotificationService.I.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  try {
    await Workmanager().registerPeriodicTask(
      "floodTaskUnique",
      floodTaskName,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10),
    );
  } catch (e) {
    debugPrint('Workmanager registerPeriodicTask error: $e');
  }

  runApp(const MyApp());
}

class _FirebaseErrorApp extends StatelessWidget {
  final String error;
  const _FirebaseErrorApp({required this.error});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Init error')),
        body: Center(child: Text('Firebase init failed:\n$error')),
      ),
    );
  }
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

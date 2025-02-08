import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:smartcitys/bindings/auth_binding.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/pages/auth/login.dart';
import 'package:smartcitys/pages/auth/signup.dart';
import 'package:smartcitys/pages/home/chat/chatbot.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/pages/profile/profile.dart';

class AppRoutes {
  static const initial = login;
  
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const profile = '/profile';
  static const flood = '/flood';
  static const chatbot = '/chatbot';
  
  static final getPages = [
    GetPage(
      name: login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: signup,
      page: () => SignupPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: home,
      page: () => Menu(),
    ),
    GetPage(
      name: profile,
      page: () => ProfilePage(),
    ),
    GetPage(
      name: flood,
      page: () => FloodMonitoringPage(),
    ),
    GetPage(
      name: chatbot,
      page: () => ChatbotOpeningPage(),
    ),
  ];
}
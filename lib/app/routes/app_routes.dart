import 'package:get/get.dart';
import 'package:smartcitys/bindings/auth_binding.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/pages/auth/login.dart';
import 'package:smartcitys/pages/auth/signup.dart';
import 'package:smartcitys/pages/home/chat/chatbot.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/pages/profile/profile.dart';
import 'package:smartcitys/helper/loading.dart';

class AppRoutes {
  static const initial = loading;

  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const profile = '/profile';
  static const flood = '/flood';
  static const chatbot = '/chatbot';
  static const loading = '/loading';

  static final getPages = [
    GetPage(
      name: login,
      page: () => LoginPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: signup,
      page: () => SignupPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: loading,
      page: () => LoadingPage(),
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

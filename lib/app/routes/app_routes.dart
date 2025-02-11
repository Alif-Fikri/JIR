import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartcitys/bindings/auth_binding.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/pages/auth/login.dart';
import 'package:smartcitys/pages/auth/signup.dart';
import 'package:smartcitys/pages/home/chat/chatbot.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/pages/home/park/park.dart';
import 'package:smartcitys/pages/profile/profile.dart';
import 'package:smartcitys/helper/loading.dart';
import 'package:smartcitys/helper/no_connection.dart';

class AppRoutes {
  static const initial = park;
  //auth
  static const login = '/login';
  static const signup = '/signup';
  //navbar
  static const home = '/home';
  static const profile = '/profile';
  static const notification = '/notification';
  //home
  static const flood = '/flood';
  static const chatbot = '/chatbot';
  static const cctv = '/cctv';
  static const park = '/park';
  static const crowd = '/crowd';
  //profile
  static const about = '/about';
  static const termsOfService = '/terms-of-service';
  static const privacyPolicy = '/privacy-policy';
  static const settings = '/settings';
  static const logout = '/logout';
  static const changePassword = '/change-password';
  static const deleteAccount = '/delate-account';
  //widget
  static const loading = '/loading';
  static const noInternet = '/no-internet';

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
      name: noInternet,
      page: () => NoInternetPage(),
    ),
    GetPage(
      name: home,
      page: () => Menu(),
    ),
    GetPage(
      name: park,
      page: () => ParkPage(),
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

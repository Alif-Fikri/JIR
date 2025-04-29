import 'package:get/get.dart';
import 'package:JIR/bindings/auth_binding.dart';
import 'package:JIR/bindings/home_binding.dart';
import 'package:JIR/bindings/report_binding.dart';
import 'package:JIR/helper/menu.dart';
import 'package:JIR/pages/activity/activity.dart';
import 'package:JIR/pages/auth/view/login.dart';
import 'package:JIR/pages/auth/view/signup.dart';
import 'package:JIR/pages/home/cctv/cctv_monitoring.dart';
import 'package:JIR/pages/home/chat/chatbot.dart';
import 'package:JIR/pages/home/crowd/crowd_monitoring.dart';
import 'package:JIR/pages/home/flood/view/flood_monitoring.dart';
import 'package:JIR/pages/home/map/view/map_monitoring.dart';
import 'package:JIR/pages/home/park/view/park.dart';
import 'package:JIR/pages/home/park/view/park_detail.dart';
import 'package:JIR/pages/home/report/view/report.dart';
import 'package:JIR/pages/home/weather/weather.dart';
import 'package:JIR/pages/notifications/notification.dart';
import 'package:JIR/pages/profile/about.dart';
import 'package:JIR/pages/profile/privacy_policy.dart';
import 'package:JIR/pages/profile/profile.dart';
import 'package:JIR/helper/loading.dart';
import 'package:JIR/helper/no_connection.dart';
import 'package:JIR/pages/auth/view/change_password_page.dart';
import 'package:JIR/pages/auth/view/delete_acc.dart';
import 'package:JIR/pages/profile/terms_of_service.dart';
import 'package:JIR/pages/splashscreen/splashscreen.dart';

class AppRoutes {
  static const initial = splash;
  static const splash = '/splash';
  //auth
  static const login = '/login';
  static const signup = '/signup';
  //navbar
  static const home = '/home';
  static const profile = '/profile';
  static const notification = '/notification';
  static const activity = '/activity';
  //home
  static const flood = '/flood';
  static const chatbot = '/chatbot';
  static const cctv = '/cctv';
  static const park = '/park';
  static const parkdetail = '/parkdetail';
  static const crowd = '/crowd';
  static const cuaca = '/cuaca';
  static const peta = '/peta';
  static const lapor = '/lapor';
  static const report = '/report_user';
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
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
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
      name: home,
      page: () => const Menu(),
    ),
    GetPage(
      name: profile,
      page: () => ProfilePage(),
    ),
    GetPage(
      name: notification,
      page: () => const NotificationPage(),
    ),
    GetPage(
      name: notification,
      page: () => ActivityPage(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: flood,
      page: () => FloodMonitoringPage(),
    ),
    GetPage(
      name: chatbot,
      page: () => const ChatbotOpeningPage(),
    ),
    GetPage(
      name: park,
      page: () => const ParkPage(),
    ),
    GetPage(
      name: parkdetail,
      page: () => const ParkDetail(),
    ),
    GetPage(
      name: crowd,
      page: () => CrowdMonitoringPage(),
    ),
    GetPage(
      name: cuaca,
      page: () => const WeatherPage(),
    ),
    GetPage(
      name: cctv,
      page: () => CCTVPage(),
    ),
    GetPage(
      name: peta,
      page: () => MapMonitoring(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: lapor,
      page: () => ReportPage(),
      binding: ReportBinding(),
    ),
    //     GetPage(
    //   name: report,
    //   page: () => ReportUser(),
    // ),
    GetPage(
      name: about,
      page: () => const AboutPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: termsOfService,
      page: () => const TermsOfService(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: privacyPolicy,
      page: () => const PrivacyPolicy(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    //     GetPage(
    //   name: logout,
    //   page: () => LogoutDialog(),
    // ),
    GetPage(
      name: changePassword,
      page: () => ChangePasswordPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    //     GetPage(
    //   name: deleteAccount,
    //   page: () => deleteAccount(),
    // ),
    GetPage(
      name: loading,
      page: () => const LoadingPage(),
    ),
    GetPage(
      name: noInternet,
      page: () => const NoInternetPage(),
    ),
  ];
}

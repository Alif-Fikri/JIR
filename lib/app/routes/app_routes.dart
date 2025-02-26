import 'package:get/get.dart';
import 'package:smartcitys/bindings/auth_binding.dart';
import 'package:smartcitys/bindings/home_binding.dart';
import 'package:smartcitys/bindings/report_binding.dart';
import 'package:smartcitys/helper/menu.dart';
import 'package:smartcitys/pages/activity/activity.dart';
import 'package:smartcitys/pages/auth/login.dart';
import 'package:smartcitys/pages/auth/signup.dart';
import 'package:smartcitys/pages/home/cctv/cctv_monitoring.dart';
import 'package:smartcitys/pages/home/chat/chatbot.dart';
import 'package:smartcitys/pages/home/crowd/crowd_monitoring.dart';
import 'package:smartcitys/pages/home/flood/flood_monitoring.dart';
import 'package:smartcitys/pages/home/home.dart';
import 'package:smartcitys/pages/home/map/map_monitoring.dart';
import 'package:smartcitys/pages/home/park/park.dart';
import 'package:smartcitys/pages/home/report/report.dart';
import 'package:smartcitys/pages/home/report/report_user.dart';
import 'package:smartcitys/pages/home/weather/weather.dart';
import 'package:smartcitys/pages/notifications/notification.dart';
import 'package:smartcitys/pages/profile/about.dart';
import 'package:smartcitys/pages/profile/privacy_policy.dart';
import 'package:smartcitys/pages/profile/profile.dart';
import 'package:smartcitys/helper/loading.dart';
import 'package:smartcitys/helper/no_connection.dart';
import 'package:smartcitys/pages/profile/settings/change_password_page.dart';
import 'package:smartcitys/pages/profile/settings/settings_page.dart';
import 'package:smartcitys/pages/profile/terms_of_service.dart';

class AppRoutes {
  static const initial = home;
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
      page: () => Menu(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
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
      name: crowd,
      page: () => CrowdMonitoringPage(),
    ),
    GetPage(
      name: cuaca,
      page: () => WeatherPage(),
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
    ),
    GetPage(
      name: termsOfService,
      page: () => const TermsOfService(),
    ),
    GetPage(
      name: privacyPolicy,
      page: () => const PrivacyPolicy(),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
    ),
    //     GetPage(
    //   name: logout,
    //   page: () => LogoutDialog(),
    // ),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordPage(),
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

import 'dart:convert';
import 'package:JIR/bindings/initial_binding.dart';
import 'package:JIR/pages/home/chat/chatbot_text.dart';
import 'package:JIR/pages/home/report/view/report_user.dart';
import 'package:JIR/pages/home/report/widget/report_detail.dart';
import 'package:JIR/pages/home/report/widget/report_loading.dart';
import 'package:get/get.dart';
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
import 'package:JIR/pages/home/weather/view/weather.dart';
import 'package:JIR/pages/notifications/view/notification.dart';
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
  static const chatbottext = '/chatbot_text';
  static const cctv = '/cctv';
  static const park = '/park';
  static const parkdetail = '/parkdetail';
  static const crowd = '/crowd';
  static const cuaca = '/cuaca';
  static const peta = '/peta';
  static const lapor = '/lapor';
  static const report = '/report_user';
  static const reportdetail = '/reportdetail';
  static const reportForm = '/report_form';
  static const reportLoading = '/report_loading';
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
      binding: InitialBinding(),
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: signup,
      page: () => SignupPage(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: home,
      page: () => const Menu(),
      transition: Transition.fadeIn,
      binding: InitialBinding(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: profile,
      page: () => ProfilePage(),
      transition: Transition.fadeIn,
      binding: InitialBinding(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: notification,
      page: () => const NotificationPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: notification,
      page: () => ActivityPage(),
      transition: Transition.fadeIn,
      binding: ReportBinding(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: flood,
      page: () => FloodMonitoringPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: chatbot,
      page: () => const ChatbotOpeningPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
        GetPage(
      name: chatbottext,
      page: () => const ChatBotPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: park,
      page: () => const ParkPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: parkdetail,
      page: () => const ParkDetail(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: crowd,
      page: () => CrowdMonitoringPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: cuaca,
      page: () => WeatherPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: cctv,
      page: () => CCTVPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: peta,
      page: () => MapMonitoring(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: lapor,
      page: () => ReportPage(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: reportdetail,
      page: () {
        final args = Get.arguments;
        final Map<String, dynamic> report = (args is Map<String, dynamic>)
            ? args
            : (args is String)
                ? (() {
                    try {
                      final decoded = jsonDecode(args);
                      if (decoded is Map<String, dynamic>) return decoded;
                    } catch (_) {}
                    return <String, dynamic>{};
                  })()
                : <String, dynamic>{};
        return ReportDetailPage(report: report);
      },
      binding: ReportBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: reportForm,
      page: () => ReportFormPage(),
      binding: ReportBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: reportLoading,
      page: () => const ReportLoadingPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
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
      binding: InitialBinding(),
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
      binding: InitialBinding(),
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

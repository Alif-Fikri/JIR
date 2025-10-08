import 'dart:async';
import 'dart:math' as math;
import 'package:JIR/pages/auth/service/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/pages/home/main/widget/home_feature_grid.dart';
import 'package:JIR/pages/home/main/widget/home_search_bar.dart';
import 'package:JIR/pages/home/main/widget/home_warning_section.dart';
import 'package:JIR/pages/home/main/widget/news_carousel.dart';
import 'package:JIR/pages/home/main/widget/weather_card.dart';
import 'package:JIR/pages/notifications/controller/notification_controller.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController controller;
  late final NotificationController nc;
  late final RouteController _routeController;
  Timer? _fallbackTimer;

  String _username = 'Pengguna';
  String _email = '';
  bool _profileLoading = true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    nc = Get.find<NotificationController>();
    _routeController = Get.find<RouteController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fallbackTimer = Timer(const Duration(seconds: 12), () {
        try {
          if (controller.isLoading.value) {
            controller.isLoading.value = false;
            debugPrint('[HomePage] fallback: forcing isLoading = false');
          }
        } catch (e) {
          debugPrint('[HomePage] fallback error: $e');
        }
      });

      _loadProfile();

      try {
        await controller.refreshData();
      } catch (e) {
        debugPrint('[HomePage] refreshData error: $e');
      } finally {
        _fallbackTimer?.cancel();
        _fallbackTimer = null;
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final auth = Get.find<AuthService>();
      final profile = await auth.fetchProfile();
      final name = (profile['username'] ?? profile['name'] ?? '') as String?;
      final email = (profile['email'] ?? '') as String?;
      var resolvedEmail = (email ?? '').trim();
      var resolvedName = (name ?? '').trim();

      if (resolvedName.isEmpty && resolvedEmail.isNotEmpty) {
        resolvedName = resolvedEmail.split('@').first;
      }

      if (resolvedName.isEmpty) {
        resolvedName = 'Pengguna';
      }

      if (mounted) {
        setState(() {
          _username = resolvedName;
          _email = resolvedEmail;
          _profileLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[HomePage] failed to load profile: $e');
      if (mounted) {
        setState(() {
          _username = 'Pengguna';
          _email = '';
          _profileLoading = false;
        });
      }
    }
  }

  Future<void> _openSupportEmail() async {
    const supportEmail = 'jirsup.dev@gmail.com';
    final subject =
        'Permintaan Bantuan dari ${_username.isNotEmpty ? _username : 'Pengguna'}';
    final body =
        'Halo Tim Support,\n\nNama: ${_username.isNotEmpty ? _username : '-'}\nEmail: ${_email.isNotEmpty ? _email : '-'}\n\nDeskripsi masalah:\n';

    final mailtoUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    const platform = MethodChannel('jir/native/email');
    try {
      final result = await platform.invokeMethod('openEmail', {
        'to': supportEmail,
        'subject': subject,
        'body': body,
      });
      if (result == true) return;
    } on PlatformException catch (e) {
      debugPrint('[HomePage] native openEmail failed: ${e.message}');
    } catch (e) {
      debugPrint('[HomePage] native openEmail error: $e');
    }

    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        return;
      }

      final gmailWeb = Uri.https('mail.google.com', '/mail/', {
        'view': 'cm',
        'fs': '1',
        'to': supportEmail,
        'su': subject,
        'body': body,
      });
      if (await canLaunchUrl(gmailWeb)) {
        await launchUrl(gmailWeb, mode: LaunchMode.externalApplication);
        return;
      }

      if (await canLaunchUrl(Uri.parse('https://mail.google.com/'))) {
        await launchUrl(Uri.parse('https://mail.google.com/'),
            mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      debugPrint('[HomePage] _openSupportEmail error: $e');
    }

    Get.snackbar('Gagal', 'Tidak dapat membuka aplikasi email',
        snackPosition: SnackPosition.BOTTOM);
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) {
      return 'Selamat Pagi,';
    } else if (hour >= 10 && hour < 15) {
      return 'Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final headerHeight = 308.h;
    const weatherCardHeight = WeatherCard.cardHeight;
    final overlap = math.min(180.h, screenHeight * 0.22);
    final appBarHeight = 90.h;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            RefreshIndicator(
              color: Colors.white,
              backgroundColor: const Color(0xff45557B),
              onRefresh: controller.refreshData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(87.r),
                              bottomRight: Radius.circular(87.r)),
                          child: Container(
                            height: headerHeight,
                            decoration:
                                const BoxDecoration(color: Color(0xFF45557B)),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Container(
                              height: appBarHeight,
                              padding: EdgeInsets.only(
                                  left: 16.w, right: 16.w, bottom: 50.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF45557B),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(87.r),
                                    bottomRight: Radius.circular(87.r)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(50.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromRGBO(
                                              0, 0, 0, 0.25),
                                          blurRadius: 2.r,
                                          offset: Offset(0, 2.h),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/jir_logo8.png',
                                      width: 45.w,
                                      height: 45.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _greetingForNow(),
                                          style: GoogleFonts.lexend(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 5.r,
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                  offset: Offset(1.w, 1.h))
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        _profileLoading
                                            ? SizedBox(
                                                height: 18.h,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 14.w,
                                                      height: 14.w,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2.w,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      'Memuat...',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Text(
                                                _username.isNotEmpty
                                                    ? _username
                                                    : 'Pengguna',
                                                style: GoogleFonts.lexend(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                        blurRadius: 5.r,
                                                        color: Colors.black
                                                            .withOpacity(0.4),
                                                        offset:
                                                            Offset(1.w, 1.h))
                                                  ],
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _openSupportEmail,
                                    child: Container(
                                      width: 40.w,
                                      height: 40.w,
                                      margin: EdgeInsets.only(left: 8.w),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(50.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.25),
                                            blurRadius: 2.r,
                                            offset: Offset(0, 2.h),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.support_agent,
                                          color: Colors.white,
                                          size: 25.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: headerHeight - overlap,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: weatherCardHeight,
                            child: WeatherCard(controller: controller),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (weatherCardHeight - overlap) + 20.h),
                    const HomeSearchBar(),
                    HomeFeatureGrid(controller: controller),
                    SizedBox(height: 12.h),
                    Image.asset('assets/images/line2.png'),
                    SizedBox(height: 16.h),
                    HomeWarningSection(
                      homeController: controller,
                      notificationController: nc,
                    ),
                    Obx(() {
                      final hasWarnings = nc.warnings.isNotEmpty;
                      return SizedBox(height: hasWarnings ? 16.h : 0);
                    }),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Berita Terkini',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                    NewsCarousel(controller: controller),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            _buildNavigationStatusSheet(),
            Obx(() {
              final hasActiveRoute = _routeController.routeActive.value &&
                  _routeController.remainingRouteDistance.value > 0;
              final extraOffset = hasActiveRoute ? 100.h : 0.0;

              return AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) {
                  final bounce = math.sin(
                          controller.animationController.value * 2 * math.pi) *
                      5.h;
                  return Positioned(
                    bottom: 50.h + extraOffset + bounce,
                    right: 25.w,
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.chatbot),
                      child: Image.asset(
                        'assets/images/robot.png',
                        width: 70.w,
                        height: 70.w,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationStatusSheet() {
    return Obx(() {
      final isActive = _routeController.routeActive.value &&
          _routeController.remainingRouteDistance.value > 0;
      if (!isActive) {
        return const SizedBox.shrink();
      }

      final title = _routeController.destinationLabel.value.isNotEmpty
          ? _routeController.destinationLabel.value
          : 'Perjalanan aktif';
      final subtitle = _routeController.destinationAddress.value;
      final distanceText = RouteController.formatDistance(
        _routeController.remainingRouteDistance.value,
      );
      final durationText = _formatDuration(
        _routeController.remainingRouteDuration.value,
      );
      final instruction = _routeController.nextInstruction.value;

      return Positioned(
        left: 16.w,
        right: 16.w,
        bottom: 16.h,
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.peta),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffE2E8F0),
                    ),
                    child: const Icon(
                      Icons.navigation_outlined,
                      color: Color(0xff1E293B),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff0F172A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$distanceText • $durationText',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xff475569),
                          ),
                        ),
                        if (instruction.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            instruction,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: const Color(0xff2563EB),
                            ),
                          ),
                        ] else if (subtitle.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: const Color(0xff94A3B8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: _cancelActiveRoute,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x11000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xff334155),
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xff94A3B8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  String _formatDuration(double seconds) {
    if (seconds <= 0) {
      return 'Tiba sebentar lagi';
    }

    final totalMinutes = (seconds / 60).round();
    if (totalMinutes <= 1) {
      return 'Sekitar 1 menit';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours jam $minutes menit';
    }
    if (hours > 0) {
      return '$hours jam';
    }
    return '$totalMinutes menit';
  }

  void _cancelActiveRoute() {
    if (!_routeController.routeActive.value) {
      return;
    }
    _routeController.clearRoute();
    Get.snackbar(
      'Perjalanan dibatalkan',
      'Rute aktif telah dihentikan.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

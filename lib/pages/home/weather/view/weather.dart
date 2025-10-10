import 'package:JIR/pages/home/weather/controller/weather_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/weather/widget/diagonal_container.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/pages/home/weather/widget/weather_helper.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration period;
  const Shimmer(
      {super.key,
      required this.child,
      this.period = const Duration(milliseconds: 1200)});
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final double slide = (_ctrl.value * 2) - 1;
        final gradient = LinearGradient(
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment(-1.0 - slide, 0),
          end: Alignment(1.0 - slide, 0),
        );
        return ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class WeatherPage extends StatelessWidget {
  WeatherPage({super.key});
  final WeatherController controller = Get.put(WeatherController());
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) return 'Selamat Pagi,';
    if (hour >= 10 && hour < 15) return 'Selamat Siang,';
    if (hour >= 15 && hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  List<Shadow> _textShadows() => [
        const Shadow(
            color: Colors.black45, offset: Offset(0, 2), blurRadius: 4),
        const Shadow(
            color: Colors.black26, offset: Offset(0, 1), blurRadius: 1),
      ];
  String _hourLabelFor(DateTime dt) {
    final now = DateTime.now();
    final diff =
        dt.difference(DateTime(now.year, now.month, now.day, now.hour)).inHours;
    if (diff == 0) return 'Sekarang';
    if (diff < 0) return '${-diff} jam lalu';
    return '$diff jam lagi';
  }

  int _floorHourEpochSeconds(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, dt.hour)
            .millisecondsSinceEpoch ~/
        1000;
  }

  Widget _buildHourlyShimmerList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(width: 12.w),
      itemBuilder: (_, __) => Shimmer(
        child: Container(
          width: 90.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryShimmerList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(width: 12.w),
      itemBuilder: (_, __) => Shimmer(
        child: Container(
          width: 90.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPredictionList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff355469), width: 1.w),
            borderRadius: BorderRadius.circular(50.r),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '-',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: const Color(0xff355469),
                ),
              ),
              SizedBox(height: 5.h),
              Image.asset(
                'assets/images/Cuaca Smart City Icon-02.png',
                width: 40.w,
                height: 35.h,
              ),
              SizedBox(height: 5.h),
              Text(
                '-',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: const Color(0xff355469),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyHistoryList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff355469), width: 1.w),
            borderRadius: BorderRadius.circular(50.r),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '-',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: const Color(0xff355469),
                ),
              ),
              SizedBox(height: 5.h),
              Image.asset(
                'assets/images/Cuaca Smart City Icon-05.png',
                width: 36.w,
                height: 32.h,
              ),
              SizedBox(height: 5.h),
              Text(
                '-',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: const Color(0xff355469),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerSkeleton() {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 260.h,
            child: Stack(
              children: [
                const DiagonalContainer(),
                Positioned.fill(
                  child: ClipPath(
                    clipper: DiagonalClipper(),
                    child: Shimmer(
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(Get.context!).padding.top + 16.w,
                    left: 16.w,
                    right: 16.w,
                    bottom: 35.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Shimmer(
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Shimmer(
                              child: Container(
                                height: 18.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Shimmer(
                        child: Container(
                          width: 140.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Shimmer(
                              child: Container(
                                height: 150.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Shimmer(
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Shimmer(
                                  child: Container(
                                    height: 28.h,
                                    width: 120.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Shimmer(
                                  child: Container(
                                    height: 24.h,
                                    width: 160.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Shimmer(
                        child: Container(
                          width: 160.w,
                          height: 22.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 110.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, __) => Shimmer(
                        child: Container(
                          width: 84.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemCount: 6,
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Shimmer(
                        child: Container(
                          width: 150.w,
                          height: 22.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 110.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, __) => Shimmer(
                        child: Container(
                          width: 84.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemCount: 6,
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Shimmer(
                      child: Container(
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    height: 110.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, __) => Shimmer(
                        child: Container(
                          width: 230.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemCount: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.loading.value) {
          return _buildShimmerSkeleton();
        }
        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }
        final greeting = _greeting();
        final username = controller.username.value.isNotEmpty
            ? controller.username.value
            : 'Pengguna';
        final location = controller.location.value;
        final tempRaw = controller.temperature.value;
        final parsedTemp = double.tryParse(tempRaw.replaceAll(',', '.'));
        final mainTempDisplay = parsedTemp != null
            ? '${parsedTemp.toStringAsFixed(1)}° C'
            : (tempRaw.isNotEmpty ? tempRaw : '-');
        final rangeDisplay = controller.temperatureRange.value;
        final description = controller.description.value;
        final weatherIcon = controller.weatherIcon.value;
        final background = controller.backgroundImage.value;
        final today = DateTime.now();
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des'
        ];
        final days = List<DateTime>.generate(
            7,
            (i) => DateTime(today.year, today.month, today.day)
                .add(Duration(days: i)));
        final now = DateTime.now();
        final nowHourEpoch = _floorHourEpochSeconds(now);
        return SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  const DiagonalContainer(),
                  if (background.isNotEmpty)
                    Positioned.fill(
                      child: ClipPath(
                        clipper: DiagonalClipper(),
                        child: Image.asset(
                          background,
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.srcOver,
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16.w,
                      left: 16.w,
                      right: 16.w,
                      bottom: 35.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, size: 22.sp),
                              color: Colors.white,
                              onPressed: () => Navigator.pop(context),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lexend(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  shadows: _textShadows(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '$greeting $username',
                          style: GoogleFonts.lexend(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: _textShadows(),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Image.asset(
                                  weatherIcon,
                                  key: ValueKey<String>(weatherIcon),
                                  width: 320.w,
                                  height: 150.h,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    mainTempDisplay,
                                    style: GoogleFonts.lexend(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: _textShadows(),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    description,
                                    style: GoogleFonts.lexend(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      shadows: _textShadows(),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    rangeDisplay,
                                    style: GoogleFonts.lexend(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      shadows: _textShadows(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Center(
                          child: Text(
                            'Prediksi Cuaca',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 110.h,
                        child: Obx(() {
                          if (controller.hourlyLoading.value) {
                            return _buildHourlyShimmerList();
                          }
                          final list = controller.hourlyWindow;
                          if (list.isEmpty) {
                            return _buildEmptyPredictionList();
                          }
                          final itemCount = list.length > 12 ? 12 : list.length;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: itemCount,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            itemBuilder: (context, index) {
                              final item = list[index];
                              final dt = DateTime.fromMillisecondsSinceEpoch(
                                  (item['dt'] as int) * 1000);
                              final label = _hourLabelFor(dt);
                              final temp = (item['temp'] is num)
                                  ? '${(item['temp'] as num).toDouble().toStringAsFixed(1)}°'
                                  : item['temp'].toString();
                              final desc = item['description'] as String? ?? '';
                              final rawDesc =
                                  item['rawDescription'] as String? ?? desc;
                              final conditionType =
                                  item['conditionType'] as String?;
                              final iconPath = WeatherHelper.getImageForWeather(
                                rawDesc,
                                conditionType: conditionType,
                              );
                              final itemEpoch = (item['dt'] as int);
                              final isActive = itemEpoch == nowHourEpoch;
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.w),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xff355469)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(50.r),
                                  border: Border.all(
                                    color: const Color(0xff355469),
                                    width: 1.w,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      label,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: isActive
                                            ? Colors.white
                                            : const Color(0xff355469),
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Image.asset(
                                      iconPath,
                                      width: 40.w,
                                      height: 35.h,
                                      color: isActive ? Colors.white : null,
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      temp,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: isActive
                                            ? Colors.white
                                            : const Color(0xff355469),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ),
                      SizedBox(height: 25.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Center(
                          child: Text(
                            'Cuaca Lampau',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 110.h,
                        child: Obx(() {
                          if (controller.historyLoading.value) {
                            return _buildHistoryShimmerList();
                          }
                          final list = controller.history;
                          if (list.isEmpty) {
                            return _buildEmptyHistoryList();
                          }
                          final itemCount = list.length > 12 ? 12 : list.length;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: itemCount,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            itemBuilder: (context, index) {
                              final item = list[index];
                              final dt = DateTime.fromMillisecondsSinceEpoch(
                                  (item['dt'] as int) * 1000);
                              final label = _hourLabelFor(dt);
                              final temp = (item['temp'] is num)
                                  ? '${(item['temp'] as num).toDouble().toStringAsFixed(1)}°'
                                  : item['temp'].toString();
                              final desc = item['description'] as String? ?? '';
                              final rawDesc =
                                  item['rawDescription'] as String? ?? desc;
                              final conditionType =
                                  item['conditionType'] as String?;
                              final iconPath = WeatherHelper.getImageForWeather(
                                rawDesc,
                                conditionType: conditionType,
                              );
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.w),
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                  horizontal: 10.w,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50.r),
                                  border: Border.all(
                                    color: const Color(0xff355469),
                                    width: 1.w,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      label,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: const Color(0xff355469),
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Image.asset(
                                      iconPath,
                                      width: 36.w,
                                      height: 32.h,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink(),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      temp,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: const Color(0xff355469),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ),
                      SizedBox(height: 25.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Center(
                          child: Text(
                            'Hari ini',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      SizedBox(
                        height: 110.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: days.length,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemBuilder: (context, index) {
                            final d = days[index];
                            final isActive = index == 0;
                            final monthShort = monthNames[d.month - 1];
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 16.w,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xff355469)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(50.r),
                                border: Border.all(
                                  color: const Color(0xff355469),
                                  width: 1.w,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    monthShort,
                                    style: GoogleFonts.inter(
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xff355469),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    '${d.day}',
                                    style: GoogleFonts.inter(
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xff355469),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    '${d.year}',
                                    style: GoogleFonts.inter(
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xff355469),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

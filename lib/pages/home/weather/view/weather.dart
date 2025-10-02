import 'package:JIR/pages/home/weather/controller/weather_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/weather/widget/diagonal_container.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
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
              SizedBox(
                height: 110.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 12,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xff355469), width: 1.w),
                        borderRadius: BorderRadius.circular(50.r),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('01:00',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                  color: const Color(0xff355469))),
                          SizedBox(height: 5.h),
                          Image.asset(
                            'assets/images/Cuaca Smart City Icon-02.png',
                            width: 40.w,
                            height: 35.h,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            '23°C',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                color: const Color(0xff355469)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 25.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: Text('Hari ini',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 18.sp)),
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
                          vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color:
                            isActive ? const Color(0xff355469) : Colors.white,
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                            color: const Color(0xff355469), width: 1.w),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            monthShort,
                            style: GoogleFonts.inter(
                              color: isActive ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '${d.day}',
                            style: GoogleFonts.inter(
                              color: isActive ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '${d.year}',
                            style: GoogleFonts.inter(
                              color: isActive ? Colors.white : Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
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
        );
      }),
    );
  }
}

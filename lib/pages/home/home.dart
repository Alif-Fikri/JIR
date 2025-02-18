import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartcitys/app/routes/app_routes.dart';
import 'package:weather/weather.dart';
import 'dart:math' as math;
import 'package:smartcitys/pages/home/chat/chatbot.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartcitys/helper/weathertranslator.dart';
import 'package:smartcitys/helper/image_selector.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  WeatherFactory wf = WeatherFactory(dotenv.env['WEATHER_API_KEY']!);
  String temperature = "Loading...";
  String location = "Loading...";
  String weatherDescription = "Loading...";

  @override
  void initState() {
    super.initState();
    _getLocationAndWeather();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getLocationAndWeather() async {
    setState(() {
      location = "Loading...";
      temperature = "Loading...";
      weatherDescription = "Loading...";
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          location = "Location permission denied";
          temperature = "N/A";
          weatherDescription = "N/A";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        location = "Location permission permanently denied";
        temperature = "N/A";
        weatherDescription = "N/A";
      });
      return;
    }

    try {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Position: $position");

      // Fetch weather data
      Weather? weather;
      try {
        weather = await wf.currentWeatherByLocation(
          position.latitude,
          position.longitude,
        );
        print("Weather data fetched: $weather");
      } catch (e) {
        print("Error fetching weather data: $e");
        weather = null;
      }

      // Fetch placemark data
      List<Placemark> placemarks;
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        print("Placemark data fetched: $placemarks");
      } catch (e) {
        print("Error fetching placemark data: $e");
        placemarks = [];
      }

      Placemark place =
          placemarks.isNotEmpty ? placemarks.first : const Placemark();

      setState(() {
        if (weather != null && weather.temperature != null) {
          temperature = "${weather.temperature!.celsius!.toStringAsFixed(1)}°";
        } else {
          temperature = "N/A";
        }

        location = place.locality?.replaceFirst("Kecamatan ", "") ??
            "Unknown Location";

        weatherDescription = weather?.weatherDescription != null
            ? _translateWeatherDescription(weather!.weatherDescription!)
            : "N/A";

        print("Temperature: $temperature");
        print("Location: $location");
        print("Weather Description: $weatherDescription");
      });
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        location = "Error fetching location";
        temperature = "N/A";
        weatherDescription = "N/A";
      });
    }
  }

  String _translateWeatherDescription(String? description) {
    return WeatherTranslator.translate(description);
  }

  @override
  Widget build(BuildContext context) {
    final int currentHour = DateTime.now().hour;
    String backgroundImage =
        BackgroundImageSelector.getBackgroundImage(currentHour);
    String translatedDescription =
        _translateWeatherDescription(weatherDescription);
    String weatherImage =
        BackgroundImageSelector.getImageForWeather(translatedDescription);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Konten halaman
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(87),
                    bottomRight: Radius.circular(87),
                  ),
                  child: Container(
                    height: 308.0,
                    color: const Color(0xFF45557B),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25.0, left: 25.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "JIR APPLICATION",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -170),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 250.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(backgroundImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  (weatherImage),
                                  width: 50,
                                  height: 37,
                                ),
                                Text(
                                  weatherDescription,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  temperature,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  location,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -20.0,
                          right: -10.0,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              'assets/images/path.png',
                              width: 45,
                              height: 45,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -140),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(50),
                      shadowColor: Colors.grey.withOpacity(0.5),
                      child: TextField(
                        style: GoogleFonts.inter(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search . . .',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontStyle: FontStyle.italic),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 5.0, top: 5.0, left: 18.0, right: 15.0),
                            child: Image.asset(
                              'assets/images/search.png',
                              height: 25,
                              width: 25,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEDEDED),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -125),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 30.0,
                      children: [
                        featureIcon(
                          onPressed: () => Get.toNamed(AppRoutes.flood),
                          label: 'Pantau Banjir',
                          imagePath: 'assets/images/pantau_banjir.png',
                        ),
                        featureIcon(
                          onPressed: () => Get.toNamed(AppRoutes.crowd),
                          imagePath: 'assets/images/pantau_kerumunan.png',
                          label: 'Pantau Kerumunan',
                        ),
                        featureIcon(
                          onPressed: () => Get.toNamed(AppRoutes.park),
                          imagePath: 'assets/images/taman.png',
                          label: 'Taman',
                        ),
                        featureIcon(
                          onPressed: () => Get.toNamed(AppRoutes.peta),
                          imagePath: 'assets/images/peta.png',
                          label: 'Peta',
                        ),
                        featureIcon(
                          onPressed: () => Get.toNamed(AppRoutes.cctv),
                          imagePath: 'assets/images/cctv.png',
                          label: 'CCTV',
                        ),
                        featureIcon(
                          onPressed: () => Get.toNamed(AppRoutes.cuaca),
                          imagePath: 'assets/images/cuaca.png',
                          label: 'Cuaca',
                        ),
                        featureIcon(
                          onPressed: () => Get.toNamed(AppRoutes.lapor),
                          imagePath: 'assets/images/laporan.png',
                          label: 'Laporan',
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -80),
                  child: Container(
                    child: Image.asset('assets/images/line2.png'),
                  ),
                ),
                const SizedBox(height: 16),
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          "WARNING",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        warningBox("Curah Hujan Tinggi Berpotensi Banjir"),
                        warningBox("Aksi Demo Para Demonstran"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_animationController]),
            builder: (context, child) {
              double bounce =
                  math.sin(_animationController.value * 2 * math.pi) * 5;
              return Positioned(
                bottom: 50 + bounce,
                right: 25,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatbotOpeningPage(),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/robot.png',
                    width: 70,
                    height: 70,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget featureIcon(
      {required VoidCallback onPressed,
      String? imagePath,
      IconData? icon,
      required String label}) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30),
            shadowColor: Colors.grey.withOpacity(1.0),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFEAEFF3),
              child: imagePath != null
                  ? Image.asset(imagePath, width: 30, height: 30)
                  : Icon(icon, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 70),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF355469)),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget warningBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD205),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

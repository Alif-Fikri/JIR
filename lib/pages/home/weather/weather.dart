import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/home/weather/diagonal_container.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                const DiagonalContainer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: const Color(0xff355469),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Meruya Selatan',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff6C6969)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hello, Bila',
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff6C6969)),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Image.asset(
                              'assets/images/Cuaca Smart City Icon-05.png',
                              width: 330,
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '27° C',
                                  style: GoogleFonts.inter(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff6C6969),
                                  ),
                                ),
                                Text(
                                  'Cerah',
                                  style: GoogleFonts.inter(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff6C6969),
                                  ),
                                ),
                                Text(
                                  '27°/27° C',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff6C6969),
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
            const SizedBox(height: 30),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xff355469)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('01:00',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: const Color(0xff355469))),
                        const SizedBox(height: 5),
                        Image.asset(
                          'assets/images/Cuaca Smart City Icon-02.png',
                          width: 40,
                          height: 35,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '23°C',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: const Color(0xff355469)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text('Hari ini',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          index == 3 ? const Color(0xff355469) : Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xff355469)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Jan',
                          style: GoogleFonts.inter(
                            color: index == 3 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${27 + index}',
                          style: GoogleFonts.inter(
                            color: index == 3 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '2025',
                          style: GoogleFonts.inter(
                            color: index == 3 ? Colors.white : Colors.black,
                            fontSize: 14,
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
      ),
    );
  }
}

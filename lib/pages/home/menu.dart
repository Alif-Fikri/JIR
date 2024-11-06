import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  child: Container(
                    height: 308.0,
                    color: Color(0xFF45557B),
                    child: Center(
                      child: Text(
                        "JIR APPLICATION",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 160,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/cerah.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Weather info overlay
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        // Location icon overlay
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  featureIcon(Icons.house, 'Pantau Banjir'),
                  featureIcon(Icons.groups, 'Pantau Kerumunan'),
                  featureIcon(Icons.park, 'Taman'),
                  featureIcon(Icons.local_police, 'Polisi'),
                  featureIcon(Icons.location_pin, 'Lokasi'),
                  featureIcon(Icons.wb_sunny, 'Cuaca'),
                  featureIcon(Icons.videocam, 'CCTV'),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Warning Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  warningBox("Curah Hujan Tinggi Berpotensi Banjir"),
                  warningBox("Aksi Demo Para Demonstran"),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Placeholder for additional content or chatbot
            Container(
              margin: EdgeInsets.all(16),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Aktivitas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget featureIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[800], size: 30),
        ),
        SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget warningBox(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
              child: Text(text, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

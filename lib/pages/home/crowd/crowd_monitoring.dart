import 'package:flutter/material.dart';

class CrowdMonitoringPage extends StatelessWidget {
  final List<Map<String, dynamic>> todayCrowd = [
    {'location': 'Union Square', 'level': 'High', 'count': '2.5k'},
    {'location': 'Westfield Centre', 'level': 'Medium', 'count': '1.8k'},
    {'location': 'Ferry Building', 'level': 'Low', 'count': '700'},
  ];

  final List<Map<String, dynamic>> yesterdayCrowd = [
    {'location': 'Union Square', 'level': 'High', 'count': '3.2k'},
    {'location': 'Westfield Centre', 'level': 'Medium', 'count': '2.3k'},
    {'location': 'Ferry Building', 'level': 'Low', 'count': '700'},
  ];

  CrowdMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kerumunan'),
        backgroundColor: Colors.blueGrey.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {

            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Level Kerumunan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Today's crowd",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildCrowdList(todayCrowd),
              const SizedBox(height: 16),
              const Text(
                "Yesterday's crowd",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildCrowdList(yesterdayCrowd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrowdList(List<Map<String, dynamic>> crowdData) {
    return Column(
      children: crowdData.map((data) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.blue),
          ),
          title: Text(data['location']),
          subtitle: Text(
            data['level'],
            style: TextStyle(
              color: _getCrowdLevelColor(data['level']),
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text(data['count']),
        );
      }).toList(),
    );
  }

  Color _getCrowdLevelColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}

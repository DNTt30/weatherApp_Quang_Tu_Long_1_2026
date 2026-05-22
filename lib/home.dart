import 'dart:ui';
import 'package:flutter/material.dart';
import 'models/city.dart';
import 'widgets/custom_bottom_bar.dart';
import 'widgets/hourly_forecast_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<City> _cities;
  int _activeHourIndex = 0;
  bool _isHourlyView = true;

  @override
  void initState() {
    super.initState();
    _cities = [
      City(id: 'hn', name: 'Hanoi', latitude: 21.0278, longitude: 105.8342),
      City(id: 'hcm', name: 'Ho Chi Minh', latitude: 10.8231, longitude: 106.6297),
      City(id: 'dn', name: 'Da Nang', latitude: 16.0544, longitude: 108.2022),
      City(id: 'hp', name: 'Hai Phong', latitude: 20.8449, longitude: 106.6881),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/wallpaper.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Dark overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top content - Current weather
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Montreal',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '19°',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mostly Clear',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'H:24° L:18°',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom panel - Weather forecast with glassmorphism
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: Colors.purple.shade900.withOpacity(0.3),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade900.withOpacity(0.2),
                              Colors.blue.shade900.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Switcher: Hourly / Weekly
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _isHourlyView = true);
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Hourly Forecast',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _isHourlyView
                                                ? Colors.white
                                                : Colors.white54,
                                          ),
                                        ),
                                        if (_isHourlyView)
                                          Container(
                                            height: 2,
                                            width: 120,
                                            margin: const EdgeInsets.only(top: 4),
                                            color: Colors.blue.shade300,
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _isHourlyView = false);
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Weekly Forecast',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: !_isHourlyView
                                                ? Colors.white
                                                : Colors.white54,
                                          ),
                                        ),
                                        if (!_isHourlyView)
                                          Container(
                                            height: 2,
                                            width: 120,
                                            margin: const EdgeInsets.only(top: 4),
                                            color: Colors.blue.shade300,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Hourly forecast list
                              if (_isHourlyView)
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 8,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() => _activeHourIndex = index);
                                        },
                                        child: HourlyForecastCard(
                                          time: '${index + 8}:00',
                                          temp: '${19 + index}°',
                                          weatherIcon: index % 2 == 0
                                              ? Icons.wb_sunny
                                              : Icons.cloud,
                                          probability: '${30 + (index * 5)}%',
                                          isActive: _activeHourIndex == index,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Weekly Forecast Coming Soon',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        onLocationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location tapped')),
          );
        },
        onFabTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('FAB tapped')),
          );
        },
        onMenuTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu tapped')),
          );
        },
      ),
    );
  }
}


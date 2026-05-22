import 'package:flutter/material.dart';
import '../models/city.dart';
import '../widgets/city_card.dart';
import '../widgets/hourly_forecast_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<City> _cities;
  late City _activeCity;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _shortForecast = [
    {
      'day': 'Hôm nay',
      'icon': Icons.wb_sunny,
      'temp': '31°',
      'description': 'Nắng',
    },
    {'day': 'T.2', 'icon': Icons.cloud, 'temp': '28°', 'description': 'Mây'},
    {'day': 'T.3', 'icon': Icons.umbrella, 'temp': '25°', 'description': 'Mưa'},
    {
      'day': 'T.4',
      'icon': Icons.wb_cloudy,
      'temp': '27°',
      'description': 'Trời âm u',
    },
    {
      'day': 'T.5',
      'icon': Icons.wb_sunny,
      'temp': '30°',
      'description': 'Nắng ấm',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cities = [
      City(id: 'hn', name: 'Hanoi', latitude: 21.0278, longitude: 105.8342),
      City(
        id: 'hcm',
        name: 'Ho Chi Minh',
        latitude: 10.8231,
        longitude: 106.6297,
      ),
      City(id: 'dn', name: 'Da Nang', latitude: 16.0544, longitude: 108.2022),
      City(id: 'hp', name: 'Hai Phong', latitude: 20.8449, longitude: 106.6881),
      City(id: 'ct', name: 'Can Tho', latitude: 10.0452, longitude: 105.7469),
    ];
    _activeCity = _cities.first;
  }

  void _selectCity(City city) {
    setState(() {
      _activeCity = city;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thời tiết hôm nay',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _activeCity.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _activeCity.toggleFavorite();
              });
            },
            icon: Icon(
              _activeCity.isFavorite ? Icons.star : Icons.star_border,
              color: _activeCity.isFavorite ? Colors.amber : Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.wb_sunny, color: Colors.amber, size: 34),
              SizedBox(width: 12),
              Text(
                'Nắng',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '29°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 84,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_upward, size: 16, color: Colors.white70),
              SizedBox(width: 6),
              Text('H:32°', style: TextStyle(color: Colors.white70)),
              SizedBox(width: 16),
              Icon(Icons.arrow_downward, size: 16, color: Colors.white70),
              SizedBox(width: 6),
              Text('L:25°', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Dự báo vài ngày tới',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _shortForecast.length,
            itemBuilder: (context, index) {
              final day = _shortForecast[index];
              return Container(
                margin: EdgeInsets.only(
                  right: index == _shortForecast.length - 1 ? 0 : 12,
                ),
                child: HourlyForecastCard(
                  time: day['day'] as String,
                  temp: day['temp'] as String,
                  weatherIcon: day['icon'] as IconData,
                  probability: day['description'] as String,
                  isActive: index == 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Thành phố lớn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _cities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final city = _cities[index];
              return GestureDetector(
                onTap: () => _selectCity(city),
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: city == _activeCity
                        ? Colors.blue.shade700.withOpacity(0.9)
                        : Colors.white.withOpacity(0.12),
                    border: Border.all(
                      color: city == _activeCity
                          ? Colors.blueAccent
                          : Colors.white24,
                      width: city == _activeCity ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            city.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                city.toggleFavorite();
                              });
                            },
                            icon: Icon(
                              city.isFavorite ? Icons.star : Icons.star_border,
                              color: city.isFavorite
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Nhiệt độ ${24 + index}°',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${city.latitude.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      Text(
                        'Lng: ${city.longitude.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF081F38),
        border: Border(
          top: BorderSide(color: Colors.white24.withOpacity(0.08), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
          _buildNavItem(
            icon: Icons.cloud_outlined,
            label: 'Forecast',
            index: 1,
          ),
          _buildNavItem(icon: Icons.person, label: 'More', index: 2),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = index == _selectedIndex;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purpleAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade400),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/wallpaper.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildCurrentWeatherCard(),
                  const SizedBox(height: 24),
                  _buildForecastSection(),
                  const SizedBox(height: 24),
                  _buildCityList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

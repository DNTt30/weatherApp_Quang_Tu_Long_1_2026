import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../widgets/shared_widgets.dart';

// ============================================================
// HomeScreen — Màn hình chính (Long's screen)
// YÊU CẦU: Hiển thị thời tiết hiện tại, chọn thành phố, dự báo
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // YÊU CẦU 1: Biến String, double, bool
  late String city;
  late double temperature;
  late String weatherStatus;
  late double humidity;
  late bool isRaining;
  int _selectedCityIndex = 0;

  // YÊU CẦU 2: List<Map> — dữ liệu thời tiết các thành phố
  final List<Map<String, dynamic>> _cityWeatherData = [
    {'city': 'Hà Nội',      'temp': 32.5, 'status': 'Sunny',  'humidity': 70.0, 'isRaining': false},
    {'city': 'Đà Nẵng',    'temp': 29.0, 'status': 'Cloudy', 'humidity': 85.0, 'isRaining': false},
    {'city': 'Hồ Chí Minh','temp': 35.0, 'status': 'Sunny',  'humidity': 60.0, 'isRaining': false},
    {'city': 'Hải Phòng',  'temp': 28.0, 'status': 'Rainy',  'humidity': 90.0, 'isRaining': true},
    {'city': 'Cần Thơ',    'temp': 33.0, 'status': 'Cloudy', 'humidity': 75.0, 'isRaining': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadCity(0);
  }

  void _loadCity(int index) {
    final d = _cityWeatherData[index];
    setState(() {
      _selectedCityIndex = index;
      city         = d['city'];
      temperature  = d['temp'];
      weatherStatus= d['status'];
      humidity     = d['humidity'];
      isRaining    = d['isRaining'];
    });
  }

  IconData _weatherIcon() {
    switch (weatherStatus.toLowerCase()) {
      case 'sunny':  return Icons.wb_sunny_rounded;
      case 'rainy':  return Icons.grain;
      case 'cloudy': return Icons.cloud_rounded;
      default:       return Icons.wb_cloudy_rounded;
    }
  }

  Color _weatherIconColor() {
    switch (weatherStatus.toLowerCase()) {
      case 'sunny':  return const Color(0xFFFFB300);
      case 'rainy':  return Colors.lightBlue.shade200;
      default:       return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    // YÊU CẦU 5: Tạo đối tượng Weather (class)
    final Weather currentWeather = Weather(
      city:        city,
      temperature: temperature,
      status:      weatherStatus,
      humidity:    humidity,
      isRaining:   isRaining,
    );

    // YÊU CẦU 2: List<Map> — forecast 5 ngày
    final List<Map<String, dynamic>> forecastList = [
      {'id':'f1','dateTime':'Thứ 2','minTemp':25.0,'maxTemp':32.0,'rainProb':10,'icon':Icons.wb_sunny_rounded,'color':const Color(0xFFFFB300)},
      {'id':'f2','dateTime':'Thứ 3','minTemp':24.0,'maxTemp':28.0,'rainProb':80,'icon':Icons.grain,           'color':Colors.lightBlue},
      {'id':'f3','dateTime':'Thứ 4','minTemp':25.0,'maxTemp':30.0,'rainProb':30,'icon':Icons.cloud_rounded,  'color':Colors.grey},
      {'id':'f4','dateTime':'Thứ 5','minTemp':23.0,'maxTemp':29.0,'rainProb':10,'icon':Icons.wb_sunny_rounded,'color':const Color(0xFFFFB300)},
      {'id':'f5','dateTime':'Thứ 6','minTemp':26.0,'maxTemp':31.0,'rainProb':50,'icon':Icons.cloud_rounded,  'color':Colors.grey},
    ];

    // YÊU CẦU 4: List<Map> danh sách thành phố (City)
    final List<Map<String, dynamic>> listCity = [
      {'id':1,'name':'Hà Nội'},
      {'id':2,'name':'Đà Nẵng'},
      {'id':3,'name':'Hồ Chí Minh'},
      {'id':4,'name':'Hải Phòng'},
      {'id':5,'name':'Cần Thơ'},
    ];

    return Column(
      children: [
        // === HEADER: Ảnh nhóm ===
        const GroupPhotoHeader(screenLabel: 'Long_home'),

        // === NỘI DUNG CUỘN ===
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thời tiết chính
                _buildMainWeatherCard(currentWeather),
                const SizedBox(height: 16),
                // Chọn thành phố
                _buildCitySelector(listCity),
                const SizedBox(height: 16),
                // Dự báo 5 ngày
                _buildForecastCards(forecastList),
                const SizedBox(height: 16),
                // Chi tiết thời tiết
                _buildWeatherDetails(currentWeather),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // === FOOTER: Thông tin nhóm ===
        const MemberInfoFooter(),
      ],
    );
  }

  // ── Card thời tiết chính ──────────────────────────────────
  Widget _buildMainWeatherCard(Weather weather) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(weatherStatus,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                ],
              ),
              Icon(_weatherIcon(), color: _weatherIconColor(), size: 64),
            ],
          ),
          const SizedBox(height: 12),
          Text('${temperature.toStringAsFixed(0)}°C',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 56, fontWeight: FontWeight.w300)),
          const SizedBox(height: 4),
          Text(weather.getWeatherInfo(),
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ── Chọn thành phố ────────────────────────────────────────
  Widget _buildCitySelector(List<Map<String, dynamic>> listCity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chọn Thành Phố',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1565C0))),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(listCity.length, (i) {
                // YÊU CẦU 4: Tạo đối tượng City
                final City cityObj = City(id: listCity[i]['id'], name: listCity[i]['name']);
                final bool isSelected = i == _selectedCityIndex;
                return GestureDetector(
                  onTap: () => _loadCity(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Text(cityObj.name,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF1565C0))),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dự báo 5 ngày ─────────────────────────────────────────
  Widget _buildForecastCards(List<Map<String, dynamic>> forecastList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dự Báo 5 Ngày',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1565C0))),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(forecastList.length, (i) {
                final f = forecastList[i];
                // YÊU CẦU 5: Tạo đối tượng Forecast (class)
                final Forecast fo = Forecast(
                  id:              f['id'],
                  dateTime:        f['dateTime'],
                  minTemp:         (f['minTemp'] as num).toDouble(),
                  maxTemp:         (f['maxTemp'] as num).toDouble(),
                  rainProbability: f['rainProb'],
                );
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(fo.dateTime,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1565C0))),
                      const SizedBox(height: 8),
                      Icon(f['icon'] as IconData, color: f['color'] as Color, size: 28),
                      const SizedBox(height: 8),
                      Text('${fo.maxTemp.toInt()}°',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E88E5))),
                      Text('${fo.minTemp.toInt()}°',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.water_drop, size: 12, color: Colors.lightBlue),
                          Text('${fo.rainProbability}%',
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.lightBlue)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chi tiết thời tiết ────────────────────────────────────
  Widget _buildWeatherDetails(Weather weather) {
    // YÊU CẦU 2: Map<String, dynamic>
    final Map<String, dynamic> weatherData = {
      'city':        weather.city,
      'temperature': '${weather.temperature}°C',
      'status':      weather.status,
      'humidity':    '${weather.humidity.toStringAsFixed(0)}%',
      'isRaining':   weather.isRaining ? 'Có mưa ☔' : 'Không mưa ☀️',
    };
    final Map<String, IconData> icons = {
      'city':        Icons.location_city,
      'temperature': Icons.thermostat,
      'status':      Icons.cloud,
      'humidity':    Icons.water_drop,
      'isRaining':   Icons.umbrella,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi Tiết Thời Tiết',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1565C0))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: weatherData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(icons[entry.key], size: 20, color: const Color(0xFF1E88E5)),
                      const SizedBox(width: 12),
                      Text(entry.key,
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
                      const Spacer(),
                      Text('${entry.value}',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1565C0))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

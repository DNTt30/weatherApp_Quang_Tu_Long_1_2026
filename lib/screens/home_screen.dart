import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../service/firestore_service.dart';

// ============================================================
// HomeScreen — Long phụ trách
// Tên thành phố | Nhiệt độ | Thời tiết | Dự báo | City list
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirestoreService firestoreService = FirestoreService();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  int _selectedCityIndex = 0;

  // ── Mock data thời tiết 5 thành phố ──────────────────────
  final List<Map<String, dynamic>> _cityWeatherData = [
    {
      'city': 'Hà Nội',       'lat': 21.0285, 'lon': 105.8542,
      'temp': 32.5, 'status': 'Sunny',  'humidity': 70.0,
      'isRaining': false, 'wind': 12.0, 'feel': 34.0, 'uv': 7,
      'icon': 'sunny',
    },
    {
      'city': 'Đà Nẵng',     'lat': 16.0544, 'lon': 108.2022,
      'temp': 29.0, 'status': 'Cloudy', 'humidity': 85.0,
      'isRaining': false, 'wind': 18.0, 'feel': 31.0, 'uv': 4,
      'icon': 'cloudy',
    },
    {
      'city': 'Hồ Chí Minh', 'lat': 10.8231, 'lon': 106.6297,
      'temp': 35.0, 'status': 'Sunny',  'humidity': 60.0,
      'isRaining': false, 'wind': 8.0,  'feel': 38.0, 'uv': 9,
      'icon': 'sunny',
    },
    {
      'city': 'Hải Phòng',   'lat': 20.8449, 'lon': 106.6881,
      'temp': 28.0, 'status': 'Rainy',  'humidity': 90.0,
      'isRaining': true,  'wind': 22.0, 'feel': 29.0, 'uv': 2,
      'icon': 'rainy',
    },
    {
      'city': 'Cần Thơ',     'lat': 10.0452, 'lon': 105.7469,
      'temp': 33.0, 'status': 'Cloudy', 'humidity': 75.0,
      'isRaining': false, 'wind': 10.0, 'feel': 35.0, 'uv': 6,
      'icon': 'cloudy',
    },
  ];

  // ── List<City> dùng class City đầy đủ ────────────────────
  late List<City> _cities;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _cities = List.generate(_cityWeatherData.length, (i) {
      final d = _cityWeatherData[i];
      return City(
        id: i + 1,
        name: d['city'],
        latitude: d['lat'],
        longitude: d['lon'],
        isFavorite: i == 0, // Hà Nội mặc định là yêu thích
      );
    });
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _selectCity(int index) {
    setState(() => _selectedCityIndex = index);
    _animCtrl.forward(from: 0);
  }

  void _toggleFavorite(int index) {
    setState(() => _cities[index].toggleFavorite());
  }

  // ── Helpers ───────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sunny':  return const Color(0xFFFFD700);
      case 'rainy':  return const Color(0xFF83B4FF);
      default:       return const Color(0xFFB0C4DE);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'sunny':  return Icons.wb_sunny_rounded;
      case 'rainy':  return Icons.grain_rounded;
      default:       return Icons.cloud_rounded;
    }
  }

  String _statusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'sunny':  return '☀️';
      case 'rainy':  return '🌧️';
      default:       return '⛅';
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final d = _cityWeatherData[_selectedCityIndex];
    final City selectedCity = _cities[_selectedCityIndex];

    // Tạo đối tượng Weather đầy đủ
    final Weather weather = Weather(
      city: d['city'],
      temperature: d['temp'],
      status: d['status'],
      humidity: d['humidity'],
      isRaining: d['isRaining'],
      windSpeed: d['wind'],
      uvIndex: d['uv'],
      icon: d['icon'],
    );

    // 5-day forecast data
    final List<Forecast> forecasts = [
      Forecast(id:'f1', dateTime:'T2', minTemp:24.0, maxTemp:32.0, rainProbability:10, description:'Nắng đẹp'),
      Forecast(id:'f2', dateTime:'T3', minTemp:23.0, maxTemp:28.0, rainProbability:80, description:'Mưa rào'),
      Forecast(id:'f3', dateTime:'T4', minTemp:25.0, maxTemp:30.0, rainProbability:30, description:'Nhiều mây'),
      Forecast(id:'f4', dateTime:'T5', minTemp:22.0, maxTemp:29.0, rainProbability:10, description:'Trời quang'),
      Forecast(id:'f5', dateTime:'T6', minTemp:26.0, maxTemp:31.0, rainProbability:50, description:'Chiều mưa'),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
        ),
      ),
      child: Column(children: [
        _buildGroupHeader(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(children: [
                _buildMainCard(weather, selectedCity),
                const SizedBox(height: 20),
                _buildHourlyForecast(),
                const SizedBox(height: 20),
                _buildForecastList(forecasts),
                const SizedBox(height: 20),
                _buildCityListSection(),
                const SizedBox(height: 16),
                _buildAddCityBtn(),
                const SizedBox(height: 4),
              ]),
            ),
          ),
        ),
        _buildFooter(),
      ]),
    );
  }

  // ── Group Photo Header ────────────────────────────────────
  Widget _buildGroupHeader() {
    return Container(
      width: double.infinity, height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF48319D), Color(0xFF5936B4)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(right: -20, top: -20, child: Container(width: 100, height: 100,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)))),
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.photo_camera_rounded, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            Text('Ảnh Nhóm', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Long_Home', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ])),
      ]),
    );
  }

  // ── Main Weather Card ─────────────────────────────────────
  Widget _buildMainCard(Weather weather, City city) {
    final warning = weather.getWarning();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF5936B4), Color(0xFF362A84)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(
          color: const Color(0xFF48319D).withValues(alpha: 0.5),
          blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        // Row: City info + emoji icon
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFFE0D9FF), size: 16),
              const SizedBox(width: 4),
              Text(city.name, style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _toggleFavorite(_selectedCityIndex),
                child: Icon(
                  city.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: city.isFavorite ? const Color(0xFFFFD700) : Colors.white38,
                  size: 20,
                ),
              ),
            ]),
            Text(city.getCityInfo().split('|').last.trim(),
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
          ])),
          Text(_statusEmoji(weather.status), style: const TextStyle(fontSize: 48)),
        ]),

        const SizedBox(height: 12),

        // Temperature — large
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            weather.formatTemperature(),
            style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 68,
              fontWeight: FontWeight.w200, height: 1),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(weather.status, style: GoogleFonts.poppins(
            color: const Color(0xFFE0D9FF), fontSize: 16)),
        ),

        const SizedBox(height: 16),

        // Quick stats
        Row(children: [
          _statChip(Icons.water_drop_rounded, '${weather.humidity.toInt()}%', 'Độ ẩm'),
          const SizedBox(width: 8),
          _statChip(Icons.air_rounded, '${weather.windSpeed.toInt()}km/h', weather.getWindLabel()),
          const SizedBox(width: 8),
          _statChip(Icons.wb_sunny_outlined, 'UV ${weather.uvIndex}', weather.getUvLabel()),
        ]),

        // Warning banner
        if (warning != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC427FB).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC427FB).withValues(alpha: 0.4)),
            ),
            child: Text(warning, style: GoogleFonts.poppins(
              color: const Color(0xFFE0D9FF), fontSize: 11)),
          ),
        ],
      ]),
    );
  }

  Widget _statChip(IconData icon, String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        Icon(icon, color: const Color(0xFFE0D9FF), size: 16),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 9), overflow: TextOverflow.ellipsis),
      ]),
    ),
  );

  // ── Hourly Forecast ───────────────────────────────────────
  Widget _buildHourlyForecast() {
    final hours = [
      {'time':'Bây giờ','temp':32,'icon':Icons.wb_sunny_rounded,'color':const Color(0xFFFFD700)},
      {'time':'13:00',  'temp':33,'icon':Icons.wb_sunny_rounded,'color':const Color(0xFFFFD700)},
      {'time':'15:00',  'temp':31,'icon':Icons.cloud_rounded,   'color':const Color(0xFFB0C4DE)},
      {'time':'17:00',  'temp':29,'icon':Icons.cloud_rounded,   'color':const Color(0xFFB0C4DE)},
      {'time':'19:00',  'temp':27,'icon':Icons.grain_rounded,   'color':const Color(0xFF83B4FF)},
      {'time':'21:00',  'temp':25,'icon':Icons.nights_stay_rounded,'color':const Color(0xFF9575CD)},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Dự Báo Theo Giờ'),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: hours.map((h) => Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Text(h['time'] as String, style: GoogleFonts.poppins(
                  color: const Color(0xFFE0D9FF), fontSize: 11)),
                const SizedBox(height: 8),
                Icon(h['icon'] as IconData, color: h['color'] as Color, size: 22),
                const SizedBox(height: 8),
                Text('${h['temp']}°', style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
            )).toList(),
          ),
        ),
      ),
    ]);
  }

  // ── 5-Day Forecast List ───────────────────────────────────
  Widget _buildForecastList(List<Forecast> forecasts) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Dự Báo 5 Ngày Tới'),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: List.generate(forecasts.length, (i) {
            final fo = forecasts[i];
            final IconData icon = fo.rainProbability > 60
                ? Icons.grain_rounded
                : fo.rainProbability > 30
                    ? Icons.cloud_rounded
                    : Icons.wb_sunny_rounded;
            final Color iconColor = fo.rainProbability > 60
                ? const Color(0xFF83B4FF)
                : fo.rainProbability > 30
                    ? const Color(0xFFB0C4DE)
                    : const Color(0xFFFFD700);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: i < forecasts.length - 1
                    ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)))
                    : null,
              ),
              child: Row(children: [
                SizedBox(width: 34, child: Text(fo.dateTime, style: GoogleFonts.poppins(
                  color: const Color(0xFFE0D9FF), fontSize: 13, fontWeight: FontWeight.w600))),
                const SizedBox(width: 10),
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 10),
                Text(fo.description ?? fo.getRainLabel(), style: GoogleFonts.poppins(
                  color: Colors.white54, fontSize: 11)),
                const Spacer(),
                // Rain probability bar
                SizedBox(width: 50, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${fo.rainProbability}%', style: GoogleFonts.poppins(
                    color: const Color(0xFF83B4FF), fontSize: 10)),
                  const SizedBox(height: 2),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fo.rainProbability / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF83B4FF)),
                      minHeight: 3)),
                ])),
                const SizedBox(width: 12),
                // Temp range
                Row(children: [
                  Text('${fo.maxTemp.toInt()}°', style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(' / ${fo.minTemp.toInt()}°', style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 12)),
                ]),
              ]),
            );
          }),
        ),
      ),
    ]);
  }

  // ── City List Section (cuộn xuống thấy) ──────────────────
  Widget _buildCityListSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Thành Phố Lớn'),
      const SizedBox(height: 10),
      ...List.generate(_cities.length, (i) => _buildCityCard(i)),
    ]);
  }

  // ── City Card UI ──────────────────────────────────────────
  Widget _buildCityCard(int index) {
    final City city = _cities[index];
    final d = _cityWeatherData[index];
    final bool isSelected = index == _selectedCityIndex;

    return GestureDetector(
      onTap: () => _selectCity(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF48319D), Color(0xFF5936B4)])
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC427FB).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1)),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF48319D).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ] : [],
        ),
        child: Row(children: [
          // Weather icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusColor(d['status']).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(d['status']), color: _statusColor(d['status']), size: 20),
          ),
          const SizedBox(width: 12),

          // City info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(city.name, style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              if (city.isFavorite) ...[
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
              ],
            ]),
            Text('Lat: ${city.latitude} | Lon: ${city.longitude}',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
          ])),

          // Temperature
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${(d['temp'] as double).toInt()}°C', style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(d['status'], style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
          ]),
          const SizedBox(width: 8),

          // Favorite button
          GestureDetector(
            onTap: () => _toggleFavorite(index),
            child: Icon(
              city.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: city.isFavorite ? const Color(0xFFFFD700) : Colors.white24,
              size: 22,
            ),
          ),
        ]),
      ),
    );
  }

  // ── Add City Button ───────────────────────────────────────
  Widget _buildAddCityBtn() {
    return GestureDetector(
      onTap: () => firestoreService.addCity(),
      child: Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF48319D), Color(0xFFC427FB)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: const Color(0xFFC427FB).withValues(alpha: 0.3),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text('Thêm vào Firestore', style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1D47).withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const Icon(Icons.school_rounded, size: 12, color: Color(0xFFE0D9FF)),
          const SizedBox(width: 6),
          Text('Phenikaa University', style: GoogleFonts.poppins(
            fontSize: 11, color: const Color(0xFFE0D9FF), fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 3),
        Text('Dương Ngọc Tú (22010052) • Ngô Thành Long (23010032) • Lê Minh Quang (21012086)',
          style: GoogleFonts.poppins(fontSize: 9, color: Colors.white38),
          overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: GoogleFonts.poppins(
    color: const Color(0xFFE0D9FF), fontSize: 14, fontWeight: FontWeight.w700));
}

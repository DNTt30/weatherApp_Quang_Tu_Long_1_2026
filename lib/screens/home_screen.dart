import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../service/firestore_service.dart';
import '../service/settings_service.dart';
import '../service/weather_data_manager.dart';

// ============================================================
// HomeScreen — Quang phụ trách
// Tên thành phố | Nhiệt độ | Thời tiết | Dự báo | City list
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirestoreService firestoreService = FirestoreService();
  final WeatherDataManager _dataManager = WeatherDataManager();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  int _selectedCityIndex = 0;

  // ── List<City> dùng class City đầy đủ ────────────────────
  late List<City> _cities;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _cities = List.generate(_dataManager.allCitiesData.length, (i) {
      final d = _dataManager.allCitiesData[i];
      return City(
        id: i + 1,
        name: d['city'],
        latitude: d['lat'],
        longitude: d['lon'],
        isFavorite: false, // Sẽ load từ Firestore sau
      );
    });
    _animCtrl.forward();
    _loadFavoritesFromFirestore();
  }

  Future<void> _loadFavoritesFromFirestore() async {
    try {
      final favorites = await firestoreService.getFavoriteCities();
      if (mounted) {
        setState(() {
          for (var city in _cities) {
            city.isFavorite = favorites.contains(city.name);
          }
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải thành phố yêu thích từ Firestore: $e");
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _selectCity(int index) {
    setState(() => _selectedCityIndex = index);
    _animCtrl.forward(from: 0);
    // Lưu lịch sử xem thành phố
    firestoreService.saveSearchHistory(_cities[index].name);
  }

  void _toggleFavorite(int index) {
    setState(() => _cities[index].toggleFavorite());
    // Đồng bộ lên Firestore
    firestoreService.toggleFavoriteCity(
      _cities[index].name,
      _cities[index].isFavorite,
    );
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
    if (_dataManager.allCitiesData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final d = _dataManager.allCitiesData[_selectedCityIndex];
    final City selectedCity = _cities[_selectedCityIndex];

    // Tạo đối tượng Weather từ API data
    final Weather weather = d['weather'];

    // 5-day forecast data từ API
    final List<Forecast> forecasts = d['forecasts'];

    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.isLightMode,
      builder: (context, isLightMode, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [SettingsService.bgGradientTop, SettingsService.bgGradientBottom],
            ),
          ),
          child: ValueListenableBuilder<bool>(
        valueListenable: SettingsService.isCelsius,
        builder: (context, isCelsius, _) {
          return Column(children: [
            _buildGroupHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(children: [
                    _buildMainCard(weather, selectedCity, isCelsius),
                    const SizedBox(height: 20),
                    _buildHourlyForecast(isCelsius),
                    const SizedBox(height: 20),
                    _buildForecastList(forecasts, isCelsius),
                    const SizedBox(height: 20),
                    _buildCityListSection(isCelsius),
                    const SizedBox(height: 16),
                    _buildAddCityBtn(),
                    const SizedBox(height: 4),
                  ]),
                ),
              ),
            ),
            _buildFooter(),
          ]);
        },
      ),
    );
    },
    );
  }

  // ── Group Photo Header ────────────────────────────────────
  Widget _buildGroupHeader() {
    return Container(
      width: double.infinity, height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [SettingsService.primaryGradientStart, SettingsService.primaryGradientEnd],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(right: -20, top: -20, child: Container(width: 100, height: 100,
          decoration: BoxDecoration(shape: BoxShape.circle, color: SettingsService.cardBorderColor))),
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.photo_camera_rounded, color: SettingsService.textMutedColor, size: 18),
            const SizedBox(width: 8),
            Text('Ảnh Nhóm', style: GoogleFonts.poppins(color: SettingsService.textDimColor, fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: SettingsService.cardBorderColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Long_Home', style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ])),
      ]),
    );
  }

  // ── Main Weather Card ─────────────────────────────────────
  Widget _buildMainCard(Weather weather, City city, bool isCelsius) {
    final warning = weather.getWarning();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [SettingsService.primaryGradientStart, SettingsService.primaryGradientEnd],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: SettingsService.cardBorderColor),
        boxShadow: [BoxShadow(
          color: SettingsService.primaryGradientStart.withValues(alpha: 0.5),
          blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        // Row: City info + emoji icon
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.location_on_rounded, color: SettingsService.accentTitleColor, size: 16),
              const SizedBox(width: 4),
              Text(city.name, style: GoogleFonts.poppins(
                color: SettingsService.textColor, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _toggleFavorite(_selectedCityIndex),
                child: Icon(
                  city.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: city.isFavorite ? const Color(0xFFFFD700) : SettingsService.textMutedColor,
                  size: 20,
                ),
              ),
            ]),
            Text(city.getCityInfo().split('|').last.trim(),
              style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 10)),
          ])),
          Text(_statusEmoji(weather.status), style: const TextStyle(fontSize: 48)),
        ]),

        const SizedBox(height: 12),

        // Temperature — large
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            weather.formatTemperature(fahrenheit: !isCelsius),
            style: GoogleFonts.poppins(
              color: SettingsService.textColor, fontSize: 68,
              fontWeight: FontWeight.w200, height: 1),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(weather.status, style: GoogleFonts.poppins(
            color: SettingsService.accentTitleColor, fontSize: 16)),
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
              color: SettingsService.accentTitleColor, fontSize: 11)),
          ),
        ],
      ]),
    );
  }

  Widget _statChip(IconData icon, String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: SettingsService.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SettingsService.cardColor),
      ),
      child: Column(children: [
        Icon(icon, color: SettingsService.accentTitleColor, size: 16),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 9), overflow: TextOverflow.ellipsis),
      ]),
    ),
  );

  // ── Hourly Forecast ───────────────────────────────────────
  Widget _buildHourlyForecast(bool isCelsius) {
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
          color: SettingsService.cardBorderColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SettingsService.cardColor),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: hours.map((h) => Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: SettingsService.cardBorderColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Text(h['time'] as String, style: GoogleFonts.poppins(
                  color: SettingsService.accentTitleColor, fontSize: 11)),
                const SizedBox(height: 8),
                Icon(h['icon'] as IconData, color: h['color'] as Color, size: 22),
                const SizedBox(height: 8),
                Text(
                  '${isCelsius ? h['temp'] : ((h['temp'] as int) * 9 / 5 + 32).toInt()}°',
                  style: GoogleFonts.poppins(
                    color: SettingsService.textColor, fontSize: 14, fontWeight: FontWeight.bold)
                ),
              ]),
            )).toList(),
          ),
        ),
      ),
    ]);
  }

  // ── 5-Day Forecast List ───────────────────────────────────
  Widget _buildForecastList(List<Forecast> forecasts, bool isCelsius) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Dự Báo 5 Ngày Tới'),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: SettingsService.cardBorderColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SettingsService.cardColor),
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
                    ? Border(bottom: BorderSide(color: SettingsService.cardBorderColor))
                    : null,
              ),
              child: Row(children: [
                SizedBox(width: 34, child: Text(fo.dateTime, style: GoogleFonts.poppins(
                  color: SettingsService.accentTitleColor, fontSize: 13, fontWeight: FontWeight.w600))),
                const SizedBox(width: 10),
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(fo.description ?? fo.getRainLabel(), style: GoogleFonts.poppins(
                    color: SettingsService.textMutedColor, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
                ),
                const Spacer(),
                // Rain probability bar
                SizedBox(width: 50, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${fo.rainProbability}%', style: GoogleFonts.poppins(
                    color: const Color(0xFF83B4FF), fontSize: 10)),
                  const SizedBox(height: 2),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fo.rainProbability / 100,
                      backgroundColor: SettingsService.cardColor,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF83B4FF)),
                      minHeight: 3)),
                ])),
                const SizedBox(width: 12),
                // Temp range
                Row(children: [
                  Text('${isCelsius ? fo.maxTemp.toInt() : (fo.maxTemp * 9 / 5 + 32).toInt()}°', style: GoogleFonts.poppins(
                    color: SettingsService.textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(' / ${isCelsius ? fo.minTemp.toInt() : (fo.minTemp * 9 / 5 + 32).toInt()}°', style: GoogleFonts.poppins(
                    color: SettingsService.textMutedColor, fontSize: 12)),
                ]),
              ]),
            );
          }),
        ),
      ),
    ]);
  }

  // ── City List Section (cuộn xuống thấy) ──────────────────
  Widget _buildCityListSection(bool isCelsius) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Thành Phố Lớn'),
      const SizedBox(height: 10),
      ...List.generate(_cities.length, (i) => _buildCityCard(i, isCelsius)),
    ]);
  }

  // ── City Card UI ──────────────────────────────────────────
  Widget _buildCityCard(int index, bool isCelsius) {
    final City city = _cities[index];
    final d = _dataManager.allCitiesData[index];
    final Weather w = d['weather'];
    final bool isSelected = index == _selectedCityIndex;

    return GestureDetector(
      onTap: () => _selectCity(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [SettingsService.primaryGradientStart, SettingsService.primaryGradientEnd])
              : null,
          color: isSelected ? null : SettingsService.cardBorderColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC427FB).withValues(alpha: 0.5)
                : SettingsService.cardColor),
          boxShadow: isSelected ? [
            BoxShadow(color: SettingsService.primaryGradientStart.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ] : [],
        ),
        child: Row(children: [
          // Weather icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusColor(w.status).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(w.status), color: _statusColor(w.status), size: 20),
          ),
          const SizedBox(width: 12),

          // City info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(city.name, style: GoogleFonts.poppins(
                color: SettingsService.textColor, fontSize: 15, fontWeight: FontWeight.w600)),
              if (city.isFavorite) ...[
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
              ],
            ]),
            Text('Lat: ${city.latitude} | Lon: ${city.longitude}',
              style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 10)),
          ])),

          // Temperature
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${isCelsius ? w.temperature.toInt() : (w.temperature * 9 / 5 + 32).toInt()}°',
              style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            Text(w.status, style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 11)),
          ]),
          const SizedBox(width: 8),

          // Favorite button
          GestureDetector(
            onTap: () => _toggleFavorite(index),
            child: Icon(
              city.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: city.isFavorite ? const Color(0xFFFFD700) : SettingsService.textMutedColor,
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
      onTap: () {
        firestoreService.addCity({
          'name': 'New City',
          'temperature': 30,
          'status': 'Clear',
        });
      },
      child: Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [SettingsService.primaryGradientStart, SettingsService.primaryGradientEnd]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: const Color(0xFFC427FB).withValues(alpha: 0.3),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_location_alt_rounded, color: SettingsService.textColor, size: 20),
          const SizedBox(width: 8),
          Text('Thêm vào Firestore', style: GoogleFonts.poppins(
            color: SettingsService.textColor, fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: SettingsService.footerBgColor,
        border: Border(top: BorderSide(color: SettingsService.cardBorderColor)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Icon(Icons.school_rounded, size: 12, color: SettingsService.accentTitleColor),
          const SizedBox(width: 6),
          Text('Phenikaa University', style: GoogleFonts.poppins(
            fontSize: 11, color: SettingsService.accentTitleColor, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 3),
        Text('Dương Ngọc Tú (22010052) • Ngô Thành Long (23010032) • Lê Minh Quang (21012086)',
          style: GoogleFonts.poppins(fontSize: 9, color: SettingsService.textMutedColor),
          overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: GoogleFonts.poppins(
    color: SettingsService.accentTitleColor, fontSize: 14, fontWeight: FontWeight.w700));
}

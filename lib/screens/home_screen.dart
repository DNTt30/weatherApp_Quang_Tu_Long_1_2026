import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../service/firestore_service.dart';
import '../service/settings_service.dart';
import '../service/weather_data_manager.dart';
import '../service/api_service.dart';

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

  final Set<String> _favoriteCities = {};
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadFavoritesFromFirestore();
  }

  Future<void> _loadFavoritesFromFirestore() async {
    try {
      final favorites = await firestoreService.getFavoriteCities();
      if (mounted) {
        setState(() {
          _favoriteCities.clear();
          _favoriteCities.addAll(favorites);
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải thành phố yêu thích từ Firestore: $e");
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectCity(String cityName) {
    _animCtrl.forward(from: 0);
    WeatherDataManager.activeCityName.value = cityName;
    
    // Tìm tọa độ trong dữ liệu để lưu vào lịch sử
    final cityData = _dataManager.allCitiesData.firstWhere(
      (c) => c['city'].toString().toLowerCase() == cityName.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );
    if (cityData.isNotEmpty) {
      firestoreService.saveSearchHistory(
        cityData['city'],
        lat: cityData['lat'],
        lon: cityData['lon'],
      );
    }
  }

  void _toggleFavorite(String cityName) {
    setState(() {
      if (_favoriteCities.contains(cityName)) {
        _favoriteCities.remove(cityName);
        firestoreService.toggleFavoriteCity(cityName, false);
      } else {
        _favoriteCities.add(cityName);
        firestoreService.toggleFavoriteCity(cityName, true);
      }
    });
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

    return ValueListenableBuilder<String>(
      valueListenable: WeatherDataManager.activeCityName,
      builder: (context, activeName, _) {
        // Tìm dữ liệu thời tiết cho thành phố đang hoạt động
        int selectedIndex = _dataManager.allCitiesData.indexWhere(
          (element) => element['city'].toString().toLowerCase() == activeName.toLowerCase(),
        );
        if (selectedIndex == -1) {
          selectedIndex = 0; // fallback
        }

        final d = _dataManager.allCitiesData[selectedIndex];
        
        // Tạo danh sách City động đồng bộ từ allCitiesData
        final List<City> currentCities = List.generate(_dataManager.allCitiesData.length, (i) {
          final cityData = _dataManager.allCitiesData[i];
          final String cityName = cityData['city'];
          return City(
            id: i + 1,
            name: cityName,
            latitude: cityData['lat'] ?? 0.0,
            longitude: cityData['lon'] ?? 0.0,
            isFavorite: _favoriteCities.contains(cityName),
          );
        });

        final City selectedCity = currentCities[selectedIndex];
        final Weather weather = d['weather'];
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
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: Column(children: [
                            _buildHomeSearchBar(),
                            _buildQuickSelectChips(currentCities, activeName),
                            _buildMainCard(weather, selectedCity, isCelsius),
                            const SizedBox(height: 20),
                            _buildHourlyForecast(isCelsius),
                            const SizedBox(height: 20),
                            _buildForecastList(forecasts, isCelsius),
                            const SizedBox(height: 20),
                            _buildCityListSection(currentCities, activeName, isCelsius),
                            const SizedBox(height: 20),
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
      },
    );
  }

  // ── Home Search Bar & Chips ───────────────────────────────
  Widget _buildHomeSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.poppins(color: SettingsService.textColor),
        decoration: InputDecoration(
          hintText: 'Tìm thành phố trực tiếp...',
          hintStyle: GoogleFonts.poppins(color: SettingsService.textMutedColor),
          prefixIcon: Icon(Icons.search, color: SettingsService.textMutedColor),
          suffixIcon: _isSearching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC427FB)),
                  ),
                )
              : null,
          filled: true,
          fillColor: SettingsService.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: SettingsService.cardBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: SettingsService.cardBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFC427FB)),
          ),
        ),
        onSubmitted: (value) async {
          final query = value.trim();
          if (query.isNotEmpty) {
            setState(() {
              _isSearching = true;
            });
            
            try {
              final apiService = ApiService();
              final geocodeData = await apiService.geocodeCity(query);
              
              if (geocodeData != null) {
                final double lat = geocodeData['lat'];
                final double lon = geocodeData['lon'];
                final String cityName = geocodeData['name'];
                final String country = geocodeData['country'];
                
                final weatherResult = await apiService.fetchWeatherData(lat, lon, cityName);
                final Weather weather = weatherResult['weather'];
                final List<Forecast> forecasts = weatherResult['forecasts'];
                
                final firestore = FirestoreService();
                await firestore.saveCity(cityName, {
                  'name': cityName,
                  'country': country,
                  'latitude': lat,
                  'longitude': lon,
                });
                
                await firestore.saveWeather(cityName, weather.toMap());
                await firestore.saveForecast(cityName, forecasts.map((e) => e.toMap()).toList());
                await firestore.saveSearchHistory(cityName, lat: lat, lon: lon);
                
                // Cập nhật bộ nhớ đệm
                _dataManager.allCitiesData.removeWhere((element) => element['city'].toString().toLowerCase() == cityName.toLowerCase());
                _dataManager.allCitiesData.insert(0, {
                  'city': cityName,
                  'lat': lat,
                  'lon': lon,
                  'weather': weather,
                  'forecasts': forecasts,
                });
                
                // Cập nhật các vùng lân cận và đổi activeCityName
                await _dataManager.loadAllData();
                WeatherDataManager.activeCityName.value = cityName;
                _searchCtrl.clear();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không tìm thấy thành phố này')),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã có lỗi xảy ra khi tìm kiếm')),
                );
              }
            } finally {
              if (mounted) {
                setState(() {
                  _isSearching = false;
                });
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildQuickSelectChips(List<City> cities, String activeCityName) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          final bool isActive = city.name.toLowerCase() == activeCityName.toLowerCase();
          
          return GestureDetector(
            onTap: () => _selectCity(city.name),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(colors: [SettingsService.primaryGradientStart, SettingsService.primaryGradientEnd])
                    : null,
                color: isActive ? null : SettingsService.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFC427FB).withValues(alpha: 0.5)
                      : SettingsService.cardBorderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (city.isFavorite) ...[
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    city.name,
                    style: GoogleFonts.poppins(
                      color: isActive ? Colors.white : SettingsService.textColor,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
              Icon(Icons.location_on_rounded, color: Colors.white.withValues(alpha: 0.9), size: 16),
              const SizedBox(width: 4),
              Text(city.name, style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _toggleFavorite(city.name),
                child: Icon(
                  city.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: city.isFavorite ? const Color(0xFFFFD700) : Colors.white60,
                  size: 20,
                ),
              ),
            ]),
            Text(city.getCityInfo().split('|').last.trim(),
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
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
              color: Colors.white, fontSize: 68,
              fontWeight: FontWeight.w200, height: 1),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(weather.status, style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.9), fontSize: 16)),
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
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(warning, style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 11)),
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
  Widget _buildCityListSection(List<City> cities, String activeCityName, bool isCelsius) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Thành Phố Lớn'),
      const SizedBox(height: 10),
      ...List.generate(cities.length, (i) => _buildCityCard(cities, i, activeCityName, isCelsius)),
    ]);
  }

  // ── City Card UI ──────────────────────────────────────────
  Widget _buildCityCard(List<City> cities, int index, String activeCityName, bool isCelsius) {
    final City city = cities[index];
    final d = _dataManager.allCitiesData[index];
    final Weather w = d['weather'];
    final bool isSelected = city.name.toLowerCase() == activeCityName.toLowerCase();

    return GestureDetector(
      onTap: () => _selectCity(city.name),
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
                color: isSelected ? Colors.white : SettingsService.textColor, fontSize: 15, fontWeight: FontWeight.w600)),
              if (city.isFavorite) ...[
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
              ],
            ]),
            Text('Lat: ${city.latitude} | Lon: ${city.longitude}',
              style: GoogleFonts.poppins(color: isSelected ? Colors.white70 : SettingsService.textMutedColor, fontSize: 10)),
          ])),

          // Temperature
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${isCelsius ? w.temperature.toInt() : (w.temperature * 9 / 5 + 32).toInt()}°',
              style: GoogleFonts.poppins(color: isSelected ? Colors.white : SettingsService.textColor, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            Text(w.status, style: GoogleFonts.poppins(color: isSelected ? Colors.white70 : SettingsService.textMutedColor, fontSize: 11)),
          ]),
          const SizedBox(width: 8),

          // Favorite button
          GestureDetector(
            onTap: () => _toggleFavorite(city.name),
            child: Icon(
              city.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: city.isFavorite ? const Color(0xFFFFD700) : (isSelected ? Colors.white70 : SettingsService.textMutedColor),
              size: 22,
            ),
          ),
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

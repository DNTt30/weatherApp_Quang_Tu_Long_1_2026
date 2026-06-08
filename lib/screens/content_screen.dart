import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/forecast.dart';
import '../models/weather.dart';
import '../service/settings_service.dart';
import '../service/weather_data_manager.dart';
import '../service/firestore_service.dart';

// ============================================================
// ContentScreen — Long phụ trách
// Cảnh báo thời tiết | Tốc độ gió, độ ẩm, UV | Dự báo 5 ngày 
// ============================================================
class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataManager = WeatherDataManager();
    
    if (dataManager.allCitiesData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Lấy thành phố đầu tiên (Hà Nội) làm mặc định cho trang hiển thị chi tiết
    final Map<String, dynamic> firstCity = dataManager.allCitiesData[0];
    final Weather currentWeather = firstCity['weather'];
    final List<Forecast> forecasts = firstCity['forecasts'];

    // Danh sách weather của tất cả các thành phố để so sánh
    final List<Weather> cityWeathers = dataManager.allCitiesData
        .map((e) => e['weather'] as Weather)
        .toList();

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
            _buildSearchBar(),
            _buildRecentSearches(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(children: [
                  // Weather warning card
                  if (currentWeather.getWarning() != null) ...[
                    _buildWarningCard(currentWeather),
                    const SizedBox(height: 16),
                  ],

                  // Weather stats (humidity, wind, UV)
                  _buildWeatherStats(currentWeather),
                  const SizedBox(height: 20),

                  // Hourly forecast
                  _sectionLabel('Dự Báo Theo Giờ'),
                  const SizedBox(height: 10),
                  _buildHourlyRow(isCelsius),
                  const SizedBox(height: 20),

                  // 5-day forecast cards
                  _sectionLabel('Dự Báo Chi Tiết 5 Ngày'),
                  const SizedBox(height: 10),
                  ...forecasts.map((fo) => _buildForecastCard(fo, isCelsius)),

                  const SizedBox(height: 20),

                  // City comparison table
                  _sectionLabel('So Sánh Thành Phố'),
                  const SizedBox(height: 10),
                  _buildComparisonTable(cityWeathers, isCelsius),

                  const SizedBox(height: 4),
                ]),
              ),
            ),
            _buildFooter(),
          ]);
        }
      ),
    );
    },
    );
  }

  // ── Search Bar ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: TextField(
        style: GoogleFonts.poppins(color: SettingsService.textColor),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm thành phố...',
          hintStyle: GoogleFonts.poppins(color: SettingsService.textMutedColor),
          prefixIcon: Icon(Icons.search, color: SettingsService.textMutedColor),
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
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            FirestoreService().saveSearchHistory(value.trim());
            // In a real app, this would trigger a weather search.
          }
        },
      ),
    );
  }

  // ── Recent Searches ───────────────────────────────────────
  Widget _buildRecentSearches() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService().getSearchHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        
        final searches = snapshot.data!.take(5).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Searches', style: GoogleFonts.poppins(color: SettingsService.textDimColor, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searches.map((s) {
                  return InkWell(
                    onTap: () {
                      // Trigger search
                      FirestoreService().saveSearchHistory(s['cityName']);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: SettingsService.cardBorderColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SettingsService.cardColor),
                      ),
                      child: Text(s['cityName'], style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ── Warning Card ──────────────────────────────────────────
  Widget _buildWarningCard(Weather weather) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFC427FB).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC427FB).withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Color(0xFFC427FB), size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(weather.getWarning()!, style: GoogleFonts.poppins(
          color: SettingsService.accentTitleColor, fontSize: 12))),
      ]),
    );
  }

  // ── Weather Stats Grid: Humidity / Wind / UV ──────────────
  Widget _buildWeatherStats(Weather weather) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Chỉ Số Thời Tiết'),
      const SizedBox(height: 10),
      Row(children: [
        // Humidity
        Expanded(child: _buildStatCard(
          icon: Icons.water_drop_rounded,
          iconColor: const Color(0xFF83B4FF),
          label: 'Độ ẩm',
          value: '${weather.humidity.toInt()}%',
          progress: weather.humidity / 100,
          progressColor: const Color(0xFF83B4FF),
          subLabel: weather.humidity > 80 ? 'Rất ẩm' : 'Bình thường',
        )),
        const SizedBox(width: 10),
        // Wind
        Expanded(child: _buildStatCard(
          icon: Icons.air_rounded,
          iconColor: const Color(0xFFAEC9FF),
          label: 'Tốc độ gió',
          value: '${weather.windSpeed.toInt()}km/h',
          progress: (weather.windSpeed / 80).clamp(0.0, 1.0),
          progressColor: const Color(0xFFAEC9FF),
          subLabel: weather.getWindLabel(),
        )),
      ]),
      const SizedBox(height: 10),
      // UV Index full-width
      _buildUvCard(weather),
    ]);
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double progress,
    required Color progressColor,
    required String subLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SettingsService.cardBorderColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettingsService.cardColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(
          color: SettingsService.textColor, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: SettingsService.cardColor,
            valueColor: AlwaysStoppedAnimation(progressColor),
            minHeight: 6)),
        const SizedBox(height: 4),
        Text(subLabel, style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 10)),
      ]),
    );
  }

  Widget _buildUvCard(Weather weather) {
    final double uvProgress = (weather.uvIndex / 11).clamp(0.0, 1.0);
    final Color uvColor = weather.uvIndex <= 2
        ? Colors.green
        : weather.uvIndex <= 5
            ? Colors.yellow
            : weather.uvIndex <= 7
                ? Colors.orange
                : Colors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SettingsService.cardBorderColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettingsService.cardColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.wb_sunny_outlined, color: Color(0xFFFFD700), size: 18),
            const SizedBox(width: 6),
            Text('Chỉ số UV', style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: uvColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: uvColor.withValues(alpha: 0.5)),
            ),
            child: Text(weather.getUvLabel(), style: GoogleFonts.poppins(
              color: uvColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('${weather.uvIndex}', style: GoogleFonts.poppins(
            color: SettingsService.textColor, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text('/11', style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 16)),
          const Spacer(),
          Text('Đo lúc 12:00', style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 10)),
        ]),
        const SizedBox(height: 8),
        // UV scale bar
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: uvProgress,
            backgroundColor: SettingsService.cardColor,
            valueColor: AlwaysStoppedAnimation(uvColor),
            minHeight: 8)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Thấp', style: GoogleFonts.poppins(color: Colors.green, fontSize: 9)),
          Text('TB', style: GoogleFonts.poppins(color: Colors.yellow, fontSize: 9)),
          Text('Cao', style: GoogleFonts.poppins(color: Colors.orange, fontSize: 9)),
          Text('Rất cao', style: GoogleFonts.poppins(color: Colors.red, fontSize: 9)),
        ]),
      ]),
    );
  }

  // ── Hourly Forecast Row ───────────────────────────────────
  Widget _buildHourlyRow(bool isCelsius) {
    final hours = [
      {'time':'09:00','temp':28,'icon':Icons.wb_sunny_rounded,'color':const Color(0xFFFFD700),'rain':5},
      {'time':'11:00','temp':31,'icon':Icons.wb_sunny_rounded,'color':const Color(0xFFFFD700),'rain':5},
      {'time':'13:00','temp':33,'icon':Icons.wb_sunny_rounded,'color':const Color(0xFFFFD700),'rain':10},
      {'time':'15:00','temp':32,'icon':Icons.cloud_rounded,   'color':const Color(0xFFB0C4DE),'rain':25},
      {'time':'17:00','temp':29,'icon':Icons.cloud_rounded,   'color':const Color(0xFFB0C4DE),'rain':40},
      {'time':'19:00','temp':27,'icon':Icons.grain_rounded,   'color':const Color(0xFF83B4FF),'rain':70},
      {'time':'21:00','temp':25,'icon':Icons.nights_stay_rounded,'color':const Color(0xFF9575CD),'rain':60},
    ];
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: SettingsService.cardBorderColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SettingsService.cardBorderColor),
            ),
            child: Column(children: [
              Text(h['time'] as String, style: GoogleFonts.poppins(
                color: SettingsService.accentTitleColor, fontSize: 11)),
              const SizedBox(height: 10),
              Icon(h['icon'] as IconData, color: h['color'] as Color, size: 22),
              const SizedBox(height: 6),
              Text('${isCelsius ? h['temp'] : ((h['temp'] as int) * 9 / 5 + 32).toInt()}°', style: GoogleFonts.poppins(
                color: SettingsService.textColor, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.water_drop_rounded, size: 9, color: Color(0xFF83B4FF)),
                const SizedBox(width: 1),
                Text('${h['rain']}%', style: GoogleFonts.poppins(
                  color: const Color(0xFF83B4FF), fontSize: 9)),
              ]),
            ]),
          )).toList(),
        ),
      ),
    );
  }

  // ── Forecast Card ─────────────────────────────────────────
  Widget _buildForecastCard(Forecast fo, bool isCelsius) {
    final bool highRain = fo.rainProbability > 50;
    final Color iconColor = highRain ? const Color(0xFF83B4FF) : const Color(0xFFFFD700);
    final IconData icon = highRain ? Icons.grain_rounded : Icons.wb_sunny_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SettingsService.cardBorderColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SettingsService.cardColor),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(fo.dateTime, style: GoogleFonts.poppins(
            color: SettingsService.textColor, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(fo.description ?? fo.getRainLabel(), style: GoogleFonts.poppins(
            color: SettingsService.textMutedColor, fontSize: 11)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.water_drop_rounded, size: 11, color: Color(0xFF83B4FF)),
            const SizedBox(width: 3),
            Text('${fo.rainProbability}%  •  Chênh lệch: ${isCelsius ? fo.getTemperatureDifference().toStringAsFixed(1) : (fo.getTemperatureDifference() * 9 / 5).toStringAsFixed(1)}°',
              style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 10)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fo.rainProbability / 100,
              backgroundColor: SettingsService.cardColor,
              valueColor: AlwaysStoppedAnimation(highRain ? const Color(0xFF83B4FF) : const Color(0xFF83B4FF).withValues(alpha: 0.4)),
              minHeight: 4)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${isCelsius ? fo.maxTemp.toInt() : (fo.maxTemp * 9 / 5 + 32).toInt()}°', style: GoogleFonts.poppins(
            color: SettingsService.textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${isCelsius ? fo.minTemp.toInt() : (fo.minTemp * 9 / 5 + 32).toInt()}°', style: GoogleFonts.poppins(
            color: SettingsService.textMutedColor, fontSize: 13)),
          Text('TB: ${isCelsius ? fo.getAverageTemp().toStringAsFixed(0) : (fo.getAverageTemp() * 9 / 5 + 32).toStringAsFixed(0)}°',
            style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 10)),
        ]),
      ]),
    );
  }

  // ── City Comparison Table ─────────────────────────────────
  Widget _buildComparisonTable(List<Weather> weathers, bool isCelsius) {
    return Container(
      decoration: BoxDecoration(
        color: SettingsService.cardBorderColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettingsService.cardColor),
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [SettingsService.primaryGradientStart, SettingsService.primaryGradientEnd]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Expanded(flex:3, child: Text('Thành Phố', style: GoogleFonts.poppins(color: SettingsService.textColor, fontWeight: FontWeight.w600, fontSize: 11))),
            Expanded(flex:2, child: Text('Nhiệt Độ',  textAlign: TextAlign.center, style: GoogleFonts.poppins(color: SettingsService.textColor, fontWeight: FontWeight.w600, fontSize: 11))),
            Expanded(flex:2, child: Text('Độ Ẩm',     textAlign: TextAlign.center, style: GoogleFonts.poppins(color: SettingsService.textColor, fontWeight: FontWeight.w600, fontSize: 11))),
            Expanded(flex:2, child: Text('Gió',        textAlign: TextAlign.center, style: GoogleFonts.poppins(color: SettingsService.textColor, fontWeight: FontWeight.w600, fontSize: 11))),
            Expanded(flex:1, child: Text('UV',         textAlign: TextAlign.center, style: GoogleFonts.poppins(color: SettingsService.textColor, fontWeight: FontWeight.w600, fontSize: 11))),
          ]),
        ),
        // Rows
        ...List.generate(weathers.length, (i) {
          final w = weathers[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: i.isEven ? SettingsService.cardBorderColor : Colors.transparent,
              borderRadius: i == weathers.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(20)) : null,
              border: i < weathers.length - 1 ? Border(bottom: BorderSide(color: SettingsService.cardBorderColor)) : null,
            ),
            child: Row(children: [
              Expanded(flex:3, child: Text(w.city, style: GoogleFonts.poppins(
                color: SettingsService.accentTitleColor, fontSize: 12, fontWeight: FontWeight.w500))),
              Expanded(flex:2, child: Text('${isCelsius ? w.temperature.toInt() : (w.temperature * 9 / 5 + 32).toInt()}°', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: SettingsService.textDimColor, fontSize: 12))),
              Expanded(flex:2, child: Text('${w.humidity.toInt()}%', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12))),
              Expanded(flex:2, child: Text('${w.windSpeed.toInt()}', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12))),
              Expanded(flex:1, child: Text('${w.uvIndex}', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: w.uvIndex >= 7 ? Colors.orange : SettingsService.textMutedColor, fontSize: 12, fontWeight: FontWeight.bold))),
            ]),
          );
        }),
      ]),
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
        Text('Dương Ngọc Tú • Ngô Thành Long • Lê Minh Quang',
          style: GoogleFonts.poppins(fontSize: 9, color: SettingsService.textMutedColor)),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: GoogleFonts.poppins(
    color: SettingsService.accentTitleColor, fontSize: 14, fontWeight: FontWeight.w700));
}

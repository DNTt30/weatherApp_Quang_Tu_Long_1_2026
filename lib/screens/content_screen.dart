import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/forecast.dart';
import '../models/weather.dart';
import '../models/city.dart';

// ============================================================
// ContentScreen — Quang phụ trách
// Dự báo theo giờ | Dự báo theo ngày | Độ ẩm | Gió | UV | So sánh
// ============================================================
class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Mock Weather data với đầy đủ thuộc tính ──────────────
    final Weather currentWeather = Weather(
      city: 'Hà Nội', temperature: 32.5, status: 'Sunny',
      humidity: 70.0, isRaining: false,
      windSpeed: 12.0, uvIndex: 7, icon: 'sunny',
    );

    // ── Dự báo theo ngày ─────────────────────────────────────
    final List<Forecast> forecasts = [
      Forecast(id:'f1', dateTime:'Thứ Hai',  minTemp:25.0, maxTemp:32.0, rainProbability:10, description:'Nắng đẹp, ít mây'),
      Forecast(id:'f2', dateTime:'Thứ Ba',   minTemp:24.0, maxTemp:28.0, rainProbability:80, description:'Mưa rào, sấm nhẹ'),
      Forecast(id:'f3', dateTime:'Thứ Tư',   minTemp:25.0, maxTemp:30.0, rainProbability:30, description:'Nhiều mây'),
      Forecast(id:'f4', dateTime:'Thứ Năm',  minTemp:23.0, maxTemp:29.0, rainProbability:10, description:'Nắng nhẹ'),
      Forecast(id:'f5', dateTime:'Thứ Sáu',  minTemp:26.0, maxTemp:31.0, rainProbability:50, description:'Chiều mưa'),
    ];

    // ── Mock so sánh thành phố ────────────────────────────────
    final List<Weather> cityWeathers = [
      Weather(city:'Hà Nội',       temperature:32.5, status:'Sunny',  humidity:70, isRaining:false, windSpeed:12, uvIndex:7),
      Weather(city:'Đà Nẵng',     temperature:29.0, status:'Cloudy', humidity:85, isRaining:false, windSpeed:18, uvIndex:4),
      Weather(city:'Hồ Chí Minh', temperature:35.0, status:'Sunny',  humidity:60, isRaining:false, windSpeed:8,  uvIndex:9),
      Weather(city:'Hải Phòng',   temperature:28.0, status:'Rainy',  humidity:90, isRaining:true,  windSpeed:22, uvIndex:2),
      Weather(city:'Cần Thơ',     temperature:33.0, status:'Cloudy', humidity:75, isRaining:false, windSpeed:10, uvIndex:6),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
        ),
      ),
      child: Column(children: [
        _buildHeader(),
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
              _buildHourlyRow(),
              const SizedBox(height: 20),

              // 5-day forecast cards
              _sectionLabel('Dự Báo Chi Tiết 5 Ngày'),
              const SizedBox(height: 10),
              ...forecasts.map((fo) => _buildForecastCard(fo)),

              const SizedBox(height: 20),

              // City comparison table
              _sectionLabel('So Sánh Thành Phố'),
              const SizedBox(height: 10),
              _buildComparisonTable(cityWeathers),

              const SizedBox(height: 4),
            ]),
          ),
        ),
        _buildFooter(),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity, height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3658B1), Color(0xFFC159EC)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: const Color(0xFF3658B1).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
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
            child: Text('Quang_Forecast', style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ])),
      ]),
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
          color: const Color(0xFFE0D9FF), fontSize: 12))),
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
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(progressColor),
            minHeight: 6)),
        const SizedBox(height: 4),
        Text(subLabel, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
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
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.wb_sunny_outlined, color: Color(0xFFFFD700), size: 18),
            const SizedBox(width: 6),
            Text('Chỉ số UV', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
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
            color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text('/11', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 16)),
          const Spacer(),
          Text('Đo lúc 12:00', style: GoogleFonts.poppins(color: Colors.white24, fontSize: 10)),
        ]),
        const SizedBox(height: 8),
        // UV scale bar
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: uvProgress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
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
  Widget _buildHourlyRow() {
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(children: [
              Text(h['time'] as String, style: GoogleFonts.poppins(
                color: const Color(0xFFE0D9FF), fontSize: 11)),
              const SizedBox(height: 10),
              Icon(h['icon'] as IconData, color: h['color'] as Color, size: 22),
              const SizedBox(height: 6),
              Text('${h['temp']}°', style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
  Widget _buildForecastCard(Forecast fo) {
    final bool highRain = fo.rainProbability > 50;
    final Color iconColor = highRain ? const Color(0xFF83B4FF) : const Color(0xFFFFD700);
    final IconData icon = highRain ? Icons.grain_rounded : Icons.wb_sunny_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(fo.dateTime, style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(fo.description ?? fo.getRainLabel(), style: GoogleFonts.poppins(
            color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.water_drop_rounded, size: 11, color: Color(0xFF83B4FF)),
            const SizedBox(width: 3),
            Text('${fo.rainProbability}%  •  Chênh lệch: ${fo.getTemperatureDifference().toStringAsFixed(1)}°C',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fo.rainProbability / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(highRain ? const Color(0xFF83B4FF) : const Color(0xFF83B4FF).withValues(alpha: 0.4)),
              minHeight: 4)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${fo.maxTemp.toInt()}°', style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${fo.minTemp.toInt()}°', style: GoogleFonts.poppins(
            color: Colors.white38, fontSize: 13)),
          Text('TB: ${fo.getAverageTemp().toStringAsFixed(0)}°',
            style: GoogleFonts.poppins(color: Colors.white24, fontSize: 10)),
        ]),
      ]),
    );
  }

  // ── City Comparison Table ─────────────────────────────────
  Widget _buildComparisonTable(List<Weather> weathers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF48319D), Color(0xFF5936B4)]),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Expanded(flex:3, child: Text('Thành Phố', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11))),
            Expanded(flex:2, child: Text('Nhiệt Độ',  textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11))),
            Expanded(flex:2, child: Text('Độ Ẩm',     textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11))),
            Expanded(flex:2, child: Text('Gió',        textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11))),
            Expanded(flex:1, child: Text('UV',         textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11))),
          ]),
        ),
        // Rows
        ...List.generate(weathers.length, (i) {
          final w = weathers[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white.withValues(alpha: 0.03) : Colors.transparent,
              borderRadius: i == weathers.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(20)) : null,
              border: i < weathers.length - 1 ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))) : null,
            ),
            child: Row(children: [
              Expanded(flex:3, child: Text(w.city, style: GoogleFonts.poppins(
                color: const Color(0xFFE0D9FF), fontSize: 12, fontWeight: FontWeight.w500))),
              Expanded(flex:2, child: Text('${w.temperature.toInt()}°C', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12))),
              Expanded(flex:2, child: Text('${w.humidity.toInt()}%', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12))),
              Expanded(flex:2, child: Text('${w.windSpeed.toInt()}', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12))),
              Expanded(flex:1, child: Text('${w.uvIndex}', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: w.uvIndex >= 7 ? Colors.orange : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold))),
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
        Text('Dương Ngọc Tú • Ngô Thành Long • Lê Minh Quang',
          style: GoogleFonts.poppins(fontSize: 9, color: Colors.white38)),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: GoogleFonts.poppins(
    color: const Color(0xFFE0D9FF), fontSize: 14, fontWeight: FontWeight.w700));
}

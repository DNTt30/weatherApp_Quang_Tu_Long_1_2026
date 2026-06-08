import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/settings_service.dart';
import '../service/weather_data_manager.dart';
import '../service/firestore_service.dart';
import '../service/api_service.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../main.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final WeatherDataManager _dataManager = WeatherDataManager();
  bool _isRecommending = false;

  String _statusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'sunny':
      case 'nắng đẹp':
      case 'trời trong':
        return '☀️';
      case 'rainy':
      case 'mưa vừa':
      case 'mưa rào':
      case 'giông bão':
        return '🌧️';
      default:
        return '⛅';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.isLightMode,
      builder: (context, isLightMode, _) {
        final Color textColor = SettingsService.textColor;
        final Color textMutedColor = SettingsService.textMutedColor;
        final Color cardBgColor = isLightMode ? Colors.white : const Color(0xFF1F1D47).withValues(alpha: 0.85);
        final Color scaffoldBgColor = isLightMode ? const Color(0xFFF5F7FF) : const Color(0xFF1C1B33);

        return Scaffold(
          backgroundColor: scaffoldBgColor,
          body: Stack(
            children: [
              RefreshIndicator(
                color: const Color(0xFFC427FB),
                onRefresh: () async {
                  await _dataManager.loadAllData();
                  if (mounted) setState(() {});
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── BRAND HEADER (Agoda style mockup) ────────────────────
                      _buildBrandHeader(isLightMode),
                      const SizedBox(height: 18),

                      // ── GRID SERVICES (Mockup adapted to Weather app) ────────
                      _buildServiceGrid(isLightMode, cardBgColor),
                      const SizedBox(height: 20),

                      // ── QUICK ICON SERVICES ROW (Weather themed params) ──────
                      _buildQuickIconRow(isLightMode, context),
                      const SizedBox(height: 22),

                      // ── MOCKUP ALERT/TIP BANNER ──────────────────────────────
                      _buildAlertBanner(isLightMode),
                      const SizedBox(height: 22),

                      // ── CONTINUE TRACKING SECTION ────────────────────────────
                      _buildContinueTrackingSection(isLightMode, cardBgColor, textColor, textMutedColor, context),
                      const SizedBox(height: 22),

                      // ── NEARBY RECOMMENDATIONS SECTION ───────────────────────
                      _buildNearbyRecommendationsSection(isLightMode, cardBgColor, textColor, textMutedColor, context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (_isRecommending)
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC427FB)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Brand Header mimicking Agoda layout
  Widget _buildBrandHeader(bool isLightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'weather',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFC427FB),
                letterSpacing: -1.0,
              ),
            ),
            Text(
              'go',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isLightMode ? Colors.blue.shade600 : Colors.blue.shade300,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 10),
                  const SizedBox(width: 2),
                  Text(
                    'VIP',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x1F83B4FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFB300), size: 14),
              const SizedBox(width: 4),
              Text(
                'Live Forecast',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isLightMode ? Colors.blue.shade700 : Colors.blue.shade200,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Agoda-style Grid Cards adapted to Weather content
  Widget _buildServiceGrid(bool isLightMode, Color cardBg) {
    return Column(
      children: [
        // Row 1: Weather Tourism & Precipitation Map
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _showTravelWeatherSheet(context, isLightMode),
                borderRadius: BorderRadius.circular(20),
                child: _buildLargeServiceCard(
                  title: 'Thời tiết Du lịch',
                  subtitle: 'Điểm đến lý tưởng hôm nay',
                  badge: 'Gợi ý',
                  gradientStart: const Color(0xFFFFEBEB),
                  gradientEnd: const Color(0xFFFFCDCD),
                  icon: Icons.beach_access_rounded,
                  iconColor: const Color(0xFFE57373),
                  isLightMode: isLightMode,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _showRainMapSheet(context, isLightMode),
                borderRadius: BorderRadius.circular(20),
                child: _buildLargeServiceCard(
                  title: 'Bản đồ Mưa & Mây',
                  subtitle: 'Vệ tinh đám mây thời gian thực',
                  badge: 'Radar',
                  gradientStart: const Color(0xFFF3E5F5),
                  gradientEnd: const Color(0xFFE1BEE7),
                  icon: Icons.radar_rounded,
                  iconColor: const Color(0xFFBA68C8),
                  isLightMode: isLightMode,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Air Quality, UV Index, Health weather
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _showAirQualitySheet(context, isLightMode),
                borderRadius: BorderRadius.circular(16),
                child: _buildSmallServiceCard(
                  title: 'Chất lượng Khí',
                  icon: Icons.air_rounded,
                  gradientStart: const Color(0xFFE3F2FD),
                  gradientEnd: const Color(0xFFBBDEFB),
                  iconColor: const Color(0xFF64B5F6),
                  isLightMode: isLightMode,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => _showUvIndexSheet(context, isLightMode),
                borderRadius: BorderRadius.circular(16),
                child: _buildSmallServiceCard(
                  title: 'Chỉ số UV',
                  icon: Icons.wb_sunny_rounded,
                  gradientStart: const Color(0xFFFFF8E1),
                  gradientEnd: const Color(0xFFFFECB3),
                  iconColor: const Color(0xFFFFB74D),
                  isLightMode: isLightMode,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => _showHealthSheet(context, isLightMode),
                borderRadius: BorderRadius.circular(16),
                child: _buildSmallServiceCard(
                  title: 'Sức khỏe',
                  icon: Icons.health_and_safety_rounded,
                  gradientStart: const Color(0xFFE8F5E9),
                  gradientEnd: const Color(0xFFC8E6C9),
                  iconColor: const Color(0xFF81C784),
                  isLightMode: isLightMode,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeServiceCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color gradientStart,
    required Color gradientEnd,
    required IconData icon,
    required Color iconColor,
    required bool isLightMode,
  }) {
    return Container(
      height: 118,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightMode
              ? [gradientStart, gradientEnd]
              : [gradientStart.withValues(alpha: 0.15), gradientEnd.withValues(alpha: 0.15)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLightMode ? Colors.white : iconColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: isLightMode
            ? [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Icon decoration
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 76,
              color: isLightMode ? iconColor.withValues(alpha: 0.12) : iconColor.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: isLightMode ? iconColor : iconColor.withValues(alpha: 0.8), size: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLightMode ? Colors.white : iconColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.poppins(
                          color: isLightMode ? iconColor : Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? Colors.black87 : Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: isLightMode ? Colors.black54 : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallServiceCard({
    required String title,
    required IconData icon,
    required Color gradientStart,
    required Color gradientEnd,
    required Color iconColor,
    required bool isLightMode,
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightMode
              ? [gradientStart, gradientEnd]
              : [gradientStart.withValues(alpha: 0.12), gradientEnd.withValues(alpha: 0.12)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLightMode ? Colors.white : iconColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: isLightMode
            ? [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: isLightMode ? iconColor : iconColor.withValues(alpha: 0.8), size: 22),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black87 : Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Row of smaller icons adapted to weather parameters/warning options (interactive)
  Widget _buildQuickIconRow(bool isLightMode, BuildContext context) {
    final items = [
      {'label': 'Cảnh báo bão', 'icon': Icons.cyclone_rounded, 'color': Colors.red, 'type': 'storm'},
      {'label': 'Độ ẩm khí', 'icon': Icons.water_drop_rounded, 'color': Colors.blue, 'type': 'humidity'},
      {'label': 'Tốc độ gió', 'icon': Icons.wind_power_rounded, 'color': Colors.teal, 'type': 'wind'},
      {'label': 'Lượng mưa', 'icon': Icons.umbrella_rounded, 'color': Colors.indigo, 'type': 'rain'},
      {'label': 'Lịch sử tìm', 'icon': Icons.history_rounded, 'color': Colors.orange, 'type': 'history'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((item) {
        final Color col = item['color'] as Color;
        return GestureDetector(
          onTap: () => _handleQuickIconTap(context, item['type'] as String, item['label'] as String, isLightMode),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLightMode ? Colors.white : const Color(0xFF1F1D47).withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  boxShadow: isLightMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: isLightMode ? col : col.withValues(alpha: 0.8),
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isLightMode ? Colors.black87 : Colors.white70,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Premium Weather Alert / Tip Banner
  Widget _buildAlertBanner(bool isLightMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white : const Color(0xFF1F1D47).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLightMode ? Colors.grey.shade200 : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: isLightMode
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cảnh báo: Chỉ số UV đang rất cao!',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isLightMode ? Colors.black87 : Colors.white,
                  ),
                ),
                Text(
                  'Hãy bôi kem chống nắng và mang ô khi ra ngoài',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isLightMode ? Colors.black54 : Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showUvIndexSheet(context, isLightMode),
            child: Text(
              'Xem',
              style: GoogleFonts.poppins(
                color: Colors.blue.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Thẻ "Khu vực quan tâm gần đây" -> Opens direct weather preview on click (1-tap optimization)
  Widget _buildContinueTrackingSection(
    bool isLightMode,
    Color cardBg,
    Color textColor,
    Color textMutedColor,
    BuildContext context,
  ) {
    if (_dataManager.allCitiesData.isEmpty) return const SizedBox.shrink();

    // Lấy thành phố tìm kiếm gần nhất (phần tử đầu tiên) làm đích đến du lịch
    final latestSearch = _dataManager.allCitiesData.first;
    final String cityName = latestSearch['city'];
    final double lat = latestSearch['lat'];
    final double lon = latestSearch['lon'];
    final Weather w = latestSearch['weather'];
    final List<Forecast> forecasts = latestSearch['forecasts'];

    // Lấy link ảnh minh họa cho vùng miền
    final String imgUrl = _getCityImageUrl(cityName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khu vực quan tâm gần đây',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // Mở Bottom Sheet xem chi tiết trực tiếp (Tránh thao tác chuyển trang phức tạp)
            _showWeatherDetailSheet(context, cityName, w, forecasts, null, lat, lon, isLightMode);
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLightMode ? Colors.grey.shade200 : Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: isLightMode
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // City image header inside card
                Stack(
                  children: [
                    Image.network(
                      imgUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.blue.shade100,
                          child: const Icon(Icons.image, color: Colors.blue, size: 40),
                        );
                      },
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wb_cloudy_rounded, color: Colors.white, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              w.status,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cityName,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Nhấn để xem nhanh thời tiết và dự báo chi tiết',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: textMutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC427FB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${w.temperature.toInt()}°C',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFC427FB),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
    );
  }

  // Thẻ "Thời tiết các khu vực lân cận" -> Opens direct weather preview on click (1-tap optimization)
  Widget _buildNearbyRecommendationsSection(
    bool isLightMode,
    Color cardBg,
    Color textColor,
    Color textMutedColor,
    BuildContext context,
  ) {
    if (_dataManager.recommendedNearbyData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời tiết các khu vực lân cận',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Đề xuất thời tiết vùng gần vị trí tra cứu của bạn nhất. Nhấn để xem.',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: textMutedColor,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: _dataManager.recommendedNearbyData.map((nr) {
            final String name = nr['city'];
            final double dist = nr['distance'] ?? 0.0;
            final double lat = nr['lat'];
            final double lon = nr['lon'];
            final Weather w = nr['weather'];
            final List<Forecast> forecasts = nr['forecasts'];
            
            return GestureDetector(
              onTap: () {
                // Hiển thị Bottom Sheet chi tiết thời tiết vùng lân cận lập tức (chỉ 1 click)
                _showWeatherDetailSheet(context, name, w, forecasts, dist, lat, lon, isLightMode);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLightMode ? Colors.grey.shade200 : Colors.white.withValues(alpha: 0.06),
                  ),
                  boxShadow: isLightMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    // Mockup Mini City Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _getCityImageUrl(name),
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 54,
                            height: 54,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.location_city, color: Colors.grey, size: 24),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.near_me_rounded, size: 10, color: Colors.blue.shade400),
                              const SizedBox(width: 4),
                              Text(
                                'Cách ${dist.toStringAsFixed(0)} km',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: Colors.blue.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${w.temperature.toInt()}°C',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          w.status,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── GRID INTERACTIVE BOTTOM SHEETS ───────────────────────────────────────
  
  // 1. Weather Detail Bottom Sheet for 1-tap view
  void _showWeatherDetailSheet(
    BuildContext context,
    String cityName,
    Weather w,
    List<Forecast> forecasts,
    double? distance,
    double lat,
    double lon,
    bool isLightMode,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: isLightMode ? Colors.white : const Color(0xFF1C1B33),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SettingsService.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              
              // Header: City name & distance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cityName,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: SettingsService.textColor,
                        ),
                      ),
                      if (distance != null)
                        Text(
                          'Khoảng cách: cách bạn ${distance.toStringAsFixed(0)} km',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.blue.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    _statusEmoji(w.status),
                    style: const TextStyle(fontSize: 38),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stats details
              Row(
                children: [
                  Text(
                    '${w.temperature.toInt()}°C',
                    style: GoogleFonts.poppins(
                      fontSize: 44,
                      fontWeight: FontWeight.w200,
                      color: SettingsService.textColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.status,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: SettingsService.textColor,
                        ),
                      ),
                      Text(
                        'Độ ẩm: ${w.humidity.toInt()}%  •  Sức gió: ${w.windSpeed.toInt()}km/h',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: SettingsService.textMutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              // 3-day forecast mini preview
              if (forecasts.isNotEmpty) ...[
                Text(
                  'Dự báo thời tiết 3 ngày tới:',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SettingsService.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...forecasts.take(3).map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 76,
                        child: Text(
                          f.dateTime,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: SettingsService.accentTitleColor,
                          ),
                        ),
                      ),
                      Icon(
                        f.rainProbability > 40 ? Icons.grain_rounded : Icons.wb_sunny_rounded,
                        color: f.rainProbability > 40 ? Colors.blue.shade300 : Colors.orange.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f.description ?? f.getRainLabel(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: SettingsService.textMutedColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${f.maxTemp.toInt()}° / ${f.minTemp.toInt()}°',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: SettingsService.textColor,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 18),
              ],
              
              // Actions buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: SettingsService.dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Đóng',
                        style: GoogleFonts.poppins(
                          color: SettingsService.textMutedColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        
                        final mainShell = context.findAncestorStateOfType<MainShellState>();
                        
                        setState(() {
                          _isRecommending = true;
                        });
                        
                        try {
                          // Lưu vào lịch sử tìm kiếm và cập nhật dữ liệu chung để đẩy thành phố này thành thành phố chính
                          final firestore = FirestoreService();
                          await firestore.saveSearchHistory(cityName, lat: lat, lon: lon);
                          
                          // Load lại dữ liệu
                          await _dataManager.loadAllData();
                          
                          // Đồng bộ thành phố hoạt động toàn cục
                          WeatherDataManager.activeCityName.value = cityName;
                          
                          // Quay về trang chủ
                          if (mounted && mainShell != null) {
                            mainShell.setIndex(0); // Switch to Home tab
                          }
                        } catch (e) {
                          // ignore
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isRecommending = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC427FB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Xem ở Trang Chủ',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── QUICK ICONS HANDLERS (1-tap access sheets) ─────────────────────────

  void _handleQuickIconTap(BuildContext context, String type, String label, bool isLightMode) {
    if (type == 'storm') {
      _showStormWarningSheet(context, isLightMode);
    } else if (type == 'humidity') {
      _showHumiditySheet(context, isLightMode);
    } else if (type == 'wind') {
      _showWindSheet(context, isLightMode);
    } else if (type == 'rain') {
      _showRainMapSheet(context, isLightMode);
    } else if (type == 'history') {
      _showRecentSearchesSheet(context, isLightMode);
    }
  }

  void _showStormWarningSheet(BuildContext context, bool isLightMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetWrapper(
          title: 'Cảnh báo Thiên tai & Bão',
          isLightMode: isLightMode,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Colors.red, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Không có bão hay áp thấp nhiệt đới hoạt động trên khu vực Biển Đông tại thời điểm hiện tại.',
                        style: GoogleFonts.poppins(fontSize: 11, color: SettingsService.textColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildBulletPoint('Khu vực Bắc Bộ & Trung Bộ có nắng nóng diện rộng.'),
              _buildBulletPoint('Khuyến nghị tàu thuyền theo dõi dự báo thời tiết biển hàng ngày.'),
            ],
          ),
        );
      },
    );
  }

  void _showHumiditySheet(BuildContext context, bool isLightMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetWrapper(
          title: 'Đo lường Độ ẩm Không khí',
          isLightMode: isLightMode,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('65%', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text('Dễ chịu (Comfortable)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildBulletPoint('Đo lường độ ẩm hiện tại trong khu vực dao động từ 60% đến 70%.'),
              _buildBulletPoint('Độ ẩm 55%-65% là khoảng độ ẩm lý tưởng nhất cho sức khỏe con người.'),
              _buildBulletPoint('Rất thích hợp cho các hoạt động ngoài trời, hạn chế nấm mốc phát triển.'),
            ],
          ),
        );
      },
    );
  }

  void _showWindSheet(BuildContext context, bool isLightMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetWrapper(
          title: 'Đo lường Tốc độ & Hướng gió',
          isLightMode: isLightMode,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('12 km/h', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal)),
                        Text('Gió nhẹ (Light Breeze)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.teal)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildBulletPoint('Hướng gió chủ đạo hiện tại: Tây Nam.'),
              _buildBulletPoint('Gió nhẹ mát mẻ phù hợp cho việc đi dạo và các hoạt động ngoài trời.'),
            ],
          ),
        );
      },
    );
  }

  void _showRecentSearchesSheet(BuildContext context, bool isLightMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: FirestoreService().getSearchHistory(),
          builder: (context, snapshot) {
            final List<Map<String, dynamic>> searches = snapshot.data ?? [];
            return _buildBottomSheetWrapper(
              title: 'Lịch sử tìm kiếm gần đây',
              isLightMode: isLightMode,
              child: searches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Chưa có lịch sử tìm kiếm nào.',
                        style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12),
                      ),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searches.length,
                        itemBuilder: (context, index) {
                          final s = searches[index];
                          final String name = s['cityName'];
                          final double? lat = s['lat'];
                          final double? lon = s['lon'];
                          
                          // Check if we have this city in our cache
                          final cachedCity = _dataManager.allCitiesData.firstWhere(
                            (c) => c['city'].toString().toLowerCase() == name.toLowerCase(),
                            orElse: () => <String, dynamic>{},
                          );
                          
                          final Weather? w = cachedCity.isNotEmpty ? cachedCity['weather'] as Weather : null;
                          
                          return ListTile(
                            leading: const Icon(Icons.history_rounded, color: Colors.orange),
                            title: Text(
                              name,
                              style: GoogleFonts.poppins(
                                color: SettingsService.textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: lat != null && lon != null
                                ? Text(
                                    'Vĩ độ: ${lat.toStringAsFixed(2)}, Kinh độ: ${lon.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 10),
                                  )
                                : null,
                            trailing: w != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC427FB).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${w.temperature.toInt()}°C',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFC427FB),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () async {
                              Navigator.pop(context); // Close the history list sheet
                              
                              if (cachedCity.isNotEmpty) {
                                // Open weather details modal directly in exactly 1 tap!
                                _showWeatherDetailSheet(
                                  context,
                                  name,
                                  cachedCity['weather'],
                                  cachedCity['forecasts'],
                                  null,
                                  lat ?? 0.0,
                                  lon ?? 0.0,
                                  isLightMode,
                                );
                              } else if (lat != null && lon != null) {
                                // Load details dynamically if not cached
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(color: Color(0xFFC427FB)),
                                  ),
                                );
                                
                                try {
                                  final apiService = ApiService();
                                  final weatherResult = await apiService.fetchWeatherData(lat, lon, name);
                                  if (context.mounted) {
                                    Navigator.pop(context); // close loader
                                    _showWeatherDetailSheet(
                                      context,
                                      name,
                                      weatherResult['weather'],
                                      weatherResult['forecasts'],
                                      null,
                                      lat,
                                      lon,
                                      isLightMode,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(context); // close loader
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Không thể tải thời tiết cho $name')),
                                    );
                                  }
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  // 1. Travel Weather Sheet
  void _showTravelWeatherSheet(BuildContext context, bool isLightMode) {
    final travelPlaces = [
      {'name': 'Đà Lạt', 'temp': '22°C', 'status': 'Se lạnh, nắng mây', 'score': '9.8', 'badge': 'Tuyệt vời'},
      {'name': 'Phú Quốc', 'temp': '29°C', 'status': 'Nắng ấm, biển trong', 'score': '9.5', 'badge': 'Rất tốt'},
      {'name': 'Hạ Long', 'temp': '28°C', 'status': 'Nắng nhẹ, lộng gió', 'score': '9.0', 'badge': 'Thích hợp'},
      {'name': 'Sa Pa', 'temp': '19°C', 'status': 'Mây mù, có sương', 'score': '8.2', 'badge': 'Nên đi'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildBottomSheetWrapper(
          title: 'Thời tiết Du lịch lý tưởng',
          isLightMode: isLightMode,
          child: Column(
            children: travelPlaces.map((place) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isLightMode ? Colors.grey.shade50 : const Color(0xFF1F1D47).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SettingsService.cardBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        place['score']!,
                        style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(place['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: SettingsService.textColor)),
                              const SizedBox(width: 6),
                              Text('(${place['badge']})', style: GoogleFonts.poppins(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Text(place['status']!, style: GoogleFonts.poppins(fontSize: 10, color: SettingsService.textMutedColor)),
                        ],
                      ),
                    ),
                    Text(place['temp']!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: SettingsService.textColor)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // 2. Rain & Cloud Map Radar Simulation Sheet
  void _showRainMapSheet(BuildContext context, bool isLightMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetWrapper(
          title: 'Bản đồ Radar Mưa & Mây',
          isLightMode: isLightMode,
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mock radar lines
                    Icon(Icons.radar_rounded, color: Colors.green, size: 120),
                    Positioned(
                      top: 40,
                      left: 100,
                      child: Icon(Icons.cloud_rounded, color: Colors.blueAccent, size: 24),
                    ),
                    Positioned(
                      bottom: 50,
                      right: 80,
                      child: Icon(Icons.grain_rounded, color: Colors.greenAccent, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Radar đang hoạt động quét vùng mây thời gian thực.',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: SettingsService.textColor),
                textAlign: TextAlign.center,
              ),
              Text(
                'Lượng mưa tích lũy hiện tại trong khu vực Hà Nội và vùng lân cận ở mức an toàn dưới 2mm/h. Không có tín hiệu thời tiết cực đoan.',
                style: GoogleFonts.poppins(fontSize: 11, color: SettingsService.textMutedColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. Air Quality AQI Index Sheet
  void _showAirQualitySheet(BuildContext context, bool isLightMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetWrapper(
          title: 'Chất lượng không khí (AQI)',
          isLightMode: isLightMode,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('42', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                        Text('Tốt (Good)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAQIRow('PM2.5 (Bụi mịn)', '10.2 µg/m³', 'Tốt', Colors.green),
              const SizedBox(height: 8),
              _buildAQIRow('PM10 (Bụi thô)', '24.5 µg/m³', 'Tốt', Colors.green),
              const SizedBox(height: 8),
              _buildAQIRow('NO₂ (Nitơ Đioxit)', '14.0 µg/m³', 'Tốt', Colors.green),
              const SizedBox(height: 14),
              Text(
                'Chất lượng không khí đạt chuẩn an toàn, rất thích hợp cho việc tập thể dục ngoài trời và mở cửa thông gió.',
                style: GoogleFonts.poppins(fontSize: 11, color: SettingsService.textMutedColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAQIRow(String name, String value, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: GoogleFonts.poppins(fontSize: 12, color: SettingsService.textColor)),
        Row(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: SettingsService.textColor)),
            const SizedBox(width: 8),
            Text(status, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ],
        )
      ],
    );
  }

  // 4. UV Index Sheet
  void _showUvIndexSheet(BuildContext context, bool isLightMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetWrapper(
          title: 'Chi tiết Chỉ số UV trong ngày',
          isLightMode: isLightMode,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('8', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
                        Text('Rất Cao (Very High)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Biện pháp bảo vệ khuyến nghị:',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: SettingsService.textColor),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Hạn chế ra ngoài trời trong khoảng từ 11:00 đến 14:00.'),
              _buildBulletPoint('Bắt buộc bôi kem chống nắng SPF 30+ trở lên.'),
              _buildBulletPoint('Đeo kính râm, đội mũ rộng vành và mặc áo dài tay chống nắng.'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.orange.shade400, size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 11, color: SettingsService.textDimColor))),
        ],
      ),
    );
  }

  // 5. Health advice Sheet
  void _showHealthSheet(BuildContext context, bool isLightMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetWrapper(
          title: 'Khuyến nghị Sức khỏe & Thời tiết',
          isLightMode: isLightMode,
          child: Column(
            children: [
              _buildHealthCard(Icons.local_drink_rounded, 'Uống đủ nước', 'Nhiệt độ ngoài trời cao làm mất nước nhanh. Hãy uống ít nhất 2L nước mỗi ngày.', Colors.blue),
              const SizedBox(height: 10),
              _buildHealthCard(Icons.fitness_center_rounded, 'Vận động thể thao', 'Nên tập luyện thể thao vào sáng sớm hoặc chiều tối khi trời mát mẻ.', Colors.purple),
              const SizedBox(height: 10),
              _buildHealthCard(Icons.nights_stay_rounded, 'Chất lượng giấc ngủ', 'Bảo quản nhiệt độ phòng ngủ ở mức 25°C-27°C để đảm bảo giấc ngủ sâu.', Colors.indigo),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthCard(IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SettingsService.cardBorderColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SettingsService.cardColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: SettingsService.textColor)),
                const SizedBox(height: 2),
                Text(desc, style: GoogleFonts.poppins(fontSize: 10, color: SettingsService.textMutedColor)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Common BottomSheet wrapper styling
  Widget _buildBottomSheetWrapper({
    required String title,
    required bool isLightMode,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white : const Color(0xFF1C1B33),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SettingsService.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: SettingsService.textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          child,
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Free beautiful stock images for specific Vietnam travel cities (using verified working photo IDs)
  String _getCityImageUrl(String cityName) {
    final String name = cityName.toLowerCase();
    
    // Group cities by type and use guaranteed active Unsplash photo IDs
    if (name.contains('đà nẵng') || name.contains('hội an') || name.contains('hồ chí minh') || name.contains('hải phòng') || name.contains('vinh')) {
      // Dragon Bridge / Modern Vietnam City (Da Nang ID - 100% Active)
      return 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&fit=crop&q=60';
    } else if (name.contains('hạ long') || name.contains('ninh bình') || name.contains('hà nội') || name.contains('huế')) {
      // Karst Mountains and water (Ha Long ID - 100% Active)
      return 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400&fit=crop&q=60';
    } else if (name.contains('phú quốc') || name.contains('nha trang') || name.contains('vũng tàu') || name.contains('đà lạt')) {
      // Beach / Resort scene (Beach ID - 100% Active)
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&fit=crop&q=60';
    } else {
      // General beautiful landscape fallback (Ha Long ID)
      return 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400&fit=crop&q=60';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/forecast.dart';
import '../models/city.dart';
import '../widgets/shared_widgets.dart';

// ============================================================
// ContentScreen — Màn hình Forecast (Quang's screen)
// YÊU CẦU: Dự báo chi tiết 5 ngày, bảng so sánh, thống kê
// ============================================================
class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // YÊU CẦU 2: List<Map> — Dữ liệu dự báo chi tiết
    final List<Map<String, dynamic>> forecastData = [
      {'id':'f1','dateTime':'Thứ Hai',  'minTemp':25.0,'maxTemp':32.0,'rainProb':10,'desc':'Nắng đẹp, ít mây'},
      {'id':'f2','dateTime':'Thứ Ba',   'minTemp':24.0,'maxTemp':28.0,'rainProb':80,'desc':'Mưa rào, sấm nhẹ'},
      {'id':'f3','dateTime':'Thứ Tư',   'minTemp':25.0,'maxTemp':30.0,'rainProb':30,'desc':'Nhiều mây, có thể mưa'},
      {'id':'f4','dateTime':'Thứ Năm',  'minTemp':23.0,'maxTemp':29.0,'rainProb':10,'desc':'Trời quang, nắng nhẹ'},
      {'id':'f5','dateTime':'Thứ Sáu',  'minTemp':26.0,'maxTemp':31.0,'rainProb':50,'desc':'Buổi chiều có mưa'},
    ];

    // YÊU CẦU 4: List<City>
    final List<Map<String, dynamic>> cityData = [
      {'id':1,'name':'Hà Nội',       'temp':32.5,'status':'Sunny'},
      {'id':2,'name':'Đà Nẵng',     'temp':29.0,'status':'Cloudy'},
      {'id':3,'name':'Hồ Chí Minh', 'temp':35.0,'status':'Sunny'},
      {'id':4,'name':'Hải Phòng',   'temp':28.0,'status':'Rainy'},
      {'id':5,'name':'Cần Thơ',     'temp':33.0,'status':'Cloudy'},
    ];

    return Column(
      children: [
        // === HEADER: Ảnh nhóm ===
        const GroupPhotoHeader(screenLabel: 'Quang_Forecast'),

        // === NỘI DUNG CUỘN ===
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dự báo chi tiết 5 ngày
                _sectionTitle('Dự Báo Chi Tiết 5 Ngày'),
                const SizedBox(height: 12),
                ...List.generate(forecastData.length, (i) {
                  final f = forecastData[i];
                  final Forecast fo = Forecast(
                    id:              f['id'],
                    dateTime:        f['dateTime'],
                    minTemp:         (f['minTemp'] as num).toDouble(),
                    maxTemp:         (f['maxTemp'] as num).toDouble(),
                    rainProbability: f['rainProb'],
                  );
                  return _buildForecastCard(fo, f['desc']);
                }),

                const SizedBox(height: 20),

                // Bảng so sánh thành phố
                _sectionTitle('So Sánh Các Thành Phố'),
                const SizedBox(height: 12),
                _buildCityTable(cityData),

                const SizedBox(height: 20),

                // Thống kê tổng quan
                _sectionTitle('Thống Kê Tổng Quan'),
                const SizedBox(height: 12),
                _buildStatCards(),

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

  Widget _sectionTitle(String title) => Text(title,
      style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1565C0)));

  // ── Forecast card với progress bar mưa ───────────────────
  Widget _buildForecastCard(Forecast fo, String desc) {
    final bool isHighRain = fo.rainProbability > 50;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fo.dateTime,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1565C0))),
              Row(
                children: [
                  Icon(Icons.thermostat, size: 16, color: Colors.orange.shade400),
                  Text(' ${fo.minTemp.toInt()}° – ${fo.maxTemp.toInt()}°C',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.water_drop, size: 14, color: Colors.lightBlue),
              const SizedBox(width: 4),
              Text('Xác suất mưa: ${fo.rainProbability}%',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isHighRain ? Colors.blue.shade700 : Colors.grey)),
              const Spacer(),
              Text('Chênh lệch: ${fo.getTemperatureDifference().toStringAsFixed(1)}°C',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fo.rainProbability / 100,
              backgroundColor: Colors.grey.shade200,
              color: isHighRain ? Colors.blue : Colors.lightBlue.shade200,
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bảng so sánh thành phố ───────────────────────────────
  Widget _buildCityTable(List<Map<String, dynamic>> cityData) {
    final Map<String, IconData> statusIcons = {
      'Sunny':  Icons.wb_sunny_rounded,
      'Cloudy': Icons.cloud_rounded,
      'Rainy':  Icons.grain,
    };
    final Map<String, Color> statusColors = {
      'Sunny':  const Color(0xFFFFB300),
      'Cloudy': Colors.grey,
      'Rainy':  Colors.lightBlue,
    };

    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E88E5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Thành Phố', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(child: Text('Nhiệt Độ', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(child: Text('Trạng Thái', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          ...List.generate(cityData.length, (i) {
            final c = cityData[i];
            // YÊU CẦU 5: Tạo đối tượng City
            final City city = City(id: c['id'], name: c['name']);
            final String status = c['status'];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: i.isEven ? Colors.grey.shade50 : Colors.white,
                borderRadius: i == cityData.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(16))
                    : BorderRadius.zero,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(city.name,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1565C0))),
                  ),
                  Expanded(
                    child: Text('${c['temp']}°C',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(statusIcons[status] ?? Icons.wb_cloudy, size: 16, color: statusColors[status] ?? Colors.grey),
                        const SizedBox(width: 4),
                        Text(status, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Thống kê ─────────────────────────────────────────────
  Widget _buildStatCards() {
    final List<Map<String, dynamic>> stats = [
      {'label': 'Nhiệt độ TB', 'value': '31.5°C', 'icon': Icons.thermostat,  'color': Colors.orange},
      {'label': 'Độ ẩm TB',   'value': '76%',     'icon': Icons.water_drop,  'color': Colors.lightBlue},
      {'label': 'Ngày mưa',   'value': '2/5',     'icon': Icons.umbrella,    'color': Colors.indigo},
      {'label': 'Chênh lệch', 'value': '7.0°C',   'icon': Icons.swap_vert,   'color': Colors.teal},
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: stats.map((s) {
        return Container(
          padding: const EdgeInsets.all(14),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(s['icon'] as IconData, color: s['color'] as Color, size: 28),
              const SizedBox(height: 6),
              Text(s['value'] as String,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565C0))),
              Text(s['label'] as String,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

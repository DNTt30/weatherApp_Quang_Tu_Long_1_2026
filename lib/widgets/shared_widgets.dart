import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// Thông tin nhóm — dùng chung toàn bộ app
// ============================================================
class AppConstants {
  static const String university = 'Phenikaa University';
  static const String teamName = 'weatherApp_Quang_Tu_Long_1_2026';
  static const String appVersion = '1.0.0';

  static const List<Map<String, String>> members = [
    {'name': 'Dương Ngọc Tú',  'id': '22010052', 'screen': 'More'},
    {'name': 'Ngô Thành Long',  'id': '23010032', 'screen': 'Home'},
    {'name': 'Lê Minh Quang',  'id': '21012086', 'screen': 'Forecast'},
  ];
}

// ============================================================
// GroupPhotoHeader — Banner ảnh nhóm ở đầu mỗi màn hình
// ============================================================
class GroupPhotoHeader extends StatelessWidget {
  /// Nhãn hiển thị trong banner (ví dụ: 'Long_home', 'Quang_Forecast', 'Tú_More')
  final String screenLabel;

  const GroupPhotoHeader({super.key, required this.screenLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E), Color(0xFF757575)],
        ),
      ),
      child: Stack(
        children: [
          // Nền mờ dạng lưới ảnh
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: GridView.count(
                crossAxisCount: 8,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  64,
                  (_) => Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Icon camera trung tâm
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: const Icon(Icons.photo_camera_rounded,
                      size: 32, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ảnh nhóm',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      const Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1))
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Label màn hình (góc trái dưới)
          Positioned(
            bottom: 10,
            left: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                screenLabel,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MemberInfoFooter — Footer thông tin thành viên cuối mỗi màn hình
// ============================================================
class MemberInfoFooter extends StatelessWidget {
  const MemberInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // University
          Row(
            children: [
              const Icon(Icons.school_rounded,
                  size: 14, color: Color(0xFF1565C0)),
              const SizedBox(width: 6),
              Text(
                AppConstants.university,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1565C0)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Members
          ...AppConstants.members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Text(
                      '${m['name']} - ${m['id']}',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/settings_service.dart';
import '../service/firestore_service.dart';

// ============================================================
// AboutScreen — Tú phụ trách (Cài đặt, Thông tin, Đăng xuất)
// Purple Glassmorphism Theme 
// ============================================================
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.isLightMode,
      builder: (context, isLight, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [SettingsService.bgGradientTop, SettingsService.bgGradientBottom],
            ),
          ),
          child: Column(
            children: [
          // ── Content ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  _buildAppInfoCard(),
                  const SizedBox(height: 24),
                  
                  _sectionLabel('Thành Viên Nhóm 1'),
                  const SizedBox(height: 12),
                  _buildTeamList(),
                  const SizedBox(height: 24),

                  _sectionLabel('Công Nghệ Sử Dụng'),
                  const SizedBox(height: 12),
                  _buildTechStack(),
                  const SizedBox(height: 30),

                  _sectionLabel('Thành Phố Yêu Thích'),
                  const SizedBox(height: 12),
                  _buildFavoritesList(),
                  const SizedBox(height: 24),

                  _sectionLabel('Lịch Sử Hoạt Động ("Câu chuyện User")'),
                  const SizedBox(height: 12),
                  _buildSearchHistory(),
                  const SizedBox(height: 24),

                  _sectionLabel('Nguồn Dữ Liệu (Data Source)'),
                  const SizedBox(height: 12),
                  _buildDataSource(),
                  const SizedBox(height: 30),

                  _buildSettingsAndLogout(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Footer ──────────────────────────────────────
          _buildFooter(),
        ],
      ),
    );
      },
    );
  }

  // ── Profile Card (Mới) ────────────────────────────────────
  Widget _buildProfileCard() {
    final String userEmail = FirebaseAuth.instance.currentUser?.email ?? "Khách";
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: SettingsService.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SettingsService.cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFC427FB).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: SettingsService.accentTitleColor, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hồ Sơ Cá Nhân',
                    style: GoogleFonts.poppins(
                        color: SettingsService.textMutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(userEmail,
                    style: GoogleFonts.poppins(
                        color: SettingsService.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App Info Card ─────────────────────────────────────────
  Widget _buildAppInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SettingsService.primaryGradientStart, SettingsService.primaryGradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SettingsService.cardBorderColor),
        boxShadow: [
          BoxShadow(
              color: SettingsService.primaryGradientStart.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SettingsService.cardBorderColor,
            ),
            child: const Icon(Icons.cloud_done_rounded,
                size: 48, color: Color(0xFFFFD700)),
          ),
          const SizedBox(height: 16),
          Text('Weather App',
              style: GoogleFonts.poppins(
                  color: SettingsService.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Phiên bản 1.0.0',
              style: GoogleFonts.poppins(
                  color: SettingsService.accentTitleColor, fontSize: 13)),
          const SizedBox(height: 16),
          Text(
            'Ứng dụng theo dõi thời tiết chính xác, nhanh chóng được xây dựng bởi Nhóm 1 - Đại học Phenikaa.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: SettingsService.textDimColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Team List ─────────────────────────────────────────────
  Widget _buildTeamList() {
    final teamMembers = [
      {
        'name': 'Dương Ngọc Tú',
        'id': '22010052',
        'role': 'Auth, Settings, Firebase',
        'icon': Icons.admin_panel_settings_rounded,
        'color': const Color(0xFFC427FB)
      },
      {
        'name': 'Ngô Thành Long',
        'id': '23010032',
        'role': 'Home, City UI',
        'icon': Icons.home_rounded,
        'color': const Color(0xFFFFD700)
      },
      {
        'name': 'Lê Minh Quang',
        'id': '21012086',
        'role': 'Forecast, Weather Detail',
        'icon': Icons.bar_chart_rounded,
        'color': const Color(0xFF83B4FF)
      },
    ];

    return Column(
      children: teamMembers.map((member) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SettingsService.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SettingsService.cardBorderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (member['color'] as Color).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(member['icon'] as IconData,
                    color: member['color'] as Color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member['name'] as String,
                        style: GoogleFonts.poppins(
                            color: SettingsService.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(member['role'] as String,
                        style: GoogleFonts.poppins(
                            color: SettingsService.textMutedColor, fontSize: 11)),
                  ],
                ),
              ),
              Text(member['id'] as String,
                  style: GoogleFonts.poppins(
                      color: SettingsService.accentTitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Tech Stack ────────────────────────────────────────────
  Widget _buildTechStack() {
    final techList = [
      {'label': 'Flutter', 'icon': Icons.flutter_dash_rounded, 'color': Colors.blue},
      {'label': 'Firebase', 'icon': Icons.local_fire_department_rounded, 'color': Colors.orange},
      {'label': 'Dart', 'icon': Icons.code_rounded, 'color': Colors.teal},
      {'label': 'Figma', 'icon': Icons.design_services_rounded, 'color': Colors.pink},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: techList.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: SettingsService.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SettingsService.dividerColor),
          ),
          child: Row(
            children: [
              Icon(t['icon'] as IconData,
                  color: (t['color'] as Color).withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 10),
              Text(t['label'] as String,
                  style: GoogleFonts.poppins(
                      color: SettingsService.textDimColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Favorite Cities (Giao diện sáng) ──────────────────────
  Widget _buildFavoritesList() {
    return FutureBuilder<List<String>>(
      future: FirestoreService().getFavoriteCities(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator());
        final favorites = snapshot.data!;
        if (favorites.isEmpty) {
          return Text('Chưa có thành phố yêu thích', style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12));
        }
        return Column(
          children: favorites.map((city) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              // Giao diện sáng hơn cho dễ nhìn
              color: SettingsService.cardBorderColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SettingsService.cardBorderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 22),
                const SizedBox(width: 14),
                Text(city, style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          )).toList(),
        );
      },
    );
  }

  // ── Lịch sử Hoạt động (Search History) ────────────────────
  Widget _buildSearchHistory() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService().getSearchHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator());
        final history = snapshot.data!;
        if (history.isEmpty) {
          return Text('Hôm nay chưa có hoạt động nào.', style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12));
        }
        return Column(
          children: history.map((record) {
            final cityName = record['cityName'] as String;
            final timestamp = record['timestamp'];
            // Xử lý thời gian (firestore trả về Timestamp)
            String timeStr = "Vừa xong";
            if (timestamp != null) {
              final DateTime dt = timestamp.toDate();
              timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}";
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: SettingsService.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SettingsService.dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đã xem thời tiết $cityName', style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(timeStr, style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── Data Source (Nguồn dữ liệu) ───────────────────────────
  Widget _buildDataSource() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SettingsService.cardBorderColor, // Giao diện sáng
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettingsService.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_sync_rounded, color: Color(0xFF83B4FF), size: 22),
              const SizedBox(width: 10),
              Text('API Thời Tiết', style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text('• Open-Meteo API', style: GoogleFonts.poppins(color: SettingsService.textDimColor, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.storage_rounded, color: Colors.orangeAccent, size: 22),
              const SizedBox(width: 10),
              Text('Cơ Sở Dữ Liệu (Database)', style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text('• Firebase Firestore', style: GoogleFonts.poppins(color: SettingsService.textDimColor, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('  - Collections: users, cities, weather, forecasts', style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Settings & Logout ─────────────────────────────────────
  Widget _buildSettingsAndLogout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Tùy Chỉnh (Settings)'),
        const SizedBox(height: 12),
        // Nhóm Tùy chỉnh (Đổi ngôn ngữ, Giao diện, Nhiệt độ, Cảnh báo)
        Container(
          decoration: BoxDecoration(
            color: SettingsService.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SettingsService.cardBorderColor),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tính năng Đổi ngôn ngữ đang phát triển (v2.0)!', style: GoogleFonts.poppins()),
                      backgroundColor: const Color(0xFFC427FB),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: _buildSettingTile(Icons.language_rounded, 'Đổi ngôn ngữ', 'Tiếng Việt', showTopRadius: true),
              ),
              Divider(height: 1, color: SettingsService.dividerColor),
              ValueListenableBuilder<bool>(
                valueListenable: SettingsService.isLightMode,
                builder: (context, isLight, _) {
                  return InkWell(
                    onTap: () {
                      SettingsService.toggleLightMode();
                    },
                    child: _buildSettingTile(Icons.dark_mode_rounded, 'Giao diện', isLight ? 'Sáng (Light)' : 'Tối (Dark)'),
                  );
                },
              ),
              Divider(height: 1, color: SettingsService.dividerColor),
              // Nút Đổi đơn vị nhiệt độ (C <-> F)
              ValueListenableBuilder<bool>(
                valueListenable: SettingsService.isCelsius,
                builder: (context, isCelsius, _) {
                  return InkWell(
                    onTap: () {
                      SettingsService.toggleTemperatureUnit();
                    },
                    child: _buildSettingTile(
                        Icons.thermostat_rounded,
                        'Đơn vị nhiệt độ',
                        isCelsius ? '°C' : '°F'),
                  );
                },
              ),
              Divider(height: 1, color: SettingsService.dividerColor),
              // Nút Bật/tắt cảnh báo
              ValueListenableBuilder<bool>(
                valueListenable: SettingsService.isNotificationEnabled,
                builder: (context, isEnabled, _) {
                  return InkWell(
                    onTap: () {
                      SettingsService.toggleNotification();
                    },
                    child: _buildSettingTile(
                        isEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                        'Cảnh báo thời tiết xấu',
                        isEnabled ? 'Bật' : 'Tắt', showBottomRadius: true),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Nhóm Quản lý Tài khoản (Xóa, Đăng Xuất)
        _sectionLabel('Quản Lý Tài Khoản'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: SettingsService.cardBorderColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SettingsService.cardBorderColor),
          ),
          child: Column(
            children: [
              // Nút Xóa Tài Khoản
              InkWell(
                onTap: () => _showDeleteAccountDialog(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_remove_rounded,
                            size: 18, color: Colors.orangeAccent),
                      ),
                      const SizedBox(width: 14),
                      Text('Xóa Tài Khoản',
                          style: GoogleFonts.poppins(
                              color: Colors.orangeAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: SettingsService.dividerColor),

              // Nút Đăng Xuất
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  // Tự động chuyển về trang đăng nhập nhờ StreamBuilder trong main.dart
                },
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            size: 18, color: Colors.redAccent),
                      ),
                      const SizedBox(width: 14),
                      Text('Đăng Xuất',
                          style: GoogleFonts.poppins(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String trailing, {bool showTopRadius = false, bool showBottomRadius = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(showTopRadius ? 20 : 0),
          bottom: Radius.circular(showBottomRadius ? 20 : 0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SettingsService.primaryGradientStart.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: SettingsService.accentTitleColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: GoogleFonts.poppins(
                    color: SettingsService.textColor, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text(trailing,
              style: GoogleFonts.poppins(
                  color: SettingsService.textMutedColor, fontSize: 12)),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded,
              color: SettingsService.textMutedColor, size: 18),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: SettingsService.footerBgColor,
        border: Border(top: BorderSide(color: SettingsService.dividerColor)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Icon(Icons.school_rounded, size: 12, color: SettingsService.accentTitleColor),
          const SizedBox(width: 6),
          Text('Phenikaa University',
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: SettingsService.accentTitleColor,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 3),
        Text('Dương Ngọc Tú • Ngô Thành Long • Lê Minh Quang',
            style: GoogleFonts.poppins(fontSize: 9, color: SettingsService.textMutedColor)),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.poppins(
          color: SettingsService.accentTitleColor,
          fontSize: 14,
          fontWeight: FontWeight.w700));

  // ── Thêm Logic Xóa Tài Khoản ──────────────────────────────
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: SettingsService.bgGradientBottom,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Xóa Tài Khoản',
            style: GoogleFonts.poppins(color: SettingsService.textColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản này không? Mọi dữ liệu (Thành phố yêu thích) sẽ bị xóa và không thể khôi phục.',
            style: GoogleFonts.poppins(color: SettingsService.textDimColor, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Hủy', style: GoogleFonts.poppins(color: SettingsService.textMutedColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await FirebaseAuth.instance.currentUser?.delete();
                  // Sẽ tự văng ra màn hình đăng nhập nhờ AuthStateChanges stream
                } on FirebaseAuthException catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi xóa tài khoản: ${e.message}', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: Text('Xóa Vĩnh Viễn', style: GoogleFonts.poppins(color: SettingsService.textColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

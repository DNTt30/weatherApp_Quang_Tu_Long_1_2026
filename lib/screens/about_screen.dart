import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============================================================
// AboutScreen — Tú phụ trách (Cài đặt, Thông tin, Đăng xuất)
// Purple Glassmorphism Theme 
// ============================================================
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────
          _buildHeader(),

          // ── Content ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3658B1), Color(0xFFC159EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF3658B1).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              right: -20,
              top: -20,
              child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05)))),
          Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.settings_rounded,
                        color: Colors.white54, size: 18),
                    const SizedBox(width: 8),
                    Text('Mở rộng (More)',
                        style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Tú_More',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5936B4), Color(0xFF362A84)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF48319D).withValues(alpha: 0.4),
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
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.cloud_done_rounded,
                size: 48, color: Color(0xFFFFD700)),
          ),
          const SizedBox(height: 16),
          Text('Weather App',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Phiên bản 1.0.0',
              style: GoogleFonts.poppins(
                  color: const Color(0xFFE0D9FF), fontSize: 13)),
          const SizedBox(height: 16),
          Text(
            'Ứng dụng theo dõi thời tiết chính xác, nhanh chóng được xây dựng bởi Nhóm 1 - Đại học Phenikaa.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
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
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(member['role'] as String,
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              Text(member['id'] as String,
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFE0D9FF),
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
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(t['icon'] as IconData,
                  color: (t['color'] as Color).withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 10),
              Text(t['label'] as String,
                  style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Settings & Logout ─────────────────────────────────────
  Widget _buildSettingsAndLogout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Cài Đặt'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildSettingTile(Icons.language_rounded, 'Đổi ngôn ngữ', 'Tiếng Việt'),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              _buildSettingTile(Icons.dark_mode_rounded, 'Giao diện', 'Tối (Dark)'),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              _buildSettingTile(Icons.thermostat_rounded, 'Đơn vị nhiệt độ', '°C'),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              
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

  Widget _buildSettingTile(IconData icon, String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF48319D).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFE0D9FF)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 13)),
          ),
          Text(trailing,
              style: GoogleFonts.poppins(
                  color: Colors.white54, fontSize: 12)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.white38, size: 18),
        ],
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
          Text('Phenikaa University',
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFFE0D9FF),
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 3),
        Text('Dương Ngọc Tú • Ngô Thành Long • Lê Minh Quang',
            style: GoogleFonts.poppins(fontSize: 9, color: Colors.white38)),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.poppins(
          color: const Color(0xFFE0D9FF),
          fontSize: 14,
          fontWeight: FontWeight.w700));
}

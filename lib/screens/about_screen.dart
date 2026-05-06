import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_widgets.dart';

// ============================================================
// AboutScreen — Màn hình About / Profile (Tú's screen)
// Theo mockup Figma: fbjspFedt90T1p34Ty2xPI node-id=4368-321106
// Layout: Dark blue header → Avatar overlap → Tên/MSSV → Settings rows
// ============================================================
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // ── State ─────────────────────────────────────────────────
  bool _notificationsOn = true;
  bool _darkMode        = false;
  bool _locationOn      = true;
  String _unit          = '°C';

  // YÊU CẦU 2: List<Map<String, dynamic>> — menu settings rows
  final List<Map<String, dynamic>> _settingsItems = [
    {
      'icon'    : Icons.thermostat_rounded,
      'title'   : 'Đơn Vị Nhiệt Độ',
      'subtitle': 'Celsius / Fahrenheit',
      'color'   : const Color(0xFF1E88E5),
      'type'    : 'unit',
    },
    {
      'icon'    : Icons.notifications_rounded,
      'title'   : 'Thông Báo',
      'subtitle': 'Cảnh báo thời tiết xấu',
      'color'   : const Color(0xFFE53935),
      'type'    : 'switch_notif',
    },
    {
      'icon'    : Icons.location_on_rounded,
      'title'   : 'Vị Trí',
      'subtitle': 'Dùng GPS hiện tại',
      'color'   : const Color(0xFF43A047),
      'type'    : 'switch_loc',
    },
    {
      'icon'    : Icons.dark_mode_rounded,
      'title'   : 'Giao Diện',
      'subtitle': 'Light / Dark mode',
      'color'   : const Color(0xFF7B1FA2),
      'type'    : 'switch_dark',
    },
    {
      'icon'    : Icons.language_rounded,
      'title'   : 'Ngôn Ngữ',
      'subtitle': 'Tiếng Việt',
      'color'   : const Color(0xFF00897B),
      'type'    : 'nav',
    },
    {
      'icon'    : Icons.help_outline_rounded,
      'title'   : 'Trợ Giúp',
      'subtitle': 'Hướng dẫn sử dụng',
      'color'   : const Color(0xFFFF8F00),
      'type'    : 'nav',
    },
    {
      'icon'    : Icons.info_outline_rounded,
      'title'   : 'Về Ứng Dụng',
      'subtitle': 'Weather App v${AppConstants.appVersion}',
      'color'   : const Color(0xFF546E7A),
      'type'    : 'nav',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── HEADER ảnh nhóm ─────────────────────────────────
        const GroupPhotoHeader(screenLabel: 'Tú_About'),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ──────────────────────────────────────────────
                // PROFILE SECTION: Dark blue header + Avatar overlap
                // Theo Figma: dark header, avatar circle đè lên header
                // ──────────────────────────────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Dark blue header block
                    Container(
                      width: double.infinity,
                      height: 130,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D2137),
                            Color(0xFF1565C0),
                          ],
                        ),
                      ),
                    ),

                    // Avatar đè lên phần dưới header (overlap)
                    Positioned(
                      bottom: -50,
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E88E5),
                              border: Border.all(
                                  color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'T',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Khoảng trống cho avatar
                const SizedBox(height: 62),

                // Tên + MSSV + Trường
                Text(
                  'Dương Ngọc Tú',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MSSV: 22010052',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Phenikaa University  •  About Screen',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF1565C0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Stats row (3 ô)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildStatBox('About', 'Screen', const Color(0xFF1E88E5)),
                      const SizedBox(width: 12),
                      _buildStatBox('SE06.2', 'Lớp', const Color(0xFF43A047)),
                      const SizedBox(width: 12),
                      _buildStatBox('2022', 'Khoá', const Color(0xFFE53935)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ──────────────────────────────────────────────
                // SETTINGS LIST — các mục theo Figma (icon + title + trailing)
                // ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('CÀI ĐẶT'),
                      const SizedBox(height: 8),
                      _buildSettingsList(),

                      const SizedBox(height: 20),
                      _buildSectionLabel('NHÓM'),
                      const SizedBox(height: 8),
                      _buildTeamCard(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── FOOTER ──────────────────────────────────────────
        const MemberInfoFooter(),
      ],
    );
  }

  // ── Stat box nhỏ ─────────────────────────────────────────
  Widget _buildStatBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── Settings list card ───────────────────────────────────
  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: _settingsItems.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == _settingsItems.length - 1;
          return _buildSettingRow(item, isLast);
        }).toList(),
      ),
    );
  }

  // ── Một dòng setting ─────────────────────────────────────
  Widget _buildSettingRow(Map<String, dynamic> item, bool isLast) {
    final Color color = item['color'] as Color;
    final String type = item['type'] as String;

    Widget trailing;
    if (type == 'switch_notif') {
      trailing = Switch(
        value: _notificationsOn,
        onChanged: (v) => setState(() => _notificationsOn = v),
        activeColor: const Color(0xFF1E88E5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else if (type == 'switch_loc') {
      trailing = Switch(
        value: _locationOn,
        onChanged: (v) => setState(() => _locationOn = v),
        activeColor: const Color(0xFF1E88E5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else if (type == 'switch_dark') {
      trailing = Switch(
        value: _darkMode,
        onChanged: (v) => setState(() => _darkMode = v),
        activeColor: const Color(0xFF1E88E5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else if (type == 'unit') {
      trailing = GestureDetector(
        onTap: () => setState(() => _unit = _unit == '°C' ? '°F' : '°C'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _unit,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    } else {
      trailing = Icon(Icons.chevron_right_rounded,
          color: Colors.grey.shade300, size: 20);
    }

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon tròn màu
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2340),
                      ),
                    ),
                    Text(
                      item['subtitle'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }

  // ── Team card ────────────────────────────────────────────
  Widget _buildTeamCard() {
    final List<Color> avatarColors = [
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFFE53935),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: AppConstants.members.asMap().entries.map((entry) {
          final m = entry.value;
          final color = avatarColors[entry.key % avatarColors.length];
          final isMe = m['id'] == '22010052';
          final isLast = entry.key == AppConstants.members.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: color,
                          child: Text(
                            m['name']![0],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isMe)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                m['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A2340),
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Tôi',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${m['id']}  •  ${m['screen']} Screen',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        m['screen']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 50,
                  endIndent: 16,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

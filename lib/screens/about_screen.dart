import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_widgets.dart';

// ============================================================
// AboutScreen — Màn hình More / Settings (Tú's screen)
// Theo mockup: Settings | Notifications | Locations | Theme | About
// ============================================================
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // State cho các toggle / lựa chọn
  String _temperatureUnit = '°C';
  String _windUnit        = 'km/h';
  bool   _enableAlerts    = true;
  bool   _lightMode       = true;

  final List<String> _locations = ['Ha Noi', 'Da Nang'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // === HEADER: Ảnh nhóm ===
        const GroupPhotoHeader(screenLabel: 'Tú_More'),

        // === NỘI DUNG CUỘN ===
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // ── ⚙️ Settings ────────────────────────────────
              _buildSectionHeader('⚙️  Settings'),
              _buildCard([
                _buildOptionTile(
                  label: 'Temperature',
                  trailing: _buildToggleChips(
                    options: ['°C', '°F'],
                    selected: _temperatureUnit,
                    onSelect: (v) => setState(() => _temperatureUnit = v),
                  ),
                ),
                _buildDivider(),
                _buildOptionTile(
                  label: 'Wind',
                  trailing: _buildToggleChips(
                    options: ['km/h', 'm/s'],
                    selected: _windUnit,
                    onSelect: (v) => setState(() => _windUnit = v),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // ── 🔔 Notifications ────────────────────────────
              _buildSectionHeader('🔔  Notifications'),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.notifications_active_rounded,
                  label: 'Enable Alerts',
                  value: _enableAlerts,
                  onChanged: (v) => setState(() => _enableAlerts = v),
                ),
              ]),

              const SizedBox(height: 16),

              // ── 📍 Locations ────────────────────────────────
              _buildSectionHeader('📍  Locations'),
              _buildCard([
                ..._locations.asMap().entries.map((e) => Column(
                      children: [
                        _buildLocationTile(e.value),
                        if (e.key < _locations.length - 1) _buildDivider(),
                      ],
                    )),
              ]),

              const SizedBox(height: 16),

              // ── 🌈 Theme ────────────────────────────────────
              _buildSectionHeader('🌈  Theme'),
              _buildCard([
                _buildSwitchTile(
                  icon: _lightMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  label: _lightMode ? 'Light Mode' : 'Dark Mode',
                  value: _lightMode,
                  onChanged: (v) => setState(() => _lightMode = v),
                ),
              ]),

              const SizedBox(height: 16),

              // ── ℹ️ About ────────────────────────────────────
              _buildSectionHeader('ℹ️  About'),
              _buildCard([
                _buildInfoRow(Icons.wb_sunny_rounded, 'App Name',    'Weather App'),
                _buildDivider(),
                _buildInfoRow(Icons.tag_rounded,       'Version',     AppConstants.appVersion),
                _buildDivider(),
                _buildInfoRow(Icons.group_rounded,     'Team',        AppConstants.teamName),
                _buildDivider(),
                _buildInfoRow(Icons.school_rounded,    'University',  AppConstants.university),
              ]),

              // ── Danh sách thành viên ──────────────────────
              const SizedBox(height: 16),
              _buildSectionHeader('👥  Thành Viên Nhóm'),
              _buildCard(
                AppConstants.members.asMap().entries.map((e) {
                  final colors = [
                    const Color(0xFF1E88E5),
                    const Color(0xFF43A047),
                    const Color(0xFFE53935),
                  ];
                  final color = colors[e.key % colors.length];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: color,
                              child: Text(
                                e.value['name']![0],
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.value['name']!,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1565C0))),
                                  Text('MSSV: ${e.value['id']}  •  ${e.value['screen']} Screen',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (e.key < AppConstants.members.length - 1) _buildDivider(),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),

        // === FOOTER: Thông tin nhóm ===
        const MemberInfoFooter(),
      ],
    );
  }

  // ── Section header ────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1565C0))),
    );
  }

  // ── Card container ────────────────────────────────────────
  Widget _buildCard(List<Widget> children) {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _buildDivider() => Divider(height: 1, color: Colors.grey.shade100);

  // ── Option tile với trailing widget ──────────────────────
  Widget _buildOptionTile({required String label, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700)),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  // ── Switch tile ───────────────────────────────────────────
  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E88E5)),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E88E5),
          ),
        ],
      ),
    );
  }

  // ── Location tile ─────────────────────────────────────────
  Widget _buildLocationTile(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF1E88E5)),
          const SizedBox(width: 10),
          Text(name,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // ── Info row ──────────────────────────────────────────────
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E88E5)),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1565C0))),
          ),
        ],
      ),
    );
  }

  // ── Toggle chips ──────────────────────────────────────────
  Widget _buildToggleChips({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((opt) {
        final bool isSel = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFF1E88E5) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(opt,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSel ? Colors.white : Colors.grey.shade600)),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../service/settings_service.dart';
import '../service/firestore_service.dart';
import '../service/weather_data_manager.dart';
import '../service/auth_service.dart';

final ValueNotifier<bool> _isUploadingAvatar = ValueNotifier(false);

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
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => _showBottomSheet(context, 'Hồ Sơ Cá Nhân', _buildProfileDetails()),
                        borderRadius: BorderRadius.circular(24),
                        child: _buildProfileCard(),
                      ),
                      const SizedBox(height: 24),
                      
                      _sectionLabel('Thông Tin & Lịch Sử'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: SettingsService.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: SettingsService.cardBorderColor),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => _showBottomSheet(context, 'Thành Viên Nhóm 1', _buildTeamList()),
                              child: _buildSettingTile(Icons.groups_rounded, 'Thành Viên Nhóm', 'Chi tiết', showTopRadius: true),
                            ),
                            Divider(height: 1, color: SettingsService.dividerColor),
                            InkWell(
                              onTap: () => _showBottomSheet(context, 'Công Nghệ Sử Dụng', _buildTechStack()),
                              child: _buildSettingTile(Icons.code_rounded, 'Công Nghệ Sử Dụng', 'Chi tiết'),
                            ),
                            Divider(height: 1, color: SettingsService.dividerColor),
                            InkWell(
                              onTap: () => _showBottomSheet(context, 'Thành Phố Yêu Thích', _buildFavoritesList()),
                              child: _buildSettingTile(Icons.star_rounded, 'Thành Phố Yêu Thích', 'Quản lý'),
                            ),
                            Divider(height: 1, color: SettingsService.dividerColor),
                            InkWell(
                              onTap: () => _showBottomSheet(context, 'Lịch Sử Hoạt Động', _buildSearchHistory()),
                              child: _buildSettingTile(Icons.history_rounded, 'Lịch Sử Hoạt Động', 'Xem'),
                            ),
                            Divider(height: 1, color: SettingsService.dividerColor),
                            InkWell(
                              onTap: () => _showBottomSheet(context, 'Nguồn Dữ Liệu', _buildDataSource()),
                              child: _buildSettingTile(Icons.data_usage_rounded, 'Nguồn Dữ Liệu', 'Chi tiết'),
                            ),
                            Divider(height: 1, color: SettingsService.dividerColor),
                            InkWell(
                              onTap: () => _showFeedbackDialog(context),
                              child: _buildSettingTile(Icons.feedback_rounded, 'Gửi Phản Hồi', 'Gửi ý kiến', showBottomRadius: true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildSettingsAndLogout(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, String title, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SettingsService.scaffoldBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SettingsService.dividerColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(title, style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: child)),
          ],
        ),
      ),
    );
  }

  // ── Profile Card (Mới) ────────────────────────────────────
  Widget _buildProfileCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String displayName = user.email ?? "Khách";
        String? avatarUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          displayName = data['username'] ?? displayName;
          avatarUrl = data['avatarUrl'];
        }

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
              _buildAvatarWidget(avatarUrl, 64),
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
                    Text(displayName,
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
    );
  }

  // ── Full Profile Details ─────────────────────────────────
  Widget _buildProfileDetails() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text("Chưa đăng nhập", style: GoogleFonts.poppins(color: SettingsService.textColor)));
    }
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text("Không tìm thấy dữ liệu", style: GoogleFonts.poppins(color: SettingsService.textColor)));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final username = data['username'] ?? 'Không rõ';
        final email = data['email'] ?? user.email ?? 'Không rõ';
        final avatarUrl = data['avatarUrl'] as String?;
        final createdAt = data['createdAt'] != null 
            ? (data['createdAt'] as Timestamp).toDate().toString().split(' ')[0] 
            : 'Không rõ';
            
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _isUploadingAvatar,
                  builder: (context, isUploading, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildAvatarWidget(avatarUrl, 100),
                        if (isUploading)
                          const CircularProgressIndicator(color: Colors.white),
                      ],
                    );
                  }
                ),
                GestureDetector(
                  onTap: () => _pickAndUploadAvatar(context, user.uid),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC427FB),
                      shape: BoxShape.circle,
                      border: Border.all(color: SettingsService.cardColor, width: 3),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _infoRow(
              'Tên hiển thị', 
              username,
              onEdit: () {
                _showEditUsernameDialog(context, user.uid, username);
              }
            ),
            const SizedBox(height: 12),
            _infoRow('Email', email),
            const SizedBox(height: 12),
            _infoRow('Ngày tham gia', createdAt),
            const SizedBox(height: 12),
            _infoRow('UID', user.uid, isMuted: true),
          ],
        );
      },
    );
  }

  Widget _buildAvatarWidget(String? avatarData, double size) {
    ImageProvider? imageProvider;
    if (avatarData != null && avatarData.isNotEmpty) {
      if (avatarData.startsWith('http')) {
        imageProvider = NetworkImage(avatarData);
      } else {
        try {
          imageProvider = MemoryImage(base64Decode(avatarData));
        } catch (e) {
          imageProvider = null;
        }
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFC427FB).withValues(alpha: 0.2),
        shape: BoxShape.circle,
        image: imageProvider != null ? DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ) : null,
      ),
      child: imageProvider == null 
        ? Icon(Icons.person_rounded, color: SettingsService.accentTitleColor, size: size * 0.5)
        : null,
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context, String uid) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 80,
      );
      
      if (image == null) return;

      _isUploadingAvatar.value = true;
      
      // Đọc file thành bytes và mã hóa Base64 để lưu trực tiếp vào Firestore
      // Cách này giúp bypass hoàn toàn lỗi CORS của Firebase Storage trên Web!
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'avatarUrl': base64String,
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh lên: $e')),
        );
      }
    } finally {
      _isUploadingAvatar.value = false;
    }
  }

  void _showEditUsernameDialog(BuildContext context, String uid, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SettingsService.cardColor,
          title: Text('Đổi Tên Hiện Thị', style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            style: GoogleFonts.poppins(color: SettingsService.textColor),
            decoration: InputDecoration(
              hintText: 'Nhập tên mới',
              hintStyle: GoogleFonts.poppins(color: SettingsService.textMutedColor),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SettingsService.textMutedColor)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFFC427FB))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.poppins(color: SettingsService.textMutedColor)),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'username': controller.text.trim()
                  });
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text('Lưu', style: GoogleFonts.poppins(color: const Color(0xFFC427FB), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  Widget _infoRow(String label, String value, {bool isMuted = false, VoidCallback? onEdit}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: SettingsService.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SettingsService.cardBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 13)),
          Row(
            children: [
              Text(value, style: GoogleFonts.poppins(color: isMuted ? SettingsService.textDimColor : SettingsService.textColor, fontSize: 13, fontWeight: FontWeight.w600)),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onEdit,
                  child: Icon(Icons.edit_rounded, color: const Color(0xFFC427FB), size: 18),
                ),
              ]
            ],
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

              ValueListenableBuilder<bool>(
                valueListenable: SettingsService.isLightMode,
                builder: (context, isLight, _) {
                  return InkWell(
                    onTap: () {
                      SettingsService.toggleLightMode();
                    },
                    child: _buildSettingTile(Icons.dark_mode_rounded, 'Giao diện', isLight ? 'Sáng (Light)' : 'Tối (Dark)', showTopRadius: true),
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

              // Nút Clear Cache
              InkWell(
                onTap: () async {
                  await WeatherDataManager().loadAllData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã xóa bộ nhớ đệm và tải lại dữ liệu thời tiết mới nhất!', style: GoogleFonts.poppins(color: Colors.white)),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: _buildSettingTile(
                    Icons.cleaning_services_rounded,
                    'Làm mới dữ liệu',
                    'Xóa Cache', showBottomRadius: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Nhóm Quản lý Tài khoản (Thay Đổi Mật Khẩu, Xóa, Đăng Xuất)
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
              // Nút Thay Đổi Mật Khẩu
              InkWell(
                onTap: () => _showChangePasswordDialog(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.password_rounded,
                            size: 18, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 14),
                      Text('Thay Đổi Mật Khẩu',
                          style: GoogleFonts.poppins(
                              color: SettingsService.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: SettingsService.dividerColor),

              // Nút Xóa Tài Khoản
              InkWell(
                onTap: () => _showDeleteAccountDialog(context),
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

  // ── Thêm Logic Thay Đổi Mật Khẩu ───────────────────────────
  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: SettingsService.bgGradientBottom,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Thay Đổi Mật Khẩu',
                style: GoogleFonts.poppins(color: SettingsService.textColor, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordCtrl,
                      obscureText: true,
                      style: GoogleFonts.poppins(color: SettingsService.textColor),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu hiện tại',
                        labelStyle: GoogleFonts.poppins(color: SettingsService.textMutedColor),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SettingsService.dividerColor)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPasswordCtrl,
                      obscureText: true,
                      style: GoogleFonts.poppins(color: SettingsService.textColor),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        labelStyle: GoogleFonts.poppins(color: SettingsService.textMutedColor),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SettingsService.dividerColor)),
                      ),
                      validator: (val) => (val == null || val.length < 6) ? 'Mật khẩu mới phải từ 6 ký tự' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Hủy', style: GoogleFonts.poppins(color: SettingsService.textMutedColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setStateDialog(() => isLoading = true);
                      try {
                        await AuthService().changePassword(currentPasswordCtrl.text, newPasswordCtrl.text);
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đổi mật khẩu thành công!', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setStateDialog(() => isLoading = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Xác Nhận', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

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

  // ── Thêm Logic Gửi Phản Hồi ────────────────────────────────
  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackCtrl = TextEditingController();
    double currentRating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: SettingsService.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.feedback_rounded, color: Color(0xFFC427FB)),
                  const SizedBox(width: 10),
                  Text(
                    'Gửi Phản Hồi',
                    style: GoogleFonts.poppins(
                      color: SettingsService.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đánh giá của bạn:',
                    style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            currentRating = starValue;
                          });
                        },
                        child: Icon(
                          Icons.star_rounded,
                          color: starValue <= currentRating ? const Color(0xFFFFD700) : SettingsService.dividerColor,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ý kiến đóng góp:',
                    style: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: feedbackCtrl,
                    maxLines: 4,
                    style: GoogleFonts.poppins(color: SettingsService.textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Nhập ý kiến phản hồi của bạn về ứng dụng...',
                      hintStyle: GoogleFonts.poppins(color: SettingsService.textMutedColor, fontSize: 12),
                      filled: true,
                      fillColor: SettingsService.scaffoldBgColor.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: SettingsService.cardBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFC427FB)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.poppins(color: SettingsService.textMutedColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC427FB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final message = feedbackCtrl.text.trim();
                    if (message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập ý kiến phản hồi của bạn!')),
                      );
                      return;
                    }

                    // Đóng dialog trước
                    Navigator.pop(context);

                    try {
                      final firestore = FirestoreService();
                      await firestore.saveFeedback(message, currentRating);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cảm ơn bạn đã gửi ý kiến phản hồi đóng góp!',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Không thể gửi phản hồi: $e')),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Gửi',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

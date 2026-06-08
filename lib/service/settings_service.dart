import 'package:flutter/material.dart';
import '../service/firestore_service.dart';

class SettingsService {
  // Biến toàn cục quản lý trạng thái hiển thị nhiệt độ
  static final ValueNotifier<bool> isCelsius = ValueNotifier<bool>(true);

  // Biến toàn cục quản lý thông báo
  static final ValueNotifier<bool> isNotificationEnabled = ValueNotifier<bool>(true);

  // Biến toàn cục quản lý giao diện sáng
  static final ValueNotifier<bool> isLightMode = ValueNotifier<bool>(false);

  // Chuyển đổi trạng thái nhiệt độ
  static void toggleTemperatureUnit() {
    isCelsius.value = !isCelsius.value;
    FirestoreService().updateUserSettings(isCelsius.value, isLightMode.value);
  }

  // Chuyển đổi trạng thái thông báo
  static void toggleNotification() {
    isNotificationEnabled.value = !isNotificationEnabled.value;
  }

  // Chuyển đổi trạng thái giao diện sáng
  static void toggleLightMode() {
    isLightMode.value = !isLightMode.value;
    FirestoreService().updateUserSettings(isCelsius.value, isLightMode.value);
  }

  // ── Tiện ích màu sắc động (Light/Dark) ──────────────────
  static Color get bgGradientTop => isLightMode.value ? const Color(0xFFE0E5FF) : const Color(0xFF2E335A);
  static Color get bgGradientBottom => isLightMode.value ? const Color(0xFFF3F5FF) : const Color(0xFF1C1B33);
  // Typography Colors
  static Color get textColor => isLightMode.value ? Colors.black : Colors.white;
  static Color get textDimColor => isLightMode.value ? Colors.black87 : Colors.white70;
  static Color get textMutedColor => isLightMode.value ? Colors.black87.withValues(alpha: 0.7) : Colors.white54;
  static Color get cardColor => isLightMode.value ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.05);
  static Color get cardBorderColor => isLightMode.value ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.1);
  static Color get dividerColor => isLightMode.value ? Colors.black12 : Colors.white.withValues(alpha: 0.08);
  static Color get accentTitleColor => isLightMode.value ? Colors.blue.shade800 : const Color(0xFFE0D9FF);
  static Color get footerBgColor => isLightMode.value ? Colors.white : const Color(0xFF1F1D47).withValues(alpha: 0.95);
  static Color get scaffoldBgColor => isLightMode.value ? Colors.white : const Color(0xFF1C1B33);
  static Color get primaryGradientStart => isLightMode.value ? Colors.blue.shade400 : const Color(0xFF48319D);
  static Color get primaryGradientEnd => isLightMode.value ? Colors.blue.shade600 : const Color(0xFF5936B4);
}

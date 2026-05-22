import 'package:flutter/foundation.dart';

class SettingsService {
  // Biến toàn cục quản lý trạng thái hiển thị nhiệt độ
  static final ValueNotifier<bool> isCelsius = ValueNotifier<bool>(true);

  // Biến toàn cục quản lý thông báo
  static final ValueNotifier<bool> isNotificationEnabled = ValueNotifier<bool>(true);

  // Chuyển đổi trạng thái nhiệt độ
  static void toggleTemperatureUnit() {
    isCelsius.value = !isCelsius.value;
  }

  // Chuyển đổi trạng thái thông báo
  static void toggleNotification() {
    isNotificationEnabled.value = !isNotificationEnabled.value;
  }
}

import 'package:flutter/foundation.dart';

class SettingsService {
  // Biến toàn cục quản lý trạng thái hiển thị nhiệt độ
  static final ValueNotifier<bool> isCelsius = ValueNotifier<bool>(true);

  // Chuyển đổi trạng thái
  static void toggleTemperatureUnit() {
    isCelsius.value = !isCelsius.value;
  }
}

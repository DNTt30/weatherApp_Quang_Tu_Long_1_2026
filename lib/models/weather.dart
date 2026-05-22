// ============================================================
// Class Weather — Quang phụ trách
// Thuộc tính: temperature, humidity, windSpeed, status, uvIndex, icon
// ============================================================
class Weather {
  String city;
  double temperature;
  String status;
  double humidity;
  bool isRaining;
  double windSpeed;    // km/h
  int uvIndex;         // 0 - 11+
  String icon;         // tên icon (sunny/cloudy/rainy)

  Weather({
    required this.city,
    required this.temperature,
    required this.status,
    required this.humidity,
    required this.isRaining,
    this.windSpeed = 0.0,
    this.uvIndex = 0,
    this.icon = 'sunny',
  });

  // ── Format nhiệt độ (Celsius) ─────────────────────────────
  String formatTemperature({bool fahrenheit = false}) {
    if (fahrenheit) {
      final f = temperature * 9 / 5 + 32;
      return '${f.toStringAsFixed(1)}°F';
    }
    return '${temperature.toStringAsFixed(1)}°C';
  }

  // ── Cảnh báo nếu UV cao hoặc gió mạnh ────────────────────
  String? getWarning() {
    final List<String> warnings = [];
    if (uvIndex >= 8) {
      warnings.add('⚠️ Chỉ số UV rất cao ($uvIndex) — hãy dùng kem chống nắng!');
    } else if (uvIndex >= 6) {
      warnings.add('⚠️ Chỉ số UV cao ($uvIndex) — hạn chế ra ngoài buổi trưa.');
    }
    if (windSpeed >= 60) {
      warnings.add('💨 Gió rất mạnh (${windSpeed}km/h) — không ra ngoài nếu không cần thiết!');
    } else if (windSpeed >= 30) {
      warnings.add('💨 Gió mạnh (${windSpeed}km/h) — cẩn thận khi di chuyển.');
    }
    if (warnings.isEmpty) return null;
    return warnings.join('\n');
  }

  // ── Mô tả chỉ số UV ──────────────────────────────────────
  String getUvLabel() {
    if (uvIndex <= 2) return 'Thấp';
    if (uvIndex <= 5) return 'Trung bình';
    if (uvIndex <= 7) return 'Cao';
    if (uvIndex <= 10) return 'Rất cao';
    return 'Cực kỳ cao';
  }

  // ── Phân loại gió (Beaufort scale) ───────────────────────
  String getWindLabel() {
    if (windSpeed < 2)  return 'Lặng gió';
    if (windSpeed < 12) return 'Gió nhẹ';
    if (windSpeed < 30) return 'Gió vừa';
    if (windSpeed < 60) return 'Gió mạnh';
    return 'Bão';
  }

  // ── Thông tin đầy đủ ─────────────────────────────────────
  String getWeatherInfo() {
    return 'City: $city, Temp: ${formatTemperature()}, Status: $status, '
      'Humidity: $humidity%, Wind: ${windSpeed}km/h, UV: $uvIndex, '
      'Raining: ${isRaining ? "Yes" : "No"}';
  }

  // ── Chuyển sang Map (Firestore) ───────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'temperature': temperature,
      'status': status,
      'humidity': humidity,
      'isRaining': isRaining,
      'windSpeed': windSpeed,
      'uvIndex': uvIndex,
      'icon': icon,
    };
  }

  @override
  String toString() => getWeatherInfo();
}

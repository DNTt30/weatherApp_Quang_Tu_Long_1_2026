// ============================================================
// Class Forecast — Tú phụ trách
// Thuộc tính: dateTime, minTemp, maxTemp, rainProbability
// ============================================================
class Forecast {
  String id;
  String dateTime;
  double minTemp;
  double maxTemp;
  int rainProbability;  // 0–100 (%)
  String? description;
  String? icon;

  Forecast({
    required this.id,
    required this.dateTime,
    required this.minTemp,
    required this.maxTemp,
    required this.rainProbability,
    this.description,
    this.icon,
  });

  // ── Tính chênh lệch nhiệt độ ngày/đêm ────────────────────
  double getTemperatureDifference() {
    return maxTemp - minTemp;
  }

  // ── Trả về thông tin dự báo ──────────────────────────────
  String getForecast() {
    return '$dateTime: $minTemp°C – $maxTemp°C';
  }

  // ── Phân loại xác suất mưa ───────────────────────────────
  String getRainLabel() {
    if (rainProbability >= 80) return 'Chắc chắn mưa';
    if (rainProbability >= 50) return 'Có thể mưa';
    if (rainProbability >= 20) return 'Ít khả năng mưa';
    return 'Không mưa';
  }

  // ── Nhiệt độ trung bình trong ngày ───────────────────────
  double getAverageTemp() {
    return (minTemp + maxTemp) / 2;
  }

  // ── Chuyển sang Map ───────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'rainProbability': rainProbability,
      'description': description,
      'icon': icon,
    };
  }

  @override
  String toString() => getForecast();
}

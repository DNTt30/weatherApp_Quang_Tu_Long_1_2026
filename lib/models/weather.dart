// Câu 3: CLASS - Tạo class Weather với biến và phương thức
class Weather {
  final String id;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String status;
  final double uvIndex;
  final String icon;

  Weather({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.status,
    required this.uvIndex,
    required this.icon,
  });

  /// Định dạng nhiệt độ thành chuỗi với 1 chữ số thập phân
  /// Ví dụ: 32.5°C
  String formatTemperature() {
    return '${temperature.toStringAsFixed(1)}°C';
  }

  /// Đánh giá mức độ nguy hiểm của thời tiết dựa trên UV hoặc trạng thái bão
  String evaluateDangerLevel() {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus.contains('bão') ||
        normalizedStatus.contains('storm') ||
        normalizedStatus.contains('giông')) {
      return 'Nguy hiểm: Thời tiết xấu';
    }

    if (uvIndex >= 11) return 'Nguy hiểm: UV cực cao';
    if (uvIndex >= 8) return 'Cảnh báo: UV rất cao';
    if (uvIndex >= 6) return 'Chú ý: UV cao';

    return 'An toàn';
  }
}

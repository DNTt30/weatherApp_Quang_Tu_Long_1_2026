// lib/models/weather.dart
class Weather {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String status;
  final double uvIndex;
  final String icon;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.status,
    required this.uvIndex,
    required this.icon,
  });

  String formatTemperature() {
    return '${temperature.toStringAsFixed(1)}°C';
  }

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
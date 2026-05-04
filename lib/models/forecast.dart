// YÊU CẦU 5: CLASS - Tạo class Forecast với biến và phương thức
class Forecast {
  String id;
  String dateTime;
  double minTemp;
  double maxTemp;
  int rainProbability;

  Forecast({
    required this.id,
    required this.dateTime,
    required this.minTemp,
    required this.maxTemp,
    required this.rainProbability,
  });

  // Phương thức getForecast
  String getForecast() {
    return '$dateTime: $minTemp°C – $maxTemp°C';
  }

  // Phương thức tính chênh lệch nhiệt độ
  double getTemperatureDifference() {
    return maxTemp - minTemp;
  }
}

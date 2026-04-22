class Forecast {
  // Khai báo các biến miêu tả đặc trưng của đối tượng
  String id;
  String dateTime;
  double minTemp;
  double maxTemp;
  int rainProbability;

  // Hàm khởi tạo (Constructor)
  Forecast({
    required this.id,
    required this.dateTime,
    required this.minTemp,
    required this.maxTemp,
    required this.rainProbability,
  });

  // Phương thức 1: Tính toán chênh lệch nhiệt độ ngày đêm
  double getTemperatureDifference() {
    return maxTemp - minTemp;
  }

  // Phương thức 2: In thông tin dự báo
  void displayForecastInfo() {
    print('[$id] Dự báo thời tiết: $dateTime');
    print('  - Nhiệt độ: $minTemp°C đến $maxTemp°C (Chênh lệch: ${getTemperatureDifference().toStringAsFixed(1)}°C)');
    print('  - Xác suất mưa: $rainProbability%');
    if (rainProbability > 70) {
      print('  -> Lời khuyên: Khả năng mưa rất cao, hãy mang theo áo mưa!');
    }
  }
}
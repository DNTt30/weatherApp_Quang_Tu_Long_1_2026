// YÊU CẦU 5: CLASS - Tạo class Forecast với biến và phương thức
class Forecast {
  String day;
  double temp;

  Forecast({required this.day, required this.temp});

  // Phương thức getForecast
  String getForecast() {
    return '$day: $temp°C';
  }
}

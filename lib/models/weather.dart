// YÊU CẦU 5: CLASS - Tạo class Weather với biến và phương thức
class Weather {
  String city;
  double temperature;
  String status;
  double humidity;
  bool isRaining;

  Weather({
    required this.city,
    required this.temperature,
    required this.status,
    required this.humidity,
    required this.isRaining,
  });

  // Phương thức getWeatherInfo
  String getWeatherInfo() {
    return 'City: $city, Temp: $temperature°C, Status: $status, Humidity: $humidity%, Raining: ${isRaining ? 'Yes' : 'No'}';
  }
}

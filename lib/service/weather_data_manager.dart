import 'api_service.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import 'firestore_service.dart';
import 'package:flutter/foundation.dart';

class WeatherDataManager {
  static final WeatherDataManager _instance = WeatherDataManager._internal();
  factory WeatherDataManager() => _instance;
  WeatherDataManager._internal();

  final ApiService _apiService = ApiService();
  bool isLoading = true;
  
  // Dữ liệu thời tiết của 5 thành phố chính
  List<Map<String, dynamic>> allCitiesData = [];

  final List<Map<String, dynamic>> _baseCities = [
    {'city': 'Hà Nội', 'lat': 21.0285, 'lon': 105.8542},
    {'city': 'Đà Nẵng', 'lat': 16.0544, 'lon': 108.2022},
    {'city': 'Hồ Chí Minh', 'lat': 10.8231, 'lon': 106.6297},
    {'city': 'Hải Phòng', 'lat': 20.8449, 'lon': 106.6881},
    {'city': 'Cần Thơ', 'lat': 10.0452, 'lon': 105.7469},
  ];

  Future<void> loadAllData() async {
    isLoading = true;
    allCitiesData.clear();

    for (var c in _baseCities) {
      try {
        final data = await _apiService.fetchWeatherData(c['lat'], c['lon'], c['city']);
        
        final Weather weather = data['weather'] as Weather;
        final List<Forecast> forecasts = data['forecasts'] as List<Forecast>;

        allCitiesData.add({
          'city': c['city'],
          'lat': c['lat'],
          'lon': c['lon'],
          'weather': weather,
          'forecasts': forecasts,
        });

        // ----------------------------------------
        // Phân rã dữ liệu lưu vào 3 Collections Firebase (Theo Yêu Cầu GV)
        // 1. Long: Lưu City vào cities
        // 2. Quang: Lưu Weather vào weather
        // 3. Tú: Lưu Forecast vào forecasts
        // ----------------------------------------
        try {
          final firestore = FirestoreService();
          
          // Lưu City
          firestore.addCity({
            'name': c['city'],
            'latitude': c['lat'],
            'longitude': c['lon'],
          });

          // Lưu Weather
          firestore.saveWeather(c['city'].toString(), {
            'temperature': weather.temperature,
            'status': weather.status,
            'humidity': weather.humidity,
            'windSpeed': weather.windSpeed,
            'uvIndex': weather.uvIndex,
            'icon': weather.icon,
            'isRaining': weather.isRaining,
          });

          // Lưu Forecasts
          firestore.saveForecast(c['city'].toString(), forecasts.map((f) => {
            'id': f.id,
            'dateTime': f.dateTime,
            'minTemp': f.minTemp,
            'maxTemp': f.maxTemp,
            'rainProbability': f.rainProbability,
            'description': f.description,
          }).toList());

        } catch (dbErr) {
          debugPrint('Lỗi lưu Firebase (có thể bỏ qua nếu chạy debug): $dbErr');
        }

      } catch (e) {
        // Fallback data if API fails
        final fallbackWeather = Weather(
          city: c['city'], temperature: 28.0, status: 'Sunny', humidity: 70, isRaining: false, icon: 'sunny'
        );
        allCitiesData.add({
          'city': c['city'],
          'lat': c['lat'],
          'lon': c['lon'],
          'weather': fallbackWeather,
          'forecasts': <Forecast>[],
        });
      }
    }
    isLoading = false;
  }
}

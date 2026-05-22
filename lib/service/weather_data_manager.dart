import 'api_service.dart';
import '../models/weather.dart';
import '../models/forecast.dart';

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
        allCitiesData.add({
          'city': c['city'],
          'lat': c['lat'],
          'lon': c['lon'],
          'weather': data['weather'] as Weather,
          'forecasts': data['forecasts'] as List<Forecast>,
        });
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

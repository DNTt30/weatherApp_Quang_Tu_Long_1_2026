import 'dart:math' as math;
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
  
  // Dữ liệu thời tiết của các khu vực lân cận được đề xuất
  List<Map<String, dynamic>> recommendedNearbyData = [];

  // Thành phố đang được hiển thị hoạt động toàn cục
  static final ValueNotifier<String> activeCityName = ValueNotifier<String>('Hà Nội');

  final List<Map<String, dynamic>> _baseCities = [
    {'city': 'Hà Nội', 'lat': 21.0285, 'lon': 105.8542},
    {'city': 'Đà Nẵng', 'lat': 16.0544, 'lon': 108.2022},
    {'city': 'Hồ Chí Minh', 'lat': 10.8231, 'lon': 106.6297},
    {'city': 'Hải Phòng', 'lat': 20.8449, 'lon': 106.6881},
    {'city': 'Cần Thơ', 'lat': 10.0452, 'lon': 105.7469},
  ];

  // Danh sách các vùng miền lớn ở Việt Nam dùng để đề xuất
  final List<Map<String, dynamic>> _vietnamRegions = [
    {'city': 'Hà Nội', 'lat': 21.0285, 'lon': 105.8542},
    {'city': 'Hải Phòng', 'lat': 20.8449, 'lon': 106.6881},
    {'city': 'Ninh Bình', 'lat': 20.2506, 'lon': 105.9744},
    {'city': 'Hạ Long', 'lat': 20.9599, 'lon': 107.0425},
    {'city': 'Sầm Sơn', 'lat': 19.7433, 'lon': 105.7882},
    {'city': 'Vinh', 'lat': 18.6734, 'lon': 105.6813},
    {'city': 'Huế', 'lat': 16.4637, 'lon': 107.5908},
    {'city': 'Đà Nẵng', 'lat': 16.0544, 'lon': 108.2022},
    {'city': 'Hội An', 'lat': 15.8801, 'lon': 108.3380},
    {'city': 'Quy Nhơn', 'lat': 13.7830, 'lon': 109.2198},
    {'city': 'Nha Trang', 'lat': 12.2388, 'lon': 109.1967},
    {'city': 'Đà Lạt', 'lat': 11.9404, 'lon': 108.4583},
    {'city': 'Phan Thiết', 'lat': 10.9254, 'lon': 108.1042},
    {'city': 'Vũng Tàu', 'lat': 10.3460, 'lon': 107.0843},
    {'city': 'Hồ Chí Minh', 'lat': 10.8231, 'lon': 106.6297},
    {'city': 'Cần Thơ', 'lat': 10.0452, 'lon': 105.7469},
    {'city': 'Phú Quốc', 'lat': 10.2289, 'lon': 103.9610},
  ];

  // Tính khoảng cách giữa hai điểm tọa độ bằng công thức Haversine (km)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Bán kính Trái Đất (km)
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) {
    return deg * (math.pi / 180);
  }

  Future<void> loadAllData() async {
    isLoading = true;
    allCitiesData.clear();
    recommendedNearbyData.clear();

    final firestore = FirestoreService();
    List<Map<String, dynamic>> citiesToLoad = List.from(_baseCities);
    Map<String, dynamic>? lastSearchCity;

    try {
      final history = await firestore.getSearchHistory();
      if (history.isNotEmpty) {
        final lastSearch = history.first;
        if (lastSearch['lat'] != null && lastSearch['lon'] != null) {
          lastSearchCity = {
            'city': lastSearch['cityName'],
            'lat': lastSearch['lat'],
            'lon': lastSearch['lon'],
            'country': '',
          };
          
          // Xóa city này nếu nó nằm trong baseCities để tránh trùng lặp
          citiesToLoad.removeWhere((c) => c['city'] == lastSearch['cityName']);
          
          // Thêm lên đầu danh sách
          citiesToLoad.insert(0, lastSearchCity);

          // Cập nhật thành phố hoạt động toàn cục sang lịch sử mới nhất
          activeCityName.value = lastSearch['cityName'];
        }
      }
    } catch (e) {
      // Bỏ qua lỗi nếu chưa có lịch sử
    }

    // 1. Load weather cho baseCities
    for (var c in citiesToLoad) {
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

        // Phân rã dữ liệu lưu vào 3 Collections Firebase (Theo Yêu Cầu GV)
        try {
          // Lưu City
          firestore.saveCity(c['city'].toString(), {
            'name': c['city'],
            'country': c['country'] ?? '',
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

    // 2. Tính toán và load weather cho các khu vực lân cận đề xuất
    List<Map<String, dynamic>> nearbyRegions = [];
    final double originLat = lastSearchCity != null ? lastSearchCity['lat'] : 21.0285; // Mặc định Hà Nội
    final double originLon = lastSearchCity != null ? lastSearchCity['lon'] : 105.8542;
    final String originName = lastSearchCity != null ? lastSearchCity['city'] : 'Hà Nội';

    List<Map<String, dynamic>> candidates = [];
    for (var r in _vietnamRegions) {
      if (r['city'].toString().toLowerCase() != originName.toLowerCase()) {
        final dist = calculateDistance(originLat, originLon, r['lat'], r['lon']);
        candidates.add({
          'city': r['city'],
          'lat': r['lat'],
          'lon': r['lon'],
          'distance': dist,
        });
      }
    }

    // Sắp xếp tăng dần theo khoảng cách và lấy 3 cái gần nhất
    candidates.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    nearbyRegions = candidates.take(3).toList();

    for (var nr in nearbyRegions) {
      try {
        final data = await _apiService.fetchWeatherData(nr['lat'], nr['lon'], nr['city']);
        
        final Weather weather = data['weather'] as Weather;
        final List<Forecast> forecasts = data['forecasts'] as List<Forecast>;

        recommendedNearbyData.add({
          'city': nr['city'],
          'lat': nr['lat'],
          'lon': nr['lon'],
          'distance': nr['distance'],
          'weather': weather,
          'forecasts': forecasts,
        });
      } catch (e) {
        // Fallback data if API fails
        final fallbackWeather = Weather(
          city: nr['city'], temperature: 28.0, status: 'Sunny', humidity: 70, isRaining: false, icon: 'sunny'
        );
        recommendedNearbyData.add({
          'city': nr['city'],
          'lat': nr['lat'],
          'lon': nr['lon'],
          'distance': nr['distance'],
          'weather': fallbackWeather,
          'forecasts': <Forecast>[],
        });
      }
    }

    isLoading = false;
  }
}

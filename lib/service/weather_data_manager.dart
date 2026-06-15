import 'dart:math' as math;
import 'api_service.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import 'firestore_service.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  
  // Thông báo khi dữ liệu đã được tải xong/cập nhật
  static final ValueNotifier<bool> onDataUpdated = ValueNotifier<bool>(false);

  final List<Map<String, dynamic>> _baseCities = [
    {'city': 'Hà Nội', 'lat': 21.0285, 'lon': 105.8542},
    {'city': 'Đà Nẵng', 'lat': 16.0544, 'lon': 108.2022},
    {'city': 'Hồ Chí Minh', 'lat': 10.8231, 'lon': 106.6297},
    {'city': 'Hải Phòng', 'lat': 20.8449, 'lon': 106.6881},
    {'city': 'Cần Thơ', 'lat': 10.0452, 'lon': 105.7469},
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

    List<Map<String, dynamic>> newAllCitiesData = [];

    // 1. Load weather cho baseCities
    for (var c in citiesToLoad) {
      try {
        final data = await _apiService.fetchWeatherData(c['lat'], c['lon'], c['city']);
        
        final Weather weather = data['weather'] as Weather;
        final List<Forecast> forecasts = data['forecasts'] as List<Forecast>;

        newAllCitiesData.add({
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
        newAllCitiesData.add({
          'city': c['city'],
          'lat': c['lat'],
          'lon': c['lon'],
          'weather': fallbackWeather,
          'forecasts': <Forecast>[],
        });
      }
    }

    List<Map<String, dynamic>> newRecommendedNearbyData = [];
    // 2. Tính toán và load weather cho các khu vực lân cận đề xuất
    List<Map<String, dynamic>> nearbyRegions = [];
    
    double originLat = 21.0285; // Mặc định Hà Nội
    double originLon = 105.8542;
    String originName = 'Hà Nội';

    // Ưu tiên 1: Kết quả tìm kiếm gần nhất (Sẽ bị ghi đè nếu có địa chỉ)
    if (lastSearchCity != null) {
      originLat = lastSearchCity['lat'];
      originLon = lastSearchCity['lon'];
      originName = lastSearchCity['city'];
    }

    // Ưu tiên 2 (Cao nhất): Địa chỉ đã lưu của người dùng
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('addressLat') && doc.data()!['addressLat'] != null) {
          originLat = doc.data()!['addressLat'];
          originLon = doc.data()!['addressLon'];
          originName = doc.data()!['address'];
        }
      } catch (e) {
        // Bỏ qua lỗi
      }
    }

    List<Map<String, dynamic>> candidates = [];
    for (var r in ApiService.vietnamProvinces) {
      if (r['name'].toString().toLowerCase() != originName.toLowerCase()) {
        final dist = calculateDistance(originLat, originLon, r['lat'], r['lon']);
        candidates.add({
          'city': r['name'],
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

        newRecommendedNearbyData.add({
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
        newRecommendedNearbyData.add({
          'city': nr['city'],
          'lat': nr['lat'],
          'lon': nr['lon'],
          'distance': nr['distance'],
          'weather': fallbackWeather,
          'forecasts': <Forecast>[],
        });
      }
    }

    allCitiesData = newAllCitiesData;
    recommendedNearbyData = newRecommendedNearbyData;
    isLoading = false;
    onDataUpdated.value = !onDataUpdated.value;
  }
}

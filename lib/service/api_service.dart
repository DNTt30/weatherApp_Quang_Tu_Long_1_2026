import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';

class ApiService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  // Lấy dữ liệu tọa độ từ tên thành phố
  Future<Map<String, dynamic>?> geocodeCity(String cityName) async {
    final url = Uri.parse('$_geocodingUrl?name=$cityName&count=1&language=en&format=json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final String country = result['country'] ?? '';
          final String countryLower = country.toLowerCase();
          
          // Chỉ chấp nhận các tỉnh thành phố thuộc Việt Nam
          if (countryLower.contains('vietnam') || countryLower.contains('việt nam') || countryLower.contains('viet nam')) {
            return {
              'name': result['name'],
              'country': country,
              'lat': result['latitude'],
              'lon': result['longitude'],
            };
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy dữ liệu thời tiết và dự báo tổng hợp từ Open-Meteo
  Future<Map<String, dynamic>> fetchWeatherData(double lat, double lon, String cityName) async {
    final url = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,is_day,precipitation,wind_speed_10m,weather_code&daily=temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_probability_max,weather_code&timezone=Asia%2FBangkok');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 1. Phân tích Current Weather
        final current = data['current'];
        final int weatherCode = current['weather_code'] ?? 0;
        final int isDay = current['is_day'] ?? 1;
        final weatherInfo = _interpretWMO(weatherCode, isDay);
        
        // Dữ liệu UV lấy từ mảng daily (hôm nay là index 0)
        final daily = data['daily'];
        double uvIndex = 0.0;
        if (daily != null && daily['uv_index_max'] != null && daily['uv_index_max'].isNotEmpty) {
          uvIndex = (daily['uv_index_max'][0] as num).toDouble();
        }

        final Weather weather = Weather(
          city: cityName,
          temperature: (current['temperature_2m'] as num).toDouble(),
          status: weatherInfo['status']!,
          humidity: (current['relative_humidity_2m'] as num).toDouble(),
          isRaining: (current['precipitation'] as num).toDouble() > 0 || weatherCode >= 50,
          windSpeed: (current['wind_speed_10m'] as num).toDouble(),
          uvIndex: uvIndex.round(),
          icon: weatherInfo['icon']!,
        );

        // 2. Phân tích Daily Forecast (5 ngày)
        final List<Forecast> forecasts = [];
        if (daily != null) {
          final List times = daily['time'];
          final List maxTemps = daily['temperature_2m_max'];
          final List minTemps = daily['temperature_2m_min'];
          final List rainProbs = daily['precipitation_probability_max'];
          final List codes = daily['weather_code'];

          // Lấy 5 ngày đầu tiên
          final int count = times.length > 5 ? 5 : times.length;
          for (int i = 0; i < count; i++) {
            // Format ngày: "YYYY-MM-DD" -> "DD/MM" hoặc tính Thứ
            String dateStr = times[i];
            DateTime date = DateTime.parse(dateStr);
            String dayLabel = _getWeekday(date.weekday);
            if (i == 0) dayLabel = "Hôm nay";
            if (i == 1) dayLabel = "Ngày mai";

            final codeInfo = _interpretWMO(codes[i] ?? 0, 1);
            
            forecasts.add(Forecast(
              id: 'f$i',
              dateTime: dayLabel,
              minTemp: (minTemps[i] as num).toDouble(),
              maxTemp: (maxTemps[i] as num).toDouble(),
              rainProbability: (rainProbs[i] as num).round(),
            )..description = codeInfo['status']); // Thêm mô tả nếu cần
          }
        }

        return {
          'weather': weather,
          'forecasts': forecasts,
        };
      } else {
        throw Exception('Lỗi gọi API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối API Open-Meteo: $e');
    }
  }

  // Chuyển đổi mã WMO sang trạng thái & icon hiển thị
  Map<String, String> _interpretWMO(int code, int isDay) {
    String status = 'Sunny';
    String icon = 'sunny';
    
    if (code == 0) {
      status = isDay == 1 ? 'Nắng đẹp' : 'Trời trong';
      icon = isDay == 1 ? 'sunny' : 'sunny';
    } else if (code == 1 || code == 2 || code == 3) {
      status = 'Có mây';
      icon = 'cloudy';
    } else if (code >= 45 && code <= 48) {
      status = 'Sương mù';
      icon = 'cloudy';
    } else if (code >= 51 && code <= 67) {
      status = 'Mưa vừa';
      icon = 'rainy';
    } else if (code >= 71 && code <= 77) {
      status = 'Tuyết';
      icon = 'rainy';
    } else if (code >= 80 && code <= 82) {
      status = 'Mưa rào';
      icon = 'rainy';
    } else if (code >= 95) {
      status = 'Giông bão';
      icon = 'rainy';
    }
    return {'status': status, 'icon': icon};
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Thứ Hai';
      case 2: return 'Thứ Ba';
      case 3: return 'Thứ Tư';
      case 4: return 'Thứ Năm';
      case 5: return 'Thứ Sáu';
      case 6: return 'Thứ Bảy';
      case 7: return 'Chủ Nhật';
      default: return '';
    }
  }
}

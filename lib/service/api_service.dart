import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';

class ApiService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  // Lấy dữ liệu tọa độ từ tên thành phố
  Future<Map<String, dynamic>?> geocodeCity(String cityName) async {
    final url = Uri.parse('$_geocodingUrl?name=${Uri.encodeComponent(cityName)}&count=1&language=en&format=json');
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
            final String name = _toNfc(result['name'] ?? '');
            return {
              'name': name,
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

  // Lấy danh sách các tỉnh/thành phố gợi ý thuộc Việt Nam
  Future<List<Map<String, dynamic>>> geocodeSuggestions(String query) async {
    final String queryTrimmed = query.trim();
    if (queryTrimmed.length < 2) return [];

    final String queryClean = _removeDiacritics(queryTrimmed.toLowerCase());
    final List<Map<String, dynamic>> results = [];

    // 1. Tìm kiếm trong danh sách 63 tỉnh/thành trước và phân loại độ ưu tiên
    final List<Map<String, dynamic>> localMatches = [];
    for (var prov in _vietnamProvinces) {
      final String provClean = _removeDiacritics(prov['name']!.toLowerCase());
      if (provClean.contains(queryClean)) {
        int rank = 2; // chứa từ khóa
        if (provClean == queryClean) {
          rank = 0; // khớp chính xác
        } else if (provClean.startsWith(queryClean)) {
          rank = 1; // bắt đầu bằng từ khóa
        }
        localMatches.add({
          'prov': prov,
          'rank': rank,
        });
      }
    }
    
    // Sắp xếp các tỉnh thành local theo độ ưu tiên
    localMatches.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));
    
    for (var m in localMatches) {
      final prov = m['prov'] as Map<String, dynamic>;
      results.add({
        'name': prov['name'],
        'country': 'Vietnam',
        'lat': prov['lat'],
        'lon': prov['lon'],
        'admin1': prov['admin1'],
      });
    }

    // 2. Gọi API để lấy thêm các kết quả chi tiết khác (quận, huyện, xã...)
    final url = Uri.parse('$_geocodingUrl?name=${Uri.encodeComponent(queryTrimmed)}&count=10&language=en&format=json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          for (var item in data['results']) {
            final String country = item['country'] ?? '';
            final String countryLower = country.toLowerCase();
            if (countryLower.contains('vietnam') || countryLower.contains('việt nam') || countryLower.contains('viet nam')) {
              final String name = item['name'];
              final String normalizedName = _toNfc(name).toLowerCase();
              
              // Tránh trùng tên với các tỉnh đã add ở bước 1 (sau khi đưa về NFC chuẩn hóa)
              final bool isDuplicate = results.any(
                (element) => _toNfc(element['name'].toString()).toLowerCase() == normalizedName
              );
              
              if (!isDuplicate) {
                results.add({
                  'name': name,
                  'country': country,
                  'lat': item['latitude'],
                  'lon': item['longitude'],
                  'admin1': item['admin1'] ?? '',
                });
              }
            }
          }
        }
      }
    } catch (e) {
      // ignore
    }

    return results;
  }

  String _toNfc(String str) {
    final Map<String, String> nfdToNfc = {
      'a\u0302': 'â', 'a\u0306': 'ă', 'e\u0302': 'ê', 'o\u0302': 'ô', 'o\u031b': 'ơ', 'u\u031b': 'ư',
      'A\u0302': 'Â', 'A\u0306': 'Ă', 'E\u0302': 'Ê', 'O\u0302': 'Ô', 'O\u031b': 'Ơ', 'U\u031b': 'Ư',
      'a\u0300': 'à', 'a\u0301': 'á', 'a\u0323': 'ạ', 'a\u0309': 'ả', 'a\u0303': 'ã',
      'â\u0300': 'ầ', 'â\u0301': 'ấ', 'â\u0323': 'ậ', 'â\u0309': 'ẩ', 'â\u0303': 'ẫ',
      'ă\u0300': 'ằ', 'ă\u0301': 'ắ', 'ă\u0323': 'ặ', 'ă\u0309': 'ẳ', 'ă\u0303': 'ẵ',
      'e\u0300': 'è', 'e\u0301': 'é', 'e\u0323': 'ẹ', 'e\u0309': 'ẻ', 'e\u0303': 'ẽ',
      'ê\u0300': 'ề', 'ê\u0301': 'ế', 'ê\u0323': 'ệ', 'ê\u0309': 'ể', 'ê\u0303': 'ễ',
      'o\u0300': 'ò', 'o\u0301': 'ó', 'o\u0323': 'ọ', 'o\u0309': 'ỏ', 'o\u0303': 'õ',
      'ô\u0300': 'ồ', 'ô\u0301': 'ố', 'ô\u0323': 'ộ', 'ô\u0309': 'ổ', 'ô\u0303': 'ỗ',
      'ơ\u0300': 'ờ', 'ơ\u0301': 'ớ', 'ơ\u0323': 'ợ', 'ơ\u0309': 'ở', 'ơ\u0303': 'ỡ',
      'u\u0300': 'ù', 'u\u0301': 'ú', 'u\u0323': 'ụ', 'u\u0309': 'ủ', 'u\u0303': 'ũ',
      'ư\u0300': 'ừ', 'ư\u0301': 'ứ', 'ư\u0323': 'ự', 'ư\u0309': 'ử', 'ư\u0303': 'ữ',
      'i\u0300': 'ì', 'i\u0301': 'í', 'i\u0323': 'ị', 'i\u0309': 'ỉ', 'i\u0303': 'ĩ',
      'y\u0300': 'ỳ', 'y\u0301': 'ý', 'y\u0323': 'ỵ', 'y\u0309': 'ỷ', 'y\u0303': 'ỹ',
      'A\u0300': 'À', 'A\u0301': 'Á', 'A\u0323': 'Ạ', 'A\u0309': 'Ả', 'A\u0303': 'Ã',
      'Â\u0300': 'Ầ', 'Â\u0301': 'Ấ', 'Â\u0323': 'Ậ', 'Â\u0309': 'Ẩ', 'Â\u0303': 'Ẫ',
      'Ă\u0300': 'Ằ', 'Ă\u0301': 'Ắ', 'Ă\u0323': 'Ặ', 'Ă\u0309': 'Ẳ', 'Ă\u0303': 'Ẵ',
      'E\u0300': 'È', 'E\u0301': 'É', 'E\u0323': 'Ẹ', 'E\u0309': 'Ẻ', 'E\u0303': 'Ẽ',
      'Ê\u0300': 'Ề', 'Ê\u0301': 'Ế', 'Ê\u0323': 'Ệ', 'Ê\u0309': 'Ể', 'Ê\u0303': 'Ễ',
      'O\u0300': 'Ò', 'O\u0301': 'Ó', 'O\u0323': 'Ọ', 'O\u0309': 'Ỏ', 'O\u0303': 'Õ',
      'Ô\u0300': 'Ồ', 'Ô\u0301': 'Ố', 'Ô\u0323': 'Ộ', 'Ô\u0309': 'Ổ', 'Ô\u0303': 'Ỗ',
      'Ơ\u0300': 'Ờ', 'Ơ\u0301': 'Ớ', 'Ơ\u0323': 'Ợ', 'Ơ\u0309': 'Ở', 'Ơ\u0303': 'Ỡ',
      'U\u0300': 'Ù', 'U\u0301': 'Ú', 'U\u0323': 'Ụ', 'U\u0309': 'Ủ', 'U\u0303': 'Ũ',
      'Ư\u0300': 'Ừ', 'Ư\u0301': 'Ứ', 'Ư\u0323': 'Ự', 'Ư\u0309': 'Ử', 'Ư\u0303': 'Ữ',
      'I\u0300': 'Ì', 'I\u0301': 'Í', 'I\u0323': 'Ị', 'I\u0309': 'Ỉ', 'I\u0303': 'Ĩ',
      'Y\u0300': 'Ỳ', 'Y\u0301': 'Ý', 'Y\u0323': 'Ỵ', 'Y\u0309': 'Ỷ', 'Y\u0303': 'Ỹ',
    };

    String result = str;
    nfdToNfc.forEach((nfd, nfc) {
      result = result.replaceAll(nfd, nfc);
    });
    return result;
  }

  String _removeDiacritics(String str) {
    str = _toNfc(str);
    str = str.replaceAll(RegExp(r'[\u0300-\u036f]'), '');
    const vietnamese = 'aAeEoOuUiIdDyY';
    final vietnameseRegex = [
      RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'),
      RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'),
      RegExp(r'[èéẹẻẽêềếệểễ]'),
      RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'),
      RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'),
      RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'),
      RegExp(r'[ùúụủũưừứựửữ]'),
      RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'),
      RegExp(r'[ìíịỉĩ]'),
      RegExp(r'[ÌÍỊỈĨ]'),
      RegExp(r'[đ]'),
      RegExp(r'[Đ]'),
      RegExp(r'[ỳýỵỷỹ]'),
      RegExp(r'[ỲÝỴỶỸ]')
    ];

    for (int i = 0; i < vietnameseRegex.length; i++) {
      str = str.replaceAll(vietnameseRegex[i], vietnamese[i]);
    }
    return str;
  }

  static const List<Map<String, dynamic>> _vietnamProvinces = [
    {'name': 'An Giang', 'lat': 10.3759, 'lon': 105.4325, 'admin1': 'Tỉnh'},
    {'name': 'Bà Rịa - Vũng Tàu', 'lat': 10.3460, 'lon': 107.0843, 'admin1': 'Tỉnh'},
    {'name': 'Bắc Giang', 'lat': 21.2731, 'lon': 106.1946, 'admin1': 'Tỉnh'},
    {'name': 'Bắc Kạn', 'lat': 22.1470, 'lon': 105.8368, 'admin1': 'Tỉnh'},
    {'name': 'Bạc Liêu', 'lat': 9.2940, 'lon': 105.7244, 'admin1': 'Tỉnh'},
    {'name': 'Bắc Ninh', 'lat': 21.1861, 'lon': 106.0763, 'admin1': 'Tỉnh'},
    {'name': 'Bến Tre', 'lat': 10.2423, 'lon': 106.3761, 'admin1': 'Tỉnh'},
    {'name': 'Bình Định', 'lat': 13.7830, 'lon': 109.2198, 'admin1': 'Tỉnh'},
    {'name': 'Bình Dương', 'lat': 10.9805, 'lon': 106.6515, 'admin1': 'Tỉnh'},
    {'name': 'Bình Phước', 'lat': 11.5325, 'lon': 106.8839, 'admin1': 'Tỉnh'},
    {'name': 'Bình Thuận', 'lat': 10.9254, 'lon': 108.1042, 'admin1': 'Tỉnh'},
    {'name': 'Cà Mau', 'lat': 9.1769, 'lon': 105.1500, 'admin1': 'Tỉnh'},
    {'name': 'Cần Thơ', 'lat': 10.0452, 'lon': 105.7469, 'admin1': 'Thành phố'},
    {'name': 'Cao Bằng', 'lat': 22.6686, 'lon': 106.2579, 'admin1': 'Tỉnh'},
    {'name': 'Đà Nẵng', 'lat': 16.0544, 'lon': 108.2022, 'admin1': 'Thành phố'},
    {'name': 'Đắk Lắk', 'lat': 12.6860, 'lon': 108.0543, 'admin1': 'Tỉnh'},
    {'name': 'Đắk Nông', 'lat': 12.0078, 'lon': 107.6847, 'admin1': 'Tỉnh'},
    {'name': 'Điện Biên', 'lat': 21.3857, 'lon': 103.0194, 'admin1': 'Tỉnh'},
    {'name': 'Đồng Nai', 'lat': 10.9574, 'lon': 106.8427, 'admin1': 'Tỉnh'},
    {'name': 'Đồng Tháp', 'lat': 10.4578, 'lon': 105.6324, 'admin1': 'Tỉnh'},
    {'name': 'Gia Lai', 'lat': 13.9822, 'lon': 108.0058, 'admin1': 'Tỉnh'},
    {'name': 'Hà Giang', 'lat': 22.8233, 'lon': 104.9836, 'admin1': 'Tỉnh'},
    {'name': 'Hà Nam', 'lat': 20.5408, 'lon': 105.9247, 'admin1': 'Tỉnh'},
    {'name': 'Hà Nội', 'lat': 21.0285, 'lon': 105.8542, 'admin1': 'Thành phố'},
    {'name': 'Hà Tĩnh', 'lat': 18.3429, 'lon': 105.9059, 'admin1': 'Tỉnh'},
    {'name': 'Hải Dương', 'lat': 20.9392, 'lon': 106.3146, 'admin1': 'Tỉnh'},
    {'name': 'Hải Phòng', 'lat': 20.8449, 'lon': 106.6881, 'admin1': 'Thành phố'},
    {'name': 'Hậu Giang', 'lat': 9.7842, 'lon': 105.4701, 'admin1': 'Tỉnh'},
    {'name': 'Hòa Bình', 'lat': 20.8173, 'lon': 105.3376, 'admin1': 'Tỉnh'},
    {'name': 'Hưng Yên', 'lat': 20.6465, 'lon': 106.0511, 'admin1': 'Tỉnh'},
    {'name': 'Khánh Hòa', 'lat': 12.2388, 'lon': 109.1967, 'admin1': 'Tỉnh'},
    {'name': 'Kiên Giang', 'lat': 9.9614, 'lon': 105.0809, 'admin1': 'Tỉnh'},
    {'name': 'Kon Tum', 'lat': 14.3497, 'lon': 107.9899, 'admin1': 'Tỉnh'},
    {'name': 'Lai Châu', 'lat': 22.3959, 'lon': 103.4611, 'admin1': 'Tỉnh'},
    {'name': 'Lâm Đồng', 'lat': 11.9404, 'lon': 108.4583, 'admin1': 'Tỉnh'},
    {'name': 'Lạng Sơn', 'lat': 21.8538, 'lon': 106.7618, 'admin1': 'Tỉnh'},
    {'name': 'Lào Cai', 'lat': 22.4856, 'lon': 103.9707, 'admin1': 'Tỉnh'},
    {'name': 'Long An', 'lat': 10.5338, 'lon': 106.4061, 'admin1': 'Tỉnh'},
    {'name': 'Nam Định', 'lat': 20.4200, 'lon': 106.1683, 'admin1': 'Tỉnh'},
    {'name': 'Nghệ An', 'lat': 18.6734, 'lon': 105.6813, 'admin1': 'Tỉnh'},
    {'name': 'Ninh Bình', 'lat': 20.2506, 'lon': 105.9744, 'admin1': 'Tỉnh'},
    {'name': 'Ninh Thuận', 'lat': 11.5643, 'lon': 108.9904, 'admin1': 'Tỉnh'},
    {'name': 'Phú Thọ', 'lat': 21.3225, 'lon': 105.4019, 'admin1': 'Tỉnh'},
    {'name': 'Phú Yên', 'lat': 13.0882, 'lon': 109.3044, 'admin1': 'Tỉnh'},
    {'name': 'Quảng Bình', 'lat': 17.4722, 'lon': 106.6003, 'admin1': 'Tỉnh'},
    {'name': 'Quảng Nam', 'lat': 15.5681, 'lon': 108.4908, 'admin1': 'Tỉnh'},
    {'name': 'Quảng Ngãi', 'lat': 15.1205, 'lon': 108.8049, 'admin1': 'Tỉnh'},
    {'name': 'Quảng Ninh', 'lat': 20.9599, 'lon': 107.0425, 'admin1': 'Tỉnh'},
    {'name': 'Quảng Trị', 'lat': 16.8173, 'lon': 107.0987, 'admin1': 'Tỉnh'},
    {'name': 'Sóc Trăng', 'lat': 9.5997, 'lon': 105.9723, 'admin1': 'Tỉnh'},
    {'name': 'Sơn La', 'lat': 21.3262, 'lon': 103.9119, 'admin1': 'Tỉnh'},
    {'name': 'Tây Ninh', 'lat': 11.3120, 'lon': 106.0988, 'admin1': 'Tỉnh'},
    {'name': 'Thái Bình', 'lat': 20.4463, 'lon': 106.3364, 'admin1': 'Tỉnh'},
    {'name': 'Thái Nguyên', 'lat': 21.5939, 'lon': 105.8442, 'admin1': 'Tỉnh'},
    {'name': 'Thanh Hóa', 'lat': 19.8067, 'lon': 105.7761, 'admin1': 'Tỉnh'},
    {'name': 'Thừa Thiên Huế', 'lat': 16.4637, 'lon': 107.5908, 'admin1': 'Tỉnh'},
    {'name': 'Tiền Giang', 'lat': 10.3601, 'lon': 106.3648, 'admin1': 'Tỉnh'},
    {'name': 'Hồ Chí Minh', 'lat': 10.8231, 'lon': 106.6297, 'admin1': 'Thành phố'},
    {'name': 'Trà Vinh', 'lat': 9.9360, 'lon': 106.3453, 'admin1': 'Tỉnh'},
    {'name': 'Tuyên Quang', 'lat': 21.8219, 'lon': 105.2158, 'admin1': 'Tỉnh'},
    {'name': 'Vĩnh Long', 'lat': 10.2515, 'lon': 105.9719, 'admin1': 'Tỉnh'},
    {'name': 'Vĩnh Phúc', 'lat': 21.3089, 'lon': 105.6046, 'admin1': 'Tỉnh'},
    {'name': 'Yên Bái', 'lat': 21.7047, 'lon': 104.8742, 'admin1': 'Tỉnh'},
  ];

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

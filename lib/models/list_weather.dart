import 'weather.dart';

/// Câu 4: CLASS - Danh sách Weather với chức năng Create, Edit, Read
class ListWeather {
  List<Weather> weatherList = [];

  /// Create - Tạo và lưu một bản ghi kiểu Weather vào danh sách
  void create(Weather weather) {
    weatherList.add(weather);
  }

  /// Edit - Sửa một bản ghi có id cụ thể
  void edit(String id, Weather newWeather) {
    for (int i = 0; i < weatherList.length; i++) {
      if (weatherList[i].id == id) {
        weatherList[i] = newWeather;
        break;
      }
    }
  }

  /// Read - Đọc tất cả các bản ghi có trong danh sách
  void readAll() {
    for (var weather in weatherList) {
      // ignore: avoid_print
      print(
        'ID: ${weather.id}, Temp: ${weather.temperature}, Humidity: ${weather.humidity}, Wind: ${weather.windSpeed}, Status: ${weather.status}, UV: ${weather.uvIndex}, Icon: ${weather.icon}',
      );
    }
  }
}

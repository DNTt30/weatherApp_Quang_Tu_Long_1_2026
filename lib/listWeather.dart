import 'working.dart';
class ListWeather {
  // Biến lưu trữ danh sách các đối tượng Weather
  List<CityData> _listWeather = [];

  // 1. Create: Thêm một bản ghi mới
  void create(CityData item) {
    _listWeather.add(item);
    print('Đã thêm thành phố: ${item.name}');
  }

  // 2. Read: Đọc tất cả bản ghi
  List<CityData> getAll() {
    return _listWeather;
  }

  // 3. Edit: Sửa bản ghi theo ID
  void edit(String id, String newDesc, double latitude, double longitude) {
    for (var i = 0; i < _listWeather.length; i++) {
      if (_listWeather[i].id == id) {
        _listWeather[i] = CityData(
          id: id,
          name: _listWeather[i].name,
          latitude: latitude,
          longitude: longitude,
          isFavourite: _listWeather[i].isFavourite,
        );
        print('Đã cập nhật thông tin cho ID: $id');
        return;
      }
    }
    print('Không tìm thấy ID: $id');
  }
  

}
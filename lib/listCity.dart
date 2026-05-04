import 'working.dart';

class ListCityData {
  // 01 biến là danh sách của các Tenclass (Câu 4)
  List<CityData> _list = [];

  // Create: Tạo 01 bản ghi và lưu giữ (Câu 4)
  void create(CityData city) {
    _list.add(city);
  }

  // Read: Đọc tất cả các bản ghi (Câu 4)
  List<CityData> readAll() {
    return _list;
  }

  // Edit: Sửa trạng thái yêu thích theo ID cụ thể (Câu 4)
  void edit(String id, bool newStatus) {
    try {
      var city = _list.firstWhere((element) => element.id == id);
      city.isFavourite = newStatus;
    } catch (e) {
      print("Lỗi: Không tìm thấy ID để sửa");
    }
  }
  
  // Khởi tạo dữ liệu mẫu để hiển thị
  void initMockData() {
    create(CityData(id: "1", name: "Hà Nội", latitude: 21.0285, longitude: 105.8542, isFavourite: false));
    create(CityData(id: "2", name: "Hồ Chí Minh", latitude: 10.7626, longitude: 106.6602, isFavourite: false));
    create(CityData(id: "3", name: "Đà Nẵng", latitude: 16.0544, longitude: 108.2022, isFavourite: false));
  }
}
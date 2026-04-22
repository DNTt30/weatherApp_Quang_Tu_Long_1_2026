import 'Forecast.dart';

class ListForecast {
  // 01 biến là danh sách của các đối tượng Forecast
  List<Forecast> forecasts = [];

  // ==========================================
  // 1. CREATE (Tạo): Thêm 01 bản ghi Forecast vào danh sách
  // ==========================================
  void createForecast(Forecast newForecast) {
    forecasts.add(newForecast);
    print(">> [CREATE] Đã tạo thành công bản tin dự báo cho ngày: ${newForecast.dateTime}");
  }

  // ==========================================
  // 2. READ (Đọc): Đọc tất cả các bản ghi có trong danh sách
  // ==========================================
  void readAllForecasts() {
    print("\n=== DANH SÁCH BẢN TIN DỰ BÁO THỜI TIẾT ===");
    if (forecasts.isEmpty) {
      print("Danh sách hiện đang trống!");
      return;
    }
    for (var forecast in forecasts) {
      forecast.displayForecastInfo();
      print("------------------------------------------");
    }
  }

  // ==========================================
  // 3. EDIT (Sửa): Sửa 01 bản ghi có id cụ thể
  // ==========================================
  void editForecast(String targetId, String newDateTime, double newMinTemp, double newMaxTemp, int newRainProb) {
    // Tìm vị trí của bản ghi có id trùng khớp trong danh sách
    int index = forecasts.indexWhere((f) => f.id == targetId);

    if (index != -1) {
      // Nếu tìm thấy, thực hiện cập nhật lại dữ liệu
      forecasts[index].dateTime = newDateTime;
      forecasts[index].minTemp = newMinTemp;
      forecasts[index].maxTemp = newMaxTemp;
      forecasts[index].rainProbability = newRainProb;
      print(">> [EDIT] Đã cập nhật thành công bản tin dự báo có ID: $targetId");
    } else {
      print(">> [LỖI] Không tìm thấy bản tin dự báo nào có ID: $targetId để sửa!");
    }
  }
}

// ==========================================
// HÀM MAIN ĐỂ CHẠY THỬ (TEST CRUD)
// ==========================================
void main() {
  // Khởi tạo đối tượng quản lý danh sách
  ListForecast forecastManager = ListForecast();

  // 1. Thực hiện CREATE (Tạo mới)
  forecastManager.createForecast(Forecast(
    id: "f1", 
    dateTime: "Hôm nay (22/04)", 
    minTemp: 25.0, 
    maxTemp: 32.0, 
    rainProbability: 20
  ));
  
  forecastManager.createForecast(Forecast(
    id: "f2", 
    dateTime: "Ngày mai (23/04)", 
    minTemp: 24.5, 
    maxTemp: 30.0, 
    rainProbability: 85
  ));

  // 2. Thực hiện READ (Đọc danh sách ban đầu)
  forecastManager.readAllForecasts();

  // 3. Thực hiện EDIT (Sửa bản ghi có id là "f2" vì thời tiết thay đổi đột ngột)
  print("\n...Hệ thống nhận dữ liệu mới, tiến hành cập nhật bản tin f2...");
  forecastManager.editForecast("f2", "Ngày mai (23/04)", 22.0, 28.0, 100);

  // 4. Thực hiện READ (Đọc lại danh sách sau khi sửa)
  forecastManager.readAllForecasts();
}
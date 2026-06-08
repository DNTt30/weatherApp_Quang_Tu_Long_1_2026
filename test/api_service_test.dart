import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/service/api_service.dart';

void main() {
  group('ApiService Autocomplete & Normalization Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('TC-26: geocodeSuggestions trả về danh sách trống khi query ngắn hơn 2 ký tự', () async {
      final results = await apiService.geocodeSuggestions('h');
      expect(results, isEmpty);
    });

    test('TC-27: geocodeSuggestions nhận diện và chuẩn hóa tiếng Việt dạng tổ hợp (NFD)', () async {
      // Chuỗi "hà nam" dạng tổ hợp NFD
      final String nfdQuery = 'h' + 'a' + '\u0300' + ' ' + 'n' + 'a' + 'm';
      
      final results = await apiService.geocodeSuggestions(nfdQuery);
      
      expect(results, isNotEmpty);
      // Kết quả đầu tiên phải là tỉnh Hà Nam
      expect(results.first['name'], equals('Hà Nam'));
      expect(results.first['admin1'], equals('Tỉnh'));
    });

    test('TC-28: geocodeSuggestions sắp xếp độ ưu tiên chuẩn xác (exact -> startsWith -> contains)', () async {
      // Từ khóa "Nam"
      final String query = 'Nam';
      final results = await apiService.geocodeSuggestions(query);
      
      expect(results, isNotEmpty);
      
      // Tìm vị trí của "Nam Định" (bắt đầu bằng "Nam" -> startsWith)
      final int indexNamDinh = results.indexWhere((element) => element['name'] == 'Nam Định');
      
      // Tìm vị trí của "Quảng Nam" (chứa "Nam" -> contains)
      final int indexQuangNam = results.indexWhere((element) => element['name'] == 'Quảng Nam');
      
      // Nam Định phải đứng trước Quảng Nam
      if (indexNamDinh != -1 && indexQuangNam != -1) {
        expect(indexNamDinh, lessThan(indexQuangNam));
      }
    });

    test('TC-29: geocodeSuggestions lọc trùng lặp tỉnh thành sử dụng chuẩn hóa NFC', () async {
      final String query = 'hà nam';
      final results = await apiService.geocodeSuggestions(query);
      
      // Chỉ được tồn tại duy nhất 1 kết quả có tên là "Hà Nam"
      final int countHaNam = results.where((element) => element['name'] == 'Hà Nam').length;
      expect(countHaNam, equals(1));
    });
  });
}

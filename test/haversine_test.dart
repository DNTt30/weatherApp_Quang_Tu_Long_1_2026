// ============================================================
// UNIT TESTS — Thuật toán Haversine (calculateDistance)
// Kiểm thử: Tính khoảng cách địa lý giữa hai điểm tọa độ
// Chạy: flutter test test/haversine_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/service/weather_data_manager.dart';

void main() {
  late WeatherDataManager manager;

  setUp(() {
    manager = WeatherDataManager();
  });

  group('Haversine - calculateDistance() Tests', () {
    // TC-30: Cùng một điểm tọa độ → khoảng cách = 0
    test('TC-30: Khoảng cách giữa cùng một điểm phải bằng 0', () {
      final dist = manager.calculateDistance(21.0285, 105.8542, 21.0285, 105.8542);
      expect(dist, closeTo(0.0, 0.001));
    });

    // TC-31: Hà Nội → Hồ Chí Minh ≈ 1137 km (thực tế đường thẳng)
    test('TC-31: Khoảng cách Hà Nội → Hồ Chí Minh xấp xỉ 1137 km', () {
      // Hà Nội: 21.0285°N, 105.8542°E
      // Hồ Chí Minh: 10.8231°N, 106.6297°E
      final dist = manager.calculateDistance(21.0285, 105.8542, 10.8231, 106.6297);
      expect(dist, closeTo(1137.0, 20.0)); // sai số chấp nhận ±20 km
    });

    // TC-32: Hà Nội → Đà Nẵng ≈ 606 km (đường thẳng theo Haversine)
    test('TC-32: Khoảng cách Hà Nội → Đà Nẵng xấp xỉ 606 km', () {
      // Đà Nẵng: 16.0544°N, 108.2022°E
      final dist = manager.calculateDistance(21.0285, 105.8542, 16.0544, 108.2022);
      expect(dist, closeTo(606.0, 20.0));
    });

    // TC-33: Kết quả phải đối xứng (A→B = B→A)
    test('TC-33: Công thức đối xứng — calculateDistance(A,B) == calculateDistance(B,A)', () {
      final distAB = manager.calculateDistance(21.0285, 105.8542, 10.8231, 106.6297);
      final distBA = manager.calculateDistance(10.8231, 106.6297, 21.0285, 105.8542);
      expect(distAB, closeTo(distBA, 0.001));
    });

    // TC-34: Khoảng cách luôn dương (không âm)
    test('TC-34: Khoảng cách luôn là số không âm', () {
      final dist = manager.calculateDistance(16.0544, 108.2022, 10.0452, 105.7469);
      expect(dist, greaterThanOrEqualTo(0.0));
    });

    // TC-35: Đà Nẵng → Cần Thơ ≈ 719 km (đường thẳng theo Haversine)
    test('TC-35: Khoảng cách Đà Nẵng → Cần Thơ xấp xỉ 719 km', () {
      // Cần Thơ: 10.0452°N, 105.7469°E
      final dist = manager.calculateDistance(16.0544, 108.2022, 10.0452, 105.7469);
      expect(dist, closeTo(719.0, 20.0));
    });

    // TC-36: Hai thành phố gần nhau có khoảng cách < 200 km (Hà Nội → Hải Phòng ≈ 103 km)
    test('TC-36: Hà Nội → Hải Phòng xấp xỉ 103 km (thành phố lân cận)', () {
      // Hải Phòng: 20.8449°N, 106.6881°E
      final dist = manager.calculateDistance(21.0285, 105.8542, 20.8449, 106.6881);
      expect(dist, closeTo(103.0, 15.0));
    });
  });
}

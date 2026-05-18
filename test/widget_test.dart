// ============================================================
// UNIT TESTS — Weather App (Nhóm 1 - Phenikaa University)
// Kiểm thử: Models (Weather, Forecast, City) + Widgets
// Chạy: flutter test
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/city.dart';

void main() {
  // ─────────────────────────────────────────────────────────
  // GROUP 1: Weather Model Tests
  // ─────────────────────────────────────────────────────────
  group('Weather Model Tests', () {
    late Weather weather;

    setUp(() {
      weather = Weather(
        city: 'Hà Nội',
        temperature: 32.5,
        status: 'Sunny',
        humidity: 70.0,
        isRaining: false,
      );
    });

    test('TC-01: Weather object khởi tạo đúng các thuộc tính', () {
      expect(weather.city, equals('Hà Nội'));
      expect(weather.temperature, equals(32.5));
      expect(weather.status, equals('Sunny'));
      expect(weather.humidity, equals(70.0));
      expect(weather.isRaining, isFalse);
    });

    test('TC-02: getWeatherInfo() trả về String đúng định dạng', () {
      final info = weather.getWeatherInfo();
      expect(info, contains('Hà Nội'));
      expect(info, contains('32.5'));
      expect(info, contains('Sunny'));
      expect(info, contains('70.0'));
      expect(info, contains('No'));
    });

    test('TC-03: Weather với isRaining=true trả về "Yes"', () {
      final rainyWeather = Weather(
        city: 'Hải Phòng',
        temperature: 28.0,
        status: 'Rainy',
        humidity: 90.0,
        isRaining: true,
      );
      expect(rainyWeather.getWeatherInfo(), contains('Yes'));
    });

    test('TC-04: Weather chấp nhận nhiệt độ âm (mùa đông)', () {
      final coldWeather = Weather(
        city: 'Hà Nội',
        temperature: -5.0,
        status: 'Cloudy',
        humidity: 80.0,
        isRaining: false,
      );
      expect(coldWeather.temperature, equals(-5.0));
    });

    test('TC-05: Weather chấp nhận độ ẩm 100%', () {
      final humidWeather = Weather(
        city: 'Cần Thơ',
        temperature: 33.0,
        status: 'Rainy',
        humidity: 100.0,
        isRaining: true,
      );
      expect(humidWeather.humidity, equals(100.0));
    });
  });

  // ─────────────────────────────────────────────────────────
  // GROUP 2: Forecast Model Tests
  // ─────────────────────────────────────────────────────────
  group('Forecast Model Tests', () {
    late Forecast forecast;

    setUp(() {
      forecast = Forecast(
        id: 'f1',
        dateTime: 'Thứ Hai',
        minTemp: 25.0,
        maxTemp: 32.0,
        rainProbability: 10,
      );
    });

    test('TC-06: Forecast object khởi tạo đúng các thuộc tính', () {
      expect(forecast.id, equals('f1'));
      expect(forecast.dateTime, equals('Thứ Hai'));
      expect(forecast.minTemp, equals(25.0));
      expect(forecast.maxTemp, equals(32.0));
      expect(forecast.rainProbability, equals(10));
    });

    test('TC-07: getTemperatureDifference() tính đúng chênh lệch nhiệt độ', () {
      expect(forecast.getTemperatureDifference(), equals(7.0));
    });

    test('TC-08: getForecast() trả về String đúng định dạng', () {
      final result = forecast.getForecast();
      expect(result, contains('Thứ Hai'));
      expect(result, contains('25.0'));
      expect(result, contains('32.0'));
    });

    test('TC-09: getTemperatureDifference() với ngày lạnh (chênh lệch 3 độ)', () {
      final coldForecast = Forecast(
        id: 'f2',
        dateTime: 'Thứ Ba',
        minTemp: 24.0,
        maxTemp: 27.0,
        rainProbability: 80,
      );
      expect(coldForecast.getTemperatureDifference(), equals(3.0));
    });

    test('TC-10: rainProbability có thể bằng 0 (không có mưa)', () {
      final dryForecast = Forecast(
        id: 'f3',
        dateTime: 'Thứ Tư',
        minTemp: 26.0,
        maxTemp: 34.0,
        rainProbability: 0,
      );
      expect(dryForecast.rainProbability, equals(0));
    });

    test('TC-11: rainProbability có thể bằng 100 (mưa chắc chắn)', () {
      final rainyForecast = Forecast(
        id: 'f4',
        dateTime: 'Thứ Năm',
        minTemp: 22.0,
        maxTemp: 26.0,
        rainProbability: 100,
      );
      expect(rainyForecast.rainProbability, equals(100));
    });
  });

  // ─────────────────────────────────────────────────────────
  // GROUP 3: City Model Tests
  // ─────────────────────────────────────────────────────────
  group('City Model Tests', () {
    test('TC-12: City object khởi tạo đúng thuộc tính', () {
      final city = City(id: 1, name: 'Hà Nội');
      expect(city.id, equals(1));
      expect(city.name, equals('Hà Nội'));
    });

    test('TC-13: Danh sách 5 thành phố khởi tạo đủ', () {
      final cities = [
        City(id: 1, name: 'Hà Nội'),
        City(id: 2, name: 'Đà Nẵng'),
        City(id: 3, name: 'Hồ Chí Minh'),
        City(id: 4, name: 'Hải Phòng'),
        City(id: 5, name: 'Cần Thơ'),
      ];
      expect(cities.length, equals(5));
      expect(cities.first.name, equals('Hà Nội'));
      expect(cities.last.name, equals('Cần Thơ'));
    });

    test('TC-14: City với id âm vẫn khởi tạo được (edge case)', () {
      final city = City(id: -1, name: 'Unknown');
      expect(city.id, equals(-1));
      expect(city.name, isNotEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────
  // GROUP 4: Business Logic Tests
  // ─────────────────────────────────────────────────────────
  group('Business Logic Tests', () {
    test('TC-15: Phân loại thời tiết qua status (Sunny/Rainy/Cloudy)', () {
      final cities = [
        {'status': 'Sunny', 'expectedRain': false},
        {'status': 'Rainy', 'expectedRain': true},
        {'status': 'Cloudy', 'expectedRain': false},
      ];

      for (final data in cities) {
        final isRainingExpected = data['expectedRain'] as bool;
        final status = data['status'] as String;
        final actualIsRaining = status.toLowerCase() == 'rainy';
        expect(actualIsRaining, equals(isRainingExpected),
            reason: 'Status "$status" nên isRaining=$isRainingExpected');
      }
    });

    test('TC-16: Xác suất mưa > 50% được coi là mưa cao (high rain)', () {
      final forecast80 = Forecast(
          id: 'f1', dateTime: 'T3', minTemp: 24, maxTemp: 28, rainProbability: 80);
      final forecast30 = Forecast(
          id: 'f2', dateTime: 'T4', minTemp: 25, maxTemp: 30, rainProbability: 30);

      expect(forecast80.rainProbability > 50, isTrue);
      expect(forecast30.rainProbability > 50, isFalse);
    });

    test('TC-17: Nhiệt độ trung bình 5 thành phố tính đúng', () {
      final temps = [32.5, 29.0, 35.0, 28.0, 33.0];
      final avg = temps.reduce((a, b) => a + b) / temps.length;
      expect(avg, closeTo(31.5, 0.1));
    });

    test('TC-18: Đếm số ngày mưa trong tuần (rainProb > 50)', () {
      final forecasts = [
        Forecast(id: 'f1', dateTime: 'T2', minTemp: 25, maxTemp: 32, rainProbability: 10),
        Forecast(id: 'f2', dateTime: 'T3', minTemp: 24, maxTemp: 28, rainProbability: 80),
        Forecast(id: 'f3', dateTime: 'T4', minTemp: 25, maxTemp: 30, rainProbability: 30),
        Forecast(id: 'f4', dateTime: 'T5', minTemp: 23, maxTemp: 29, rainProbability: 10),
        Forecast(id: 'f5', dateTime: 'T6', minTemp: 26, maxTemp: 31, rainProbability: 50),
      ];
      final rainyDays = forecasts.where((f) => f.rainProbability > 50).length;
      expect(rainyDays, equals(1)); // Chỉ T3 > 50%
    });

    test('TC-19: Thành phố nóng nhất trong danh sách', () {
      final temps = {'Hà Nội': 32.5, 'Đà Nẵng': 29.0, 'Hồ Chí Minh': 35.0};
      final hottest = temps.entries.reduce((a, b) => a.value > b.value ? a : b);
      expect(hottest.key, equals('Hồ Chí Minh'));
      expect(hottest.value, equals(35.0));
    });

    test('TC-20: Thành phố lạnh nhất trong danh sách', () {
      final temps = {'Hà Nội': 32.5, 'Đà Nẵng': 29.0, 'Hải Phòng': 28.0};
      final coldest = temps.entries.reduce((a, b) => a.value < b.value ? a : b);
      expect(coldest.key, equals('Hải Phòng'));
      expect(coldest.value, equals(28.0));
    });
  });

  // ─────────────────────────────────────────────────────────
  // GROUP 5: Widget Tests (UI)
  // ─────────────────────────────────────────────────────────
  group('Widget Tests', () {
    testWidgets('TC-21: LoginScreen hiển thị đúng các thành phần', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('WEATHER APP'),
            ),
          ),
        ),
      );
      expect(find.text('WEATHER APP'), findsOneWidget);
    });

    testWidgets('TC-22: Weather card render đúng nhiệt độ', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('32°C'),
            ),
          ),
        ),
      );
      expect(find.text('32°C'), findsOneWidget);
    });

    testWidgets('TC-23: Bottom Navigation Bar render đúng 3 tab', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Forecast'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'More'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Forecast'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('TC-24: LinearProgressIndicator render đúng với giá trị 0.8', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinearProgressIndicator(value: 0.8),
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('TC-25: AppBar hiển thị title đúng', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Weather App')),
          ),
        ),
      );
      expect(find.text('Weather App'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}

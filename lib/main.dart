import 'package:flutter/material.dart';

// --- 4. Tạo đối tượng (Class) tương ứng với Project ---
class WeatherData {
  final String time;
  final String status;
  final int temp;

  WeatherData({required this.time, required this.status, required this.temp});
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WeatherForecast(),
  ));
}

class WeatherForecast extends StatelessWidget {
  const WeatherForecast({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 1. Sử dụng các biến đơn ---
    String location = "Hà Nội";
    String date = "2026-04-15";

    // --- 2. Sử dụng Collections (List & Map) ---
    // Map lưu thông số phụ
    Map<String, String> details = {
      "Độ ẩm": "70%",
      "Gió": "10km/h"
    };

    // --- 4. Tạo List tương ứng với đối tượng WeatherData ---
    List<WeatherData> listData = [
      WeatherData(time: "08:00", status: "Sunny", temp: 28),
      WeatherData(time: "12:00", status: "Hot", temp: 34),
      WeatherData(time: "16:00", status: "Cloudy", temp: 30),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị biến đơn
            Text("Khu vực: $location"),
            Text("Thời điểm: $date"),
            const SizedBox(height: 20),

            // --- 3. Hiển thị dữ liệu từ Collections (List Đối tượng) theo dạng Hàng (Row) ---
            const Text("Dự báo sắp tới:"),
            Row(
              children: listData.map((item) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(item.time),
                      Text(item.status),
                      Text("${item.temp}°C"),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Hiển thị dữ liệu từ Map (Sử dụng Text đơn giản)
            const Text("Chi Tiết:"),
            Column(
              children: details.entries.map((e) {
                return Text("${e.key}: ${e.value}");
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
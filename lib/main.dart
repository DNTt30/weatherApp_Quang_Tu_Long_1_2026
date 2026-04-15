import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
// Student: Dương Ngọc Tú
// Assignment: Bài thực hành số 2 - Flutter Variables & Collections
class MyApp extends StatelessWidget {

  // =========================
  //  YÊU CẦU 1: SỬ DỤNG BIẾN
  // =========================
  String city = "Ha Noi";
  double temperature = 32.5;
  String weatherStatus = "Sunny";
  int humidity = 70;
  bool isRaining = false;

  // =========================
  //  YÊU CẦU 2: COLLECTIONS
  // =========================

  // List đơn giản
  List<String> weeklyForecast = [
    "Monday - Sunny",
    "Tuesday - Rainy",
    "Wednesday - Cloudy",
    "Thursday - Sunny",
    "Friday - Storm"
  ];

  // Map
  Map<String, dynamic> weatherData = {
    "city": "Ha Noi",
    "temperature": 32,
    "humidity": 70,
    "status": "Sunny"
  };

  // List<Map> (nâng cao)
  List<Map<String, dynamic>> forecastList = [
    {"day": "Mon", "temp": 32},
    {"day": "Tue", "temp": 28},
    {"day": "Wed", "temp": 30},
    {"day": "Thu", "temp": 33},
    {"day": "Fri", "temp": 29},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Weather App")),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            //  YÊU CẦU 3: HIỂN THỊ BIẾN
            // =========================
            Text("City: $city"),
            Text("Temperature: $temperature°C"),
            Text("Status: $weatherStatus"),
            Text("Humidity: $humidity%"),
            Text("Is Raining: $isRaining"),

            SizedBox(height: 20),

            // =========================
            //  YÊU CẦU 3: HIỂN THỊ COLLECTION
            // =========================
            Text("Weekly Forecast:"),

            Column(
              children: forecastList.map((item) {

                // =========================
                // HIỂN THỊ DẠNG ROW (THEO YÊU CẦU)
                // =========================
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item["day"]),
                    Text("${item["temp"]}°C"),
                  ],
                );

              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
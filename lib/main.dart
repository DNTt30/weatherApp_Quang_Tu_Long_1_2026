import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // =========================
  // ✅ YÊU CẦU 1: BIẾN
  // =========================
  String city = "Ha Noi";
  double temperature = 32.5;
  String weatherStatus = "Sunny";
  int humidity = 70;
  bool isRaining = false;

  // =========================
  // ✅ YÊU CẦU 2: COLLECTIONS
  // =========================

  // List đơn giản
  List<String> weeklyForecast = [
    "Monday - Sunny",
    "Tuesday - Rainy",
    "Wednesday - Cloudy",
  ];

  // Map
  Map<String, dynamic> weatherData = {
    "city": "Ha Noi",
    "temperature": 32,
    "humidity": 70,
    "status": "Sunny"
  };

  // =========================
  // ✅ YÊU CẦU 4: LIST OBJECT
  // =========================
  // Đối tượng Weather Location (id, name)
  List<Map<String, dynamic>> listCity = [
    {'id': 1, 'name': 'Ha Noi'},
    {'id': 2, 'name': 'Da Nang'},
    {'id': 3, 'name': 'Ho Chi Minh'},
  ];

  // Forecast nâng cao
  List<Map<String, dynamic>> forecastList = [
    {"day": "Mon", "temp": 32},
    {"day": "Tue", "temp": 28},
    {"day": "Wed", "temp": 30},
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
            // ✅ YÊU CẦU 3: HIỂN THỊ BIẾN
            // =========================
            Text("City: $city"),
            Text("Temperature: $temperature°C"),
            Text("Status: $weatherStatus"),
            Text("Humidity: $humidity%"),
            Text("Is Raining: $isRaining"),

            SizedBox(height: 20),

            // =========================
            // ✅ HIỂN THỊ COLLECTION
            // =========================
            Text("Forecast:"),

            Column(
              children: forecastList.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item["day"]),
                    Text("${item["temp"]}°C"),
                  ],
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // =========================
            // ✅ YÊU CẦU 4: HIỂN THỊ LIST OBJECT
            // =========================
            Text("City List:"),

            Column(
              children: listCity.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ID: ${item["id"]}"),
                    Text(item["name"]),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
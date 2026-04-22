import 'package:flutter/material.dart';

import '../models/city.dart';
import '../models/forecast.dart';
import '../models/weather.dart';
import '../widgets/app_drawer.dart';

// Widget trang chủ với Stateful
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // YÊU CẦU 1: Khai báo biến (String, int, double, bool)
  late String id;
  late double temperature;
  late int humidity;
  late double windSpeed;
  late String weatherStatus;
  late double uvIndex;
  late String icon;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị biến
    id = "w1";
    temperature = 32.5;
    humidity = 70;
    windSpeed = 12.0;
    weatherStatus = "Sunny";
    uvIndex = 8.5;
    icon = "01d";
  }

  @override
  Widget build(BuildContext context) {
    // YÊU CẦU 2: COLLECTIONS - List<String>
    List<String> weeklyForecast = [
      "Monday - Sunny",
      "Tuesday - Rainy",
      "Wednesday - Cloudy",
      "Thursday - Sunny",
      "Friday - Cloudy",
    ];

    // YÊU CẦU 2: Collections - Map
    Map<String, dynamic> weatherData = {
      "id": id,
      "temperature": temperature,
      "humidity": humidity,
      "status": weatherStatus,
      "windSpeed": windSpeed,
      "uvIndex": uvIndex,
    };

    // YÊU CẦU 2: Collections - List<Map> (Forecast List)
    List<Map<String, dynamic>> forecastList = [
      {"day": "Mon", "temp": 32},
      {"day": "Tue", "temp": 28},
      {"day": "Wed", "temp": 30},
      {"day": "Thu", "temp": 29},
      {"day": "Fri", "temp": 31},
    ];

    // YÊU CẦU 4: List<Map> - Danh sách thành phố (id, name)
    List<Map<String, dynamic>> listCity = [
      {'id': 1, 'name': 'Ha Noi'},
      {'id': 2, 'name': 'Da Nang'},
      {'id': 3, 'name': 'Ho Chi Minh'},
      {'id': 4, 'name': 'Hai Phong'},
      {'id': 5, 'name': 'Can Tho'},
    ];

    // Tạo đối tượng Weather
    Weather currentWeather = Weather(
      id: id,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      status: weatherStatus,
      uvIndex: uvIndex,
      icon: icon,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Weather App"), elevation: 0),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YÊU CẦU 3: Hiển thị dữ liệu bằng Widget - Thông tin thời tiết
            _buildWeatherHeader(currentWeather),
            const SizedBox(height: 16),

            // YÊU CẦU 2: Hiển thị List<String> (Weekly Forecast)
            _buildWeeklyForecast(weeklyForecast),
            const SizedBox(height: 16),

            // YÊU CẦU 2: Hiển thị List<Map> (Forecast Details)
            _buildDetailedForecast(forecastList),
            const SizedBox(height: 16),

            // YÊU CẦU 4: Danh sách City hiển thị dạng Row
            _buildCityList(listCity),
            const SizedBox(height: 16),

            // YÊU CẦU 2: Hiển thị Map weatherData
            _buildWeatherData(weatherData),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thông tin thời tiết chính
  Widget _buildWeatherHeader(Weather currentWeather) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.blue.shade400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ID: ${currentWeather.id}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Temperature: ${currentWeather.formatTemperature()}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Status: ${currentWeather.status}",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            "Humidity: ${currentWeather.humidity}%",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          Text(
            "Wind Speed: ${currentWeather.windSpeed} km/h",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          Text(
            "UV Index: ${currentWeather.uvIndex}",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            currentWeather.evaluateDangerLevel(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị dự báo hàng tuần
  Widget _buildWeeklyForecast(List<String> weeklyForecast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "5-Day Forecast",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                weeklyForecast.length,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    weeklyForecast[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị dự báo chi tiết
  Widget _buildDetailedForecast(List<Map<String, dynamic>> forecastList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detailed Forecast",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(forecastList.length, (index) {
              Map<String, dynamic> forecast = forecastList[index];
              Forecast forecastObj = Forecast(
                day: forecast['day'],
                temp: forecast['temp'].toDouble(),
              );
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(forecastObj.getForecast()),
                    Text(
                      "Sunny",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách thành phố
  Widget _buildCityList(List<Map<String, dynamic>> listCity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Cities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(listCity.length, (index) {
                Map<String, dynamic> cityData = listCity[index];
                City cityObj = City(id: cityData['id'], name: cityData['name']);
                return Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        cityObj.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ID: ${cityObj.id}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị dữ liệu thời tiết (Map)
  Widget _buildWeatherData(Map<String, dynamic> weatherData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weather Data (Map)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: weatherData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

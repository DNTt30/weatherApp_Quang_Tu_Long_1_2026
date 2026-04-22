import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../widgets/app_drawer.dart';

// Widget trang chủ với Stateful
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // YÊU CẦU 1: Khai báo biến (String, int, double, bool)
  late String city;
  late double temperature;
  late String weatherStatus;
  late double humidity;
  late bool isRaining;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị biến
    city = "Ha Noi";
    temperature = 32.5;
    weatherStatus = "Sunny";
    humidity = 70.0;
    isRaining = false;
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
      "city": city,
      "temperature": temperature,
      "humidity": humidity,
      "status": weatherStatus,
      "isRaining": isRaining,
    };

    // YÊU CẦU 2: Collections - List<Map> (Forecast List)
    // DỮ LIỆU MỚI: Khớp với các biến của model Forecast
    List<Map<String, dynamic>> forecastList = [
      {"id": "f1", "dateTime": "Mon", "minTemp": 25.0, "maxTemp": 32.0, "rainProb": 10},
      {"id": "f2", "dateTime": "Tue", "minTemp": 24.0, "maxTemp": 28.0, "rainProb": 80},
      {"id": "f3", "dateTime": "Wed", "minTemp": 25.0, "maxTemp": 30.0, "rainProb": 30},
      {"id": "f4", "dateTime": "Thu", "minTemp": 23.0, "maxTemp": 29.0, "rainProb": 10},
      {"id": "f5", "dateTime": "Fri", "minTemp": 26.0, "maxTemp": 31.0, "rainProb": 50},
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
      city: city,
      temperature: temperature,
      status: weatherStatus,
      humidity: humidity,
      isRaining: isRaining,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        elevation: 0,
      ),
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
            "City: $city",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Temperature: ${temperature.toStringAsFixed(1)}°C",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Status: $weatherStatus",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            "Humidity: ${humidity.toStringAsFixed(0)}%",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          Text(
            "Is Raining: $isRaining",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            currentWeather.getWeatherInfo(),
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

  // Widget hiển thị dự báo chi tiết (Đã sửa lỗi)
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
            children: List.generate(
              forecastList.length,
              (index) {
                Map<String, dynamic> forecast = forecastList[index];

                // TRUYỀN BIẾN MỚI: Khớp hoàn toàn với Constructor của Forecast.dart
                Forecast forecastObj = Forecast(
                  id: forecast['id'],
                  dateTime: forecast['dateTime'],
                  minTemp: forecast['minTemp'].toDouble(),
                  maxTemp: forecast['maxTemp'].toDouble(),
                  rainProbability: forecast['rainProb'],
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
                      // IN DỮ LIỆU MỚI THAY VÌ DÙNG getForecast()
                      Text(
                        '${forecastObj.dateTime}:  ${forecastObj.minTemp}°C - ${forecastObj.maxTemp}°C',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Mưa: ${forecastObj.rainProbability}%",
                        style: TextStyle(
                            color: forecastObj.rainProbability > 50
                                ? Colors.blue
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
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
              children: List.generate(
                listCity.length,
                (index) {
                  Map<String, dynamic> cityData = listCity[index];
                  City cityObj =
                      City(id: cityData['id'], name: cityData['name']);
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
                },
              ),
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

import 'package:flutter/material.dart';
import 'working.dart';
import 'listCity.dart';

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
    // Khởi tạo trình quản lý dữ liệu (Câu 4)
    final manager = ListCityData();
    manager.initMockData(); // Tạo dữ liệu mẫu
    
    // Read: Lấy danh sách để hiển thị (Câu 4)
    List<CityData> listData = manager.readAll();

    return Scaffold(
      appBar: AppBar(title: const Text("Dự báo thời tiết")),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Danh sách thành phố:", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            // Sử dụng ListView.builder để tối ưu hiệu năng hiển thị (Chương 3)
            Expanded(
              child: ListView.builder(
                itemCount: listData.length,
                itemBuilder: (context, index) {
                  final item = listData[index];
                  return ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.blue),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Tọa độ: ${item.latitude}, ${item.longitude}"),
                    trailing: Icon(
                      item.isFavourite ? Icons.favorite : Icons.favorite_border,
                      color: item.isFavourite ? Colors.red : null,
                    ),
                    onTap: () => item.displayLocation(), // Gọi phương thức hoạt động (Câu 3)
                  );
                },
              ),
            ),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Thông tin ứng dụng:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            // Hiển thị Map dữ liệu từ file working.dart
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              //  children: details.entries.map((e) => Text("${e.key}: ${e.value}")).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
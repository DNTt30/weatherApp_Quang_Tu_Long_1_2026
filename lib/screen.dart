import 'package:flutter/material.dart';
import 'forecast.dart';
import 'more.dart';
import 'working.dart';
import 'listCity.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    ContentTab(),
    MoreTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        leading: const Icon(Icons.wb_sunny),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Phenikaa University',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Ngô Thành Long - 23010032',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_copy),
            label: 'Forecast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo trình quản lý dữ liệu
    final manager = ListCityData();
    manager.initMockData(); // Tạo dữ liệu mẫu
    
    // Read: Lấy danh sách để hiển thị
    List<CityData> listData = manager.readAll();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
            // Header: Thành phố hiện tại
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    listData.isNotEmpty ? listData[0].name : "Hà Nội",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Vị trí hiện tại',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Phần giữa: Nhiệt độ hiện tại
            SizedBox(
              height: 220,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wb_sunny, size: 80, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    '28',
                    style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '°C',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trời nắng',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Thông tin chi tiết thời tiết
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: const [
                      Icon(Icons.cloud, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Mây', style: TextStyle(fontSize: 12)),
                      Text('30%', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(Icons.opacity, color: Colors.lightBlue),
                      SizedBox(height: 8),
                      Text('Độ ẩm', style: TextStyle(fontSize: 12)),
                      Text('65%', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(Icons.air, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Gió', style: TextStyle(fontSize: 12)),
                      Text('12 km/h', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Danh sách thành phố lớn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Danh sách thành phố",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: listData.length,
                      itemBuilder: (context, index) {
                        final item = listData[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.location_city, color: Colors.blue),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${item.latitude}, ${item.longitude}"),
                            trailing: Icon(
                              item.isFavourite ? Icons.favorite : Icons.favorite_border,
                              color: item.isFavourite ? Colors.red : null,
                            ),
                            onTap: () => item.displayLocation(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      }
    }

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoreScreen();
  }
}

class ContentTab extends StatelessWidget {
  const ContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ForecastScreen();
  }
}

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('About Tab'),
    );
  }
}
import 'package:flutter/material.dart';

// 1. Viết một class Generics cho tất cả các đối tượng, có phương thức CRUD tổng quát.
abstract class BaseModel {
  String get id;
  set id(String value);
}

class GenericRepository<T extends BaseModel> {
  final List<T> _items = [];

  // Create
  void create(T item) {
    _items.add(item);
  }

  // Read all
  List<T> readAll() {
    return List.unmodifiable(_items);
  }

  // Read by Id
  T? readById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update
  bool update(String id, T newItem) {
    int index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = newItem;
      return true;
    }
    return false;
  }

  // Delete
  bool delete(String id) {
    int initialLength = _items.length;
    _items.removeWhere((item) => item.id == id);
    return _items.length < initialLength;
  }
}

// 2. Thực hiện 02 đối tượng MỚI kế thừa từ (1).

// Đối tượng 1: WeatherAlert
class WeatherAlert implements BaseModel {
  @override
  String id;
  String title;
  int severity; // 1: Low, 2: Medium, 3: High
  bool isActive;

  WeatherAlert({
    required this.id,
    required this.title,
    required this.severity,
    this.isActive = true,
  });
}

class WeatherAlertRepository extends GenericRepository<WeatherAlert> {
  // Phương thức hoạt động khác nhau, trả về kết quả khác nhau
  List<WeatherAlert> getActiveCriticalAlerts() {
    return readAll().where((alert) => alert.isActive && alert.severity >= 3).toList();
  }
}

// Đối tượng 2: WeatherStation
class WeatherStation implements BaseModel {
  @override
  String id;
  String name;
  double latitude;
  double longitude;
  bool isOnline;

  WeatherStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isOnline = true,
  });
}

class WeatherStationRepository extends GenericRepository<WeatherStation> {
  // Phương thức hoạt động khác nhau, trả về kết quả khác nhau
  List<WeatherStation> getOfflineStations() {
    return readAll().where((station) => !station.isOnline).toList();
  }
}

// 3. Xây dựng một frontend đơn giản hiển thị dữ liệu của 2 đối tượng
class GenericsLabScreen extends StatefulWidget {
  const GenericsLabScreen({super.key});

  @override
  State<GenericsLabScreen> createState() => _GenericsLabScreenState();
}

class _GenericsLabScreenState extends State<GenericsLabScreen> {
  final WeatherAlertRepository _alertRepo = WeatherAlertRepository();
  final WeatherStationRepository _stationRepo = WeatherStationRepository();

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu mẫu
    _alertRepo.create(WeatherAlert(id: 'A1', title: 'Cảnh báo Bão', severity: 3));
    _alertRepo.create(WeatherAlert(id: 'A2', title: 'Mưa lớn', severity: 1));
    _alertRepo.create(WeatherAlert(id: 'A3', title: 'Lũ lụt', severity: 3, isActive: false));

    _stationRepo.create(WeatherStation(id: 'S1', name: 'Trạm Hà Nội', latitude: 21.0, longitude: 105.8));
    _stationRepo.create(WeatherStation(id: 'S2', name: 'Trạm TP.HCM', latitude: 10.8, longitude: 106.6, isOnline: false));
    _stationRepo.create(WeatherStation(id: 'S3', name: 'Trạm Đà Nẵng', latitude: 16.0, longitude: 108.2, isOnline: false));
  }

  void _showAddAlertDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    int selectedSeverity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm Cảnh Báo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Tên cảnh báo'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedSeverity,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Mức 1 (Thấp)')),
                      DropdownMenuItem(value: 2, child: Text('Mức 2 (TB)')),
                      DropdownMenuItem(value: 3, child: Text('Mức 3 (Cao)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedSeverity = val);
                    },
                    decoration: const InputDecoration(labelText: 'Mức độ'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        _alertRepo.create(WeatherAlert(
                          id: 'A${DateTime.now().millisecondsSinceEpoch}',
                          title: titleController.text,
                          severity: selectedSeverity,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addRandomStation() {
    setState(() {
      _stationRepo.create(WeatherStation(
        id: 'S${DateTime.now().millisecondsSinceEpoch}',
        name: 'Trạm Mới',
        latitude: 0.0,
        longitude: 0.0,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài Thực Hành 6+ Generics'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Giao diện cho Đối tượng 1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cảnh báo thời tiết (Weather Alerts)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () => _showAddAlertDialog(context),
                  child: const Text('Thêm'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Số cảnh báo nguy hiểm (Mức 3) đang Active: ${_alertRepo.getActiveCriticalAlerts().length}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _alertRepo.readAll().length,
              itemBuilder: (context, index) {
                final alert = _alertRepo.readAll()[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.warning, color: alert.severity >= 3 ? Colors.red : Colors.orange),
                    title: Text(alert.title),
                    subtitle: Text('Mức độ: ${alert.severity} | Hoạt động: ${alert.isActive}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              alert.title = alert.title.contains('(Đã sửa)') 
                                  ? alert.title.replaceAll(' (Đã sửa)', '') 
                                  : '${alert.title} (Đã sửa)';
                              alert.isActive = !alert.isActive;
                              _alertRepo.update(alert.id, alert);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _alertRepo.delete(alert.id);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Divider(height: 40, thickness: 2),

            // Giao diện cho Đối tượng 2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Trạm thời tiết (Weather Stations)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: _addRandomStation,
                  child: const Text('Thêm'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Số trạm đang Offline: ${_stationRepo.getOfflineStations().length}',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stationRepo.readAll().length,
              itemBuilder: (context, index) {
                final station = _stationRepo.readAll()[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.satellite_alt, color: station.isOnline ? Colors.green : Colors.grey),
                    title: Text(station.name),
                    subtitle: Text('Tọa độ: ${station.latitude}, ${station.longitude} | Online: ${station.isOnline}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              station.name = station.name.contains('(Đã sửa)')
                                  ? station.name.replaceAll(' (Đã sửa)', '')
                                  : '${station.name} (Đã sửa)';
                              station.isOnline = !station.isOnline;
                              _stationRepo.update(station.id, station);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _stationRepo.delete(station.id);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

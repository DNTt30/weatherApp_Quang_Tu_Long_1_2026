import 'package:flutter/material.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _notificationsEnabled = true;
  bool _isDarkTheme = false;
  String _defaultLocation = 'Hà Nội';

  static const List<String> _locations = [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
    'Cần Thơ',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt thêm',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Bật tắt thông báo'),
            subtitle: const Text('Nhận thông báo thời tiết mới nhất'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text('Chọn vị trí mặc định'),
            subtitle: Text(_defaultLocation),
            trailing: DropdownButton<String>(
              value: _defaultLocation,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _defaultLocation = value;
                  });
                }
              },
              items: _locations
                  .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                  .toList(),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Theme sáng/tối'),
            subtitle: const Text('Chuyển đổi giữa light và dark theme'),
            value: _isDarkTheme,
            onChanged: (value) {
              setState(() {
                _isDarkTheme = value;
              });
            },
            secondary: const Icon(Icons.brightness_6),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Thông tin phiên bản'),
            subtitle: Text('WeatherApp v1.0.0'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Ghi chú',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn có thể bật thông báo, chọn vị trí mặc định và thay đổi theme tại đây.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

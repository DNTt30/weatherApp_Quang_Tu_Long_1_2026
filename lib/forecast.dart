import 'package:flutter/material.dart';

class HourlyForecast {
  final String time;
  final int temperature;
  final IconData icon;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
  });
}

class DailyForecast {
  final String day;
  final int high;
  final int low;
  final IconData icon;

  DailyForecast({
    required this.day,
    required this.high,
    required this.low,
    required this.icon,
  });
}

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  static final List<HourlyForecast> _hourly = [
    HourlyForecast(time: '08:00', temperature: 26, icon: Icons.wb_sunny),
    HourlyForecast(time: '10:00', temperature: 28, icon: Icons.wb_sunny),
    HourlyForecast(time: '12:00', temperature: 30, icon: Icons.wb_sunny),
    HourlyForecast(time: '14:00', temperature: 31, icon: Icons.wb_sunny),
    HourlyForecast(time: '16:00', temperature: 29, icon: Icons.cloud),
    HourlyForecast(time: '18:00', temperature: 27, icon: Icons.cloud_queue),
  ];

  static final List<DailyForecast> _daily = [
    DailyForecast(day: 'Thứ 2', high: 31, low: 24, icon: Icons.wb_sunny),
    DailyForecast(day: 'Thứ 3', high: 30, low: 24, icon: Icons.wb_sunny),
    DailyForecast(day: 'Thứ 4', high: 29, low: 23, icon: Icons.cloud),
    DailyForecast(day: 'Thứ 5', high: 28, low: 22, icon: Icons.cloud_queue),
    DailyForecast(day: 'Thứ 6', high: 27, low: 22, icon: Icons.wb_cloudy),
    DailyForecast(day: 'Thứ 7', high: 26, low: 21, icon: Icons.grain),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhiệt độ hôm nay',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.thermostat, size: 50, color: Colors.orange),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '28°C',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Trời nắng nhẹ',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cảm giác như 30°C',
                      style: TextStyle(fontSize: 14, color: Colors.black45),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nhiệt độ từng giờ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hourly.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final hour = _hourly[index];
                return Container(
                  width: 100,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(hour.time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Icon(hour.icon, color: Colors.orange),
                      const SizedBox(height: 10),
                      Text('${hour.temperature}°C', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nhiệt độ hằng ngày',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _daily.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final day = _daily[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(day.icon, color: Colors.blue),
                        const SizedBox(width: 12),
                        Text(day.day, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      '${day.high}° / ${day.low}°',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

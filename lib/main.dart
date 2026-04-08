import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Thay đổi Title của App theo yêu cầu
    return MaterialApp(
      title: 'Ứng dụng Dự báo Thời tiết', 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false, // Ẩn chữ debug góc phải
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dự báo Thời tiết - Nhóm 1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'THÔNG TIN THÀNH VIÊN NHÓM',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 30),
            Text(
              '1. Dương Ngọc Tú - Mã SV: 22010052',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              '2. Lê Minh Quang - Mã SV: 21012086',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              '3. Ngô Thành Long - Mã SV: 23010032',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
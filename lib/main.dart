import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/content_screen.dart';
import 'screens/about_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'service/auth_service.dart';
import 'service/weather_data_manager.dart';
import 'service/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            return const MainShell();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

// ============================================================
// MainShell — Khung chính chứa 3 màn hình + AppBar + BottomNav
// ============================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await WeatherDataManager().loadAllData();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tiêu đề AppBar theo từng tab
  final List<String> _titles = ['Home', 'Forecast', 'More'];

  // 3 màn hình chính của app
  final List<Widget> _screens = const [
    HomeScreen(),     // Long's screen
    ContentScreen(),  // Quang's screen
    AboutScreen(),    // Tú's screen
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1C1B33),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFC427FB)),
              const SizedBox(height: 16),
              Text('Đang lấy dữ liệu thời tiết...', style: GoogleFonts.poppins(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      // ── AppBar ──────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E335A),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wb_sunny_rounded,
                color: Color(0xFFFFB300), size: 22),
            const SizedBox(width: 8),
            Text(
              _titles[_currentIndex],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      // ── 3 màn hình dùng IndexedStack (giữ state) ────────────
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // ── Navigation Bar cuối màn hình ─────────────────────────
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      // THỰC HÀNH CRUD: Nút test CRUD được thêm vào main.dart
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC427FB),
        onPressed: () => _showCrudTestDialog(context),
        child: const Icon(Icons.data_object, color: Colors.white),
      ),
    );
  }

  // Dialog thực hành CRUD trong main.dart
  void _showCrudTestDialog(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2E335A),
          title: Text('Test CRUD Firebase', style: GoogleFonts.poppins(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // [C]reate
                  await firestoreService.addCity({
                    'name': 'Hanoi Test',
                    'temperature': 35,
                    'status': 'Sunny',
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create: Đã thêm Hanoi Test!')));
                },
                child: const Text('1. Create (Thêm Dữ Liệu)'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // [R]ead
                  final snapshot = await firestoreService.cities.limit(1).get();
                  if (snapshot.docs.isNotEmpty) {
                    final data = snapshot.docs.first.data() as Map<String, dynamic>;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Read: Thành phố đầu tiên là ${data['name']}')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Read: Chưa có dữ liệu')));
                  }
                },
                child: const Text('2. Read (Đọc Dữ Liệu)'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // [U]pdate
                  final snapshot = await firestoreService.cities.limit(1).get();
                  if (snapshot.docs.isNotEmpty) {
                    final docId = snapshot.docs.first.id;
                    await firestoreService.updateCity(docId, {'status': 'Rainy Updated'});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update: Đã cập nhật trạng thái!')));
                  }
                },
                child: const Text('3. Update (Cập nhật Dữ Liệu)'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // [D]elete
                  final snapshot = await firestoreService.cities.limit(1).get();
                  if (snapshot.docs.isNotEmpty) {
                    final docId = snapshot.docs.first.id;
                    await firestoreService.deleteCity(docId);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete: Đã xóa thành công!')));
                  }
                },
                child: const Text('4. Delete (Xóa Dữ Liệu)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
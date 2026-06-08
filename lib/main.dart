import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/content_screen.dart';
import 'screens/about_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'service/auth_service.dart';
import 'service/weather_data_manager.dart';
import 'service/settings_service.dart';
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
    // Reset to defaults first to avoid leftovers from previous sessions
    SettingsService.isLightMode.value = false;
    SettingsService.isCelsius.value = true;

    // 1. Load User Settings
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          final isDark = data['darkMode'] ?? true;
          final unit = data['temperatureUnit'] ?? 'C';
          
          SettingsService.isLightMode.value = !isDark;
          SettingsService.isCelsius.value = (unit == 'C');
        }
      } catch (e) {
        // ignore
      }
    }

    // 2. Load Weather Data
    await WeatherDataManager().loadAllData();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tiêu đề AppBar theo từng tab
  final List<String> _titles = ['Home', 'Discover', 'Forecast', 'More'];

  // 4 màn hình chính của app
  final List<Widget> _screens = const [
    HomeScreen(),     // Long's screen
    DiscoverScreen(), // Agoda-inspired Travel/Weather mockup
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
        backgroundColor: SettingsService.scaffoldBgColor,
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

    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.isLightMode,
      builder: (context, isLight, _) {
        return Scaffold(
          backgroundColor: SettingsService.scaffoldBgColor,
          // ── AppBar ──────────────────────────────────────────────
          appBar: AppBar(
            backgroundColor: SettingsService.bgGradientTop,
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
                    color: SettingsService.textColor,
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
    );
      },
    );
  }
}
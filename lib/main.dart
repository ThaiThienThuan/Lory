import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/social_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/upload_manga_with_chapters_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Load biến môi trường .env
  try {
    await dotenv.load(fileName: ".env");
    print('[App] ✓ .env file loaded successfully');
  } catch (e) {
    print('[App] ⚠️ Could not load .env file: $e');
  }

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/lang',
      fallbackLocale: const Locale('vi'),
      saveLocale: true, // ✅ Tự động lưu
      child: const LoryApp(),
    ),
  );
}

class LoryApp extends StatefulWidget {
  const LoryApp({super.key});

  @override
  State<LoryApp> createState() => _LoryAppState();
}

class _LoryAppState extends State<LoryApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // ✅ Chỉ load theme preference
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;

    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });

    _updateStatusBar(isDark);
  }

  void _updateStatusBar(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isDark ? const Color(0xFF0f172a) : Colors.white,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = _themeMode == ThemeMode.dark;

    setState(() {
      _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    });

    await prefs.setBool('isDarkMode', !isDark);
    _updateStatusBar(!isDark);
  }

  // ✅ EasyLocalization tự động lưu
  Future<void> _changeLanguage(Locale locale) async {
    await context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lory - Cộng đồng đọc truyện',
      debugShowCheckedModeBanner: false,

      // ✅ EasyLocalization config
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF06b6d4),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF06b6d4),
          secondary: Color(0xFFec4899),
          surface: Color(0xFFF5F5F5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF06b6d4),
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFF5F5F5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF06b6d4),
        scaffoldBackgroundColor: const Color(0xFF0f172a),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF06b6d4),
          secondary: Color(0xFFec4899),
          surface: Color(0xFF1e293b),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1e293b),
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1e293b),
          selectedItemColor: Color(0xFF06b6d4),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1e293b),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF1e293b),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF1e293b),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF0f172a),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.white12),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(
              onToggleTheme: _toggleTheme,
              onChangeLanguage: _changeLanguage,
            ),
        '/main': (context) =>
            MainScreen(onToggleTheme: _toggleTheme), // ✅ Truyền callback
        '/detail': (context) => DetailScreen(),
        '/reader': (context) => ReaderScreen(),
        '/upload-manga': (context) => const UploadMangaWithChaptersScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme; // ✅ Thêm callback
  const MainScreen({super.key, required this.onToggleTheme});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ✅ Tạo list động với callback
    final List<Widget> _screens = [
      HomeScreen(),
      LibraryScreen(),
      SocialScreen(),
      ProfileScreen(onToggleTheme: widget.onToggleTheme), // ✅ Truyền callback
    ];
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'nav.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.library_books),
            label: 'nav.library'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: 'nav.community'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'nav.profile'.tr(),
          ),
        ],
      ),
    );
  }
}

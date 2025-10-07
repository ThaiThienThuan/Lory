import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/social_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(LoryApp());
}

class LoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lory - Cộng đồng đọc truyện',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF06b6d4),
        scaffoldBackgroundColor: Color(0xFF0f172a),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF06b6d4),
          secondary: Color(0xFFec4899),
          surface: Color(0xFF1e293b),
          background: Color(0xFF0f172a),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1e293b),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1e293b),
          selectedItemColor: Color(0xFF06b6d4),
          unselectedItemColor: Colors.grey[500],
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: Color(0xFF1e293b),
          elevation: 2,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(),
        '/detail': (context) => DetailScreen(),
        '/reader': (context) => ReaderScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    LibraryScreen(),
    SocialScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.home),
            label: 'Trang Chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Thư Viện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Cộng Đồng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ Sơ',
          ),
        ],
      ),
    );
  }
}
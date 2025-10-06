import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/social_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MangaSocialApp());
}

class MangaSocialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truyện Tranh', 
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: Color(0xFF06b6d4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF06b6d4),
          secondary: Color(0xFFec4899),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1e293b),
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF06b6d4),
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
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
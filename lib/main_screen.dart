import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/history_screen.dart';
import 'screens/explore_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  
  List<Widget> get _screens => [
    const HomePage(),
    ExploreScreen(),
    HistoryScreen(),
    ProfilePage(onLogout: _handleLogout), // Truyền callback onLogout
  ];

  void _handleLogout() {
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
} 
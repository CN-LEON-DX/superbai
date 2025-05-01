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
  
  // Khai báo các màn hình tương ứng với mỗi tab
  // Sử dụng getter thay vì biến để đảm bảo luôn nhận được instances mới nếu cần
  List<Widget> get _screens => [
    const HomePage(),
    const ExploreScreen(),
    HistoryScreen(),
    ProfilePage(onLogout: _handleLogout), // Truyền callback onLogout
  ];

  // Xử lý khi người dùng đăng xuất
  void _handleLogout() {
    // Không cần làm gì ở đây vì ProfilePage sẽ tự điều hướng đến LoginPage
    // Nhưng trong tương lai có thể xử lý thêm logic nếu cần
  }

  // Thay đổi tab khi người dùng tap vào bottom navigation
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng IndexedStack để giữ trạng thái của tất cả các tab
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Sử dụng bottom navigation bar chung
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
} 
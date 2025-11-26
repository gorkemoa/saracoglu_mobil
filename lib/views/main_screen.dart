import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_content.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _cartBadgeCount = 3; // Bu değer sepet state'inden gelecek

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToSearchTab() {
    setState(() {
      _currentIndex = NavTab.search;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeContent(onSearchTap: _goToSearchTab),
          const SearchPage(),
          const FavoritesPage(),
          const CartPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        cartBadgeCount: _cartBadgeCount,
      ),
    );
  }
}

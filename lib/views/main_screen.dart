import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import 'home_content.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'bot_video_page.dart';

/// Sayfa yenileme için typedef'ler
typedef _HomeContentRefreshable = HomeContentState;
typedef _SearchPageRefreshable = SearchPageState;
typedef _FavoritesPageRefreshable = FavoritesPageState;
typedef _CartPageRefreshable = CartPageState;
typedef _ProfilePageRefreshable = ProfilePageState;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _cartBadgeCount = 3; // Bu değer sepet state'inden gelecek
  bool _showBotBubble = true; // Konuşma balonu gösterilsin mi

  // Sayfa key'leri - yenileme için
  final GlobalKey<_HomeContentRefreshable> _homeKey = GlobalKey();
  final GlobalKey<_SearchPageRefreshable> _searchKey = GlobalKey();
  final GlobalKey<_FavoritesPageRefreshable> _favoritesKey = GlobalKey();
  final GlobalKey<_CartPageRefreshable> _cartKey = GlobalKey();
  final GlobalKey<_ProfilePageRefreshable> _profileKey = GlobalKey();

  void _onTabTapped(int index) {
    // Aynı tab'a tıklanırsa veya farklı tab'a geçilirse yenile
    _refreshPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  /// İlgili sayfayı yenile
  void _refreshPage(int index) {
    switch (index) {
      case NavTab.home:
        _homeKey.currentState?.refresh();
        break;
      case NavTab.search:
        _searchKey.currentState?.refresh();
        break;
      case NavTab.favorites:
        _favoritesKey.currentState?.refresh();
        break;
      case NavTab.cart:
        _cartKey.currentState?.refresh();
        break;
      case NavTab.profile:
        _profileKey.currentState?.refresh();
        break;
    }
  }

  void _goToSearchTab() {
    setState(() {
      _currentIndex = NavTab.search;
    });
  }

  void _closeBotBubble() {
    setState(() {
      _showBotBubble = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeContent(key: _homeKey, onSearchTap: _goToSearchTab),
          SearchPage(key: _searchKey),
          FavoritesPage(key: _favoritesKey),
          CartPage(key: _cartKey),
          ProfilePage(key: _profileKey),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Konuşma Balonu
                if (_showBotBubble)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 4),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 220),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "Merhaba! 👋 Sağlıklı yaşam için size nasıl yardımcı olabilirim?",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _closeBotBubble,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Üçgen ok (balonu bot'a bağlayan)
                        Positioned(
                          bottom: -8,
                          right: 20,
                          child: CustomPaint(
                            size: const Size(24, 16),
                            painter: BubbleArrowPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Bot ikonu
                SizedBox(
                  width: 60,
                  height: 60,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Video sayfasını aç
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BotVideoPage(),
                        ),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/bot/bot.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.smart_toy,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        cartBadgeCount: _cartBadgeCount,
      ),
    );
  }
}

// Konuşma balonu ok çizici
class BubbleArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

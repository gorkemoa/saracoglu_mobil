import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/favorite_item_card.dart';
import '../services/auth_service.dart';
import 'auth/login_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with TickerProviderStateMixin {
  // Favori ürünler listesi - gerçek uygulamada state management ile yönetilecek
  final List<FavoriteItemData> _favorites = [
    FavoriteItemData(
      id: '1',
      title: 'Aromaterapi Yağı',
      weight: '50 ml',
      price: 189.90,
      oldPrice: 229.90,
      imageUrl: 'assets/kategorileri/aromaterapi.png',
      isAssetImage: true,
      category: 'Aromaterapi',
    ),
    FavoriteItemData(
      id: '2',
      title: 'Doğal Bitkisel Çay',
      weight: '100 gr',
      price: 129.90,
      imageUrl: 'assets/kategorileri/dogalbitkiler.png',
      isAssetImage: true,
      category: 'Bitkisel',
    ),
    FavoriteItemData(
      id: '3',
      title: 'Soğuk Sıkım Zeytinyağı',
      weight: '500 ml',
      price: 349.90,
      oldPrice: 399.90,
      imageUrl: 'assets/kategorileri/soguksikimyaglar.png',
      isAssetImage: true,
      category: 'Yağlar',
    ),
    FavoriteItemData(
      id: '4',
      title: 'Organik Kozmetik Krem',
      weight: '30 ml',
      price: 159.90,
      oldPrice: 189.90,
      imageUrl: 'assets/kategorileri/organikkozmatik.png',
      isAssetImage: true,
      category: 'Kozmetik',
    ),
  ];

  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  int get _totalItems => _favorites.length;

  void _removeItem(FavoriteItemData item) {
    HapticFeedback.mediumImpact();
    setState(() {
      _favorites.removeWhere((i) => i.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} favorilerden kaldırıldı'),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _favorites.add(item);
            });
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(FavoriteItemData item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Favoriden Kaldır',
                style: AppTypography.h4,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '${item.title} ürününü favorilerinizden kaldırmak istediğinize emin misiniz?',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text(
                        'Vazgeç',
                        style: AppTypography.buttonMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeItem(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text(
                        'Kaldır',
                        style: AppTypography.buttonMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFavorites() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.heart_broken_outlined,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Favorileri Temizle',
                style: AppTypography.h4,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Tüm favori ürünleriniz kaldırılacak. Devam etmek istiyor musunuz?',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text(
                        'Vazgeç',
                        style: AppTypography.buttonMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _favorites.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text(
                        'Temizle',
                        style: AppTypography.buttonMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(FavoriteItemData item) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('${item.title} sepete eklendi'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        action: SnackBarAction(
          label: 'Sepete Git',
          textColor: Colors.white,
          onPressed: () {
            // Sepete yönlendir
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: !authService.isLoggedIn 
        ? _buildLoginRequiredState() 
        : (_favorites.isEmpty ? _buildEmptyState() : _buildFavoritesContent()),
    );
  }

  Widget _buildLoginRequiredState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.error.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: 56,
                    color: AppColors.error.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                'Favorilerinizi Görüntüleyin',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Beğendiğiniz ürünleri favorilerinize eklemek ve görüntülemek için giriş yapın.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    ).then((_) {
                      setState(() {}); // Sayfayı yenile
                    });
                  },
                  icon: Icon(Icons.login_rounded),
                  label: Text('Giriş Yap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMD,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
                child: Text(
                  'Hesabınız yok mu? Kayıt olun',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasyonlu ikon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withOpacity(0.1),
                        AppColors.error.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        size: 64,
                        color: AppColors.error.withOpacity(0.7),
                      ),
                      Positioned(
                        top: 30,
                        right: 30,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              Text(
                'Favorileriniz Boş',
                style: AppTypography.h3,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Beğendiğiniz ürünleri kalp ikonuna tıklayarak\nfavorilerinize ekleyebilirsiniz.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Ana sayfaya yönlendir
                  },
                  icon: Icon(Icons.storefront_outlined),
                  label: Text(
                    'Ürünleri Keşfet',
                    style: AppTypography.buttonLarge,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMD,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Popüler kategoriler
              Text(
                'Popüler Kategoriler',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryChip('Bal', Icons.water_drop_outlined),
                  SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Propolis', Icons.local_florist_outlined),
                  SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Bitkisel', Icons.eco_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: AppRadius.borderRadiusRound,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusRound,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTypography.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return CustomScrollView(
      slivers: [
        // Custom AppBar
        SliverAppBar(
          backgroundColor: AppColors.surface,
          pinned: true,
          elevation: 0,
          scrolledUnderElevation: 2,
          expandedHeight: 60,
          title: Column(
            children: [
              Text(
                'Favorilerim',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                '$_totalItems ürün',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _clearFavorites,
              icon: Icon(Icons.delete_sweep_outlined, color: AppColors.error, size: 22),
              tooltip: 'Favorileri Temizle',
            ),
          ],
        ),

        // Favori Bilgi Alanı
        SliverToBoxAdapter(
          child: _buildInfoSection(),
        ),

        // Ürün Listesi
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _favorites[index];
                return Column(
                  children: [
                    FavoriteItemCard(
                      item: item,
                      onTap: () {
                        // Ürün detay sayfasına yönlendir
                      },
                      onRemove: () => _showDeleteConfirmation(item),
                      onAddToCart: () => _addToCart(item),
                      onDismissed: () => _removeItem(item),
                    ),
                    if (index < _favorites.length - 1)
                      SizedBox(height: AppSpacing.sm),
                  ],
                );
              },
              childCount: _favorites.length,
            ),
          ),
        ),

        // Önerilen Ürünler
        SliverToBoxAdapter(
          child: _buildSuggestionsSection(),
        ),

        // Alt boşluk
        SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: AppColors.error,
            size: 18,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Favori ürünlerinize hızlıca erişin ve sepete ekleyin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.error.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    final suggestions = [
      {
        'title': 'Doğal Gıda ve İçecek',
        'weight': '450 gr',
        'price': 289.90,
        'oldPrice': 349.90,
        'image': 'assets/kategorileri/dogalgidaveicecekler.png',
      },
      {
        'title': 'Cilt ve Vücut Bakım',
        'weight': '100 ml',
        'price': 249.90,
        'image': 'assets/kategorileri/ciltvevucuturunleri.png',
      },
      {
        'title': 'Saç Bakım Ürünü',
        'weight': '200 ml',
        'price': 179.90,
        'oldPrice': 199.90,
        'image': 'assets/kategorileri/sacbakimurunleri.png',
      },
      {
        'title': 'Bebek Bakım Seti',
        'weight': '150 ml',
        'price': 129.90,
        'image': 'assets/kategorileri/bebekbakim.png',
      },
    ];

    return Container(
      margin: EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, color: AppColors.accent, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Bunları da beğenebilirsiniz',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ProductCardList(
            height: 330,
            products: suggestions.map((item) => ProductCard(
              title: item['title'] as String,
              weight: item['weight'] as String,
              price: item['price'] as double,
              oldPrice: item['oldPrice'] as double?,
              imageUrl: item['image'] as String,
              isAssetImage: true,
              onTap: () {
                // Ürün detay sayfasına yönlendir
              },
              onAddToCart: () {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text('${item['title']} sepete eklendi'),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                  ),
                );
              },
              onFavorite: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.white, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text('${item['title']} favorilere eklendi'),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                  ),
                );
              },
            )).toList(),
          ),
        ],
      ),
    );
  }
}

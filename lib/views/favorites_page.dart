import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../models/favorite/favorite_model.dart';
import 'auth/login_page.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with TickerProviderStateMixin {
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();

  List<FavoriteProduct> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController.forward();

    if (_authService.isLoggedIn) {
      _loadFavorites();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _favoriteService.getUserFavorites();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response != null && response.success) {
          _favorites = response.favoriteProducts;
        } else {
          _errorMessage = 'Favoriler yüklenemedi';
        }
      });
    }
  }

  int get _totalItems => _favorites.length;

  Future<void> _removeItem(FavoriteProduct item) async {
    HapticFeedback.mediumImpact();

    // Önce UI'dan kaldır (optimistic update)
    final removedItem = item;
    final removedIndex = _favorites.indexOf(item);
    setState(() {
      _favorites.removeWhere((i) => i.favoriteID == item.favoriteID);
    });

    // API çağrısı yap
    final response = await _favoriteService.toggleFavorite(
      productId: item.productID,
    );

    if (mounted) {
      if (response != null && response.success && !response.isFavorite) {
        // Başarıyla kaldırıldı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      } else {
        // Hata oldu, geri ekle
        setState(() {
          if (removedIndex >= 0 && removedIndex <= _favorites.length) {
            _favorites.insert(removedIndex, removedItem);
          } else {
            _favorites.add(removedItem);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Favori kaldırma işlemi başarısız oldu'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(FavoriteProduct item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
              Text('Favoriden Kaldır', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                '${item.productName} ürününü favorilerinizden kaldırmak istediğinize emin misiniz?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _removeItem(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text('Kaldır', style: AppTypography.buttonMedium),
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
              Text('Favorileri Temizle', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Tüm favori ürünleriniz kaldırılacak. Devam etmek istiyor musunuz?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
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
                      child: Text('Temizle', style: AppTypography.buttonMedium),
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

  void _addToCart(FavoriteProduct item) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text('${item.productName} sepete eklendi')),
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

  void _navigateToProductDetail(FavoriteProduct item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: item.productID),
      ),
    ).then((_) {
      // Sayfaya geri dönünce yenile
      if (_authService.isLoggedIn) {
        _loadFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: !_authService.isLoggedIn
          ? _buildLoginRequiredState()
          : _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : (_favorites.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesContent()),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Favoriler yükleniyor...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage ?? 'Bir hata oluştu',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _loadFavorites,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
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
                  return Transform.scale(scale: value, child: child);
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
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    ).then((_) {
                      setState(() {});
                      if (_authService.isLoggedIn) {
                        _loadFavorites();
                      }
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
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ).then((_) {
                    setState(() {});
                    if (_authService.isLoggedIn) {
                      _loadFavorites();
                    }
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
                  return Transform.scale(scale: value, child: child);
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
                          child: Icon(Icons.add, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              Text('Favorileriniz Boş', style: AppTypography.h3),
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
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
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
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
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
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$_totalItems ürün',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              if (_favorites.isNotEmpty)
                IconButton(
                  onPressed: _clearFavorites,
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.error,
                    size: 22,
                  ),
                  tooltip: 'Favorileri Temizle',
                ),
            ],
          ),

          // Favori Bilgi Alanı
          SliverToBoxAdapter(child: _buildInfoSection()),

          // Ürün Listesi
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _favorites[index];
                return Column(
                  children: [
                    _buildFavoriteItemCard(item),
                    if (index < _favorites.length - 1)
                      SizedBox(height: AppSpacing.sm),
                  ],
                );
              }, childCount: _favorites.length),
            ),
          ),

          // Alt boşluk
          SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildFavoriteItemCard(FavoriteProduct item) {
    return Dismissible(
      key: Key(item.favoriteID.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadius.borderRadiusMD,
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        _showDeleteConfirmation(item);
        return false;
      },
      child: GestureDetector(
        onTap: () => _navigateToProductDetail(item),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusMD,
            boxShadow: AppShadows.shadowSM,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün Görseli
              ClipRRect(
                borderRadius: AppRadius.borderRadiusSM,
                child: Container(
                  width: 90,
                  height: 90,
                  color: AppColors.background,
                  child: Image.network(
                    item.productImage,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      );
                    },
                    errorBuilder: (c, o, s) => Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textTertiary,
                      size: 32,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),

              // Ürün Bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İndirim badge
                    if (item.hasDiscount)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        margin: EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.productDiscountIcon}${item.productDiscount}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),

                    // Ürün adı
                    Text(
                      item.productName,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    // Rating
                    if (item.ratingAsDouble != null)
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: i < (item.ratingAsDouble?.round() ?? 0)
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '(${item.totalComments})',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 8),

                    // Fiyat ve butonlar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productPrice,
                              style: AppTypography.priceMain,
                            ),
                            if (item.hasDiscount)
                              Text(
                                item.productPriceDiscount,
                                style: AppTypography.priceOld.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            // Kaldır butonu
                            IconButton(
                              onPressed: () => _showDeleteConfirmation(item),
                              icon: Icon(
                                Icons.favorite,
                                color: AppColors.error,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                            SizedBox(width: 4),
                            // Sepete ekle butonu
                            GestureDetector(
                              onTap: () => _addToCart(item),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: item.isInStock
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                  borderRadius: AppRadius.borderRadiusSM,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      item.isInStock ? 'Ekle' : 'Tükendi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, color: AppColors.error, size: 18),
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
}

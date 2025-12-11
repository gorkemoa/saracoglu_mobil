import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/favorite_service.dart';
import '../services/basket_service.dart';
import '../services/banner_service.dart';
import '../services/notification_service.dart';
import '../models/product/product_model.dart';
import '../models/product/category_model.dart';
import '../models/banner/banner_model.dart';
import 'product_detail_page.dart';
import 'all_products_page.dart';

class HomeContent extends StatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeContent({super.key, this.onSearchTap});

  @override
  State<HomeContent> createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  // Services
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();
  final BasketService _basketService = BasketService();
  final BannerService _bannerService = BannerService();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  // Bildirimler state
  int _unreadNotificationCount = 0;

  // Yeni ürünler state
  List<ProductModel> _newProducts = [];
  bool _isLoadingNewProducts = true;

  // Kampanyalı ürünler state
  List<ProductModel> _campaignProducts = [];
  bool _isLoadingCampaignProducts = true;

  // Kategoriler state
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;

  // Bannerlar state
  List<BannerModel> _banners = [];
  bool _isLoadingBanners = true;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _loadProducts();
    _loadNotifications();
  }

  /// Sayfayı yenile - MainScreen'den çağrılır
  void refresh() {
    _loadProducts();
    _loadNotifications();
  }

  /// Bildirimleri yükle
  Future<void> _loadNotifications() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final notifications = await _notificationService.getNotifications(
      userId: user.id,
    );

    if (mounted) {
      setState(() {
        _unreadNotificationCount =
            notifications.where((n) => !n.isRead).length;
      });
    }
  }

  /// Ürünleri yükle
  Future<void> _loadProducts() async {
    await Future.wait([
      _loadBanners(),
      _loadCategories(),
      _loadNewProducts(),
      _loadCampaignProducts(),
    ]);
  }

  /// Banner'ları yükle
  Future<void> _loadBanners() async {
    final banners = await _bannerService.getBanners();
    if (mounted) {
      setState(() {
        _isLoadingBanners = false;
        _banners = banners;
      });
    }
  }

  /// Kategorileri yükle
  Future<void> _loadCategories() async {
    final categories = await _productService.getCategories();
    if (mounted) {
      setState(() {
        _isLoadingCategories = false;
        _categories = categories;
      });
    }
  }

  /// Yeni ürünleri yükle (tüm sayfalardan)
  Future<void> _loadNewProducts() async {
    final products = await _productService.getAllNewProducts(maxProducts: 10);
    if (mounted) {
      setState(() {
        _isLoadingNewProducts = false;
        _newProducts = products;
      });
    }
  }

  /// Kampanyalı ürünleri yükle (tüm sayfalardan indirimli olanlar)
  Future<void> _loadCampaignProducts() async {
    final products = await _productService.getAllCampaignProducts(
      maxProducts: 10,
    );
    if (mounted) {
      setState(() {
        _isLoadingCampaignProducts = false;
        _campaignProducts = products;
      });
    }
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _navigateToProductDetail(
    BuildContext context, {
    required ProductModel product,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.productID),
      ),
    );
  }

  Future<void> _handleAddToCart(
    BuildContext context,
    ProductModel product,
  ) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Sepete eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.mediumImpact();
    if (!context.mounted) return;

    final response = await _basketService.addToBasket(
      productId: product.productID,
    );

    if (!context.mounted) return;

    if (response != null && response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(response.message)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(response?.message ?? 'Sepete eklenemedi')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        ),
      );
    }
  }

  Future<void> _handleFavorite(
    BuildContext context,
    ProductModel product,
  ) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Favorilere eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.lightImpact();
    if (!context.mounted) return;

    final response = await _favoriteService.toggleFavorite(
      productId: product.productID,
    );

    if (!context.mounted) return;

    if (response != null && response.success) {
      // Ürünün favori durumunu güncelle
      setState(() {
        // Yeni ürünlerde güncelle
        final newIndex = _newProducts.indexWhere(
          (p) => p.productID == product.productID,
        );
        if (newIndex != -1) {
          _newProducts[newIndex] = _newProducts[newIndex].copyWith(
            isFavorite: response.isFavorite,
          );
        }
        // Kampanyalı ürünlerde güncelle
        final campaignIndex = _campaignProducts.indexWhere(
          (p) => p.productID == product.productID,
        );
        if (campaignIndex != -1) {
          _campaignProducts[campaignIndex] = _campaignProducts[campaignIndex]
              .copyWith(isFavorite: response.isFavorite);
        }
      });
    } else {
      // Hata durumunda mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('Favori işlemi başarısız oldu')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildInfoBanners(),
              SizedBox(height: AppSpacing.md),
              _buildPromoSlider(),
              SizedBox(height: AppSpacing.lg),
              _buildMainCategories(),
              SizedBox(height: AppSpacing.md),
              _buildCampaignProducts(),
              SizedBox(height: AppSpacing.lg),
              _buildNewProducts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 40, fit: BoxFit.contain),
          GestureDetector(
            onTap: () async {
              if (!await AuthGuard.checkAuth(
                context,
                message: 'Bildirimleri görmek için giriş yapın',
              )) {
                return;
              }
              if (!mounted) return;
              Navigator.pushNamed(context, '/notifications').then((_) {
                _loadNotifications();
              });
            },
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderRadiusXS,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: AppSizes.iconMD,
                  ),
                ),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _unreadNotificationCount > 9
                            ? '9+'
                            : _unreadNotificationCount.toString(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        color: AppColors.surface,
        child: Container(
          height: AppSizes.buttonHeightMD,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.borderRadiusSM,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.search,
                color: AppColors.textTertiary,
                size: AppSizes.iconSM,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  "Ürün, kategori veya marka ara...",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanners() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            _buildInfoBanner(
              Icons.local_shipping,
              "1000 TL Üzeri",
              "Ücretsiz Kargo",
              AppColors.primary,
            ),
            SizedBox(width: AppSpacing.md),
            _buildInfoBanner(
              Icons.verified_user,
              "Güvenli",
              "Alışveriş",
              AppColors.info,
            ),
            SizedBox(width: AppSpacing.md),
            _buildInfoBanner(
              Icons.headset_mic,
              "Çağrı Merkezi",
              "0850 221 01 61",
              AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCategories() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.borderRadiusXS,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text("BAŞLICA KATEGORİLERİMİZ", style: AppTypography.h4),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          if (_isLoadingCategories)
            _buildCategoriesLoading()
          else if (_categories.isEmpty)
            _buildCategoriesEmpty()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryItem(category);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesLoading() {
    return SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildCategoriesEmpty() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'Kategoriler yüklenemedi',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllProductsPage.category(
              categoryId: category.catID,
              categoryName: category.catName,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderRadiusMD,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.shadowCard,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.borderRadiusMD,
              child: Image.network(
                category.catThumbImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.category, color: AppColors.primary, size: 28),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            category.catName,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSlider() {
    if (_isLoadingBanners) {
      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          height: 200,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return _buildSliderItem(banner);
            },
          ),
        ),
        SizedBox(height: AppSpacing.md),
        _buildSliderIndicators(),
      ],
    );
  }

  Widget _buildSliderItem(BannerModel banner) {
    return GestureDetector(
      onTap: () {
        // Banner tıklama işlemi
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderRadiusLG,
          boxShadow: AppShadows.shadowMD,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderRadiusLG,
          child: Image.network(
            banner.postMainImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.borderRadiusLG,
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.textOnPrimary,
                  size: 48,
                ),
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.borderRadiusLG,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSliderIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _banners.length,
        (index) => GestureDetector(
          onTap: () {
            _bannerController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            width: _currentBannerIndex == index ? 24.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: _currentBannerIndex == index
                  ? AppColors.primary
                  : AppColors.border,
              borderRadius: AppRadius.borderRadiusXS,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignProducts() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: AppRadius.borderRadiusXS,
                      ),
                      child: Text(
                        "KAMPANYALI ÜRÜNLER",
                        style: AppTypography.discountBadge,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    const Text("🔥", style: TextStyle(fontSize: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllProductsPage.campaignProducts(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "Tümünü Gör",
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                        size: AppSizes.iconSM,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              "İndirimli ürünleri kaçırmayın!",
              style: AppTypography.bodySmall,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (_isLoadingCampaignProducts)
            _buildProductsLoading()
          else if (_campaignProducts.isEmpty)
            _buildProductsEmpty("Kampanyalı ürün bulunamadı")
          else
            ProductCardList(
              products: _campaignProducts
                  .map(
                    (product) => ProductCard(
                      title: product.productName,
                      weight: product.productExcerpt.isNotEmpty
                          ? product.productExcerpt
                          : "",
                      price: product.priceAsDouble,
                      oldPrice: product.hasDiscount
                          ? product.discountPriceAsDouble
                          : null,
                      imageUrl: product.productImage,
                      rating: product.ratingAsDouble,
                      reviewCount: product.totalComments > 0
                          ? product.totalComments
                          : null,
                      badgeText: product.hasDiscount ? "KAMPANYA" : null,
                      badgeColor: const Color(0xFF7B2CBF),
                      isFavorite: product.isFavorite,
                      onTap: () =>
                          _navigateToProductDetail(context, product: product),
                      onAddToCart: () => _handleAddToCart(context, product),
                      onFavorite: () => _handleFavorite(context, product),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildNewProducts() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: AppRadius.borderRadiusXS,
                      ),
                      child: Text(
                        "YENİ ÜRÜNLER",
                        style: AppTypography.discountBadge,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    const Text("✨", style: TextStyle(fontSize: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllProductsPage.newProducts(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "Tümünü Gör",
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                        size: AppSizes.iconSM,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              "En son eklenen ürünlerimiz",
              style: AppTypography.bodySmall,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (_isLoadingNewProducts)
            _buildProductsLoading()
          else if (_newProducts.isEmpty)
            _buildProductsEmpty("Yeni ürün bulunamadı")
          else
            ProductCardList(
              products: _newProducts
                  .map(
                    (product) => ProductCard(
                      title: product.productName,
                      weight: product.productExcerpt.isNotEmpty
                          ? product.productExcerpt
                          : "",
                      price: product.priceAsDouble,
                      oldPrice: product.hasDiscount
                          ? product.discountPriceAsDouble
                          : null,
                      imageUrl: product.productImage,
                      rating: product.ratingAsDouble,
                      reviewCount: product.totalComments > 0
                          ? product.totalComments
                          : null,
                      badgeText: "YENİ",
                      badgeColor: const Color(0xFF4CAF50),
                      isFavorite: product.isFavorite,
                      onTap: () =>
                          _navigateToProductDetail(context, product: product),
                      onAddToCart: () => _handleAddToCart(context, product),
                      onFavorite: () => _handleFavorite(context, product),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  /// Loading widget for products
  Widget _buildProductsLoading() {
    return SizedBox(
      height: 330,
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  /// Empty widget for products
  Widget _buildProductsEmpty(String message) {
    return SizedBox(
      height: 330,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

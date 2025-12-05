import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/favorite_service.dart';
import '../models/product/product_model.dart';
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

  // Product service
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();

  // Yeni ürünler state
  List<ProductModel> _newProducts = [];
  bool _isLoadingNewProducts = true;

  // Kampanyalı ürünler state
  List<ProductModel> _campaignProducts = [];
  bool _isLoadingCampaignProducts = true;

  final List<Map<String, dynamic>> _banners = [
    {'image': 'assets/slider/1.png'},
    {'image': 'assets/slider/2.png'},
    {'image': 'assets/slider/3.png'},
    {'image': 'assets/slider/4.png'},
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _loadProducts();
  }

  /// Sayfayı yenile - MainScreen'den çağrılır
  void refresh() {
    _loadProducts();
  }

  /// Ürünleri yükle
  Future<void> _loadProducts() async {
    await Future.wait([_loadNewProducts(), _loadCampaignProducts()]);
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
    String productName,
  ) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Sepete eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.mediumImpact();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('$productName sepete eklendi')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
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
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 35, fit: BoxFit.contain),
          Row(
            children: [
              _buildHeaderIcon(Icons.favorite_border, badge: false),
              SizedBox(width: AppSpacing.md),
              _buildHeaderIcon(
                Icons.shopping_cart_outlined,
                badge: true,
                badgeCount: "0",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(
    IconData icon, {
    bool badge = false,
    String? badgeCount,
  }) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: AppSizes.iconMD),
        ),
        if (badge)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: const BoxDecoration(
                color: AppColors.badge,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: AppSizes.badgeSize,
                minHeight: AppSizes.badgeSize,
              ),
              child: Text(
                badgeCount ?? "",
                style: AppTypography.badge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
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
    final categories = [
      {
        'name': 'Kampanyalı Ürünler',
        'image': 'assets/kategorileri/kampanya.png',
      },
      {
        'name': 'Soğuk Sıkım Yağlar',
        'image': 'assets/kategorileri/soguksikimyaglar.png',
      },
      {
        'name': 'Doğal Bitkiler',
        'image': 'assets/kategorileri/dogalbitkiler.png',
      },
      {
        'name': 'Gıda & İçecekler',
        'image': 'assets/kategorileri/dogalgidaveicecekler.png',
      },
      {
        'name': 'Organik Kozmetik',
        'image': 'assets/kategorileri/organikkozmatik.png',
      },
      {'name': 'Bebek Bakım', 'image': 'assets/kategorileri/bebekbakim.png'},
      {'name': 'Ev & Yaşam', 'image': 'assets/kategorileri/evyasam.png'},
      {'name': 'Aromaterapi', 'image': 'assets/kategorileri/aromaterapi.png'},
      {
        'name': 'Cilt & Vücut',
        'image': 'assets/kategorileri/ciltvevucuturunleri.png',
      },
      {
        'name': 'Saç Bakım',
        'image': 'assets/kategorileri/sacbakimurunleri.png',
      },
      {'name': 'Kitaplar', 'image': 'assets/kategorileri/kitaplar.png'},
      {
        'name': 'Son Çağrı',
        'image': 'assets/kategorileri/soncagriurunleri.png',
      },
    ];

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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.90,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(
                categories[index]['name'] as String,
                categories[index]['image'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Kategori tıklama işlemi
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.category, color: AppColors.primary, size: 28),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            name,
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

  Widget _buildSliderItem(Map<String, dynamic> banner) {
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
          child: Image.asset(
            banner['image'] as String,
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
                      onAddToCart: () =>
                          _handleAddToCart(context, product.productName),
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
                      onAddToCart: () =>
                          _handleAddToCart(context, product.productName),
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

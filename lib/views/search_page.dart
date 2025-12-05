import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../models/product/product_model.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  final bool showBackButton;

  const SearchPage({super.key, this.showBackButton = false});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();
  final ScrollController _scrollController = ScrollController();

  // Arama sonuçları state
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _isLastPage = false;
  int _currentPage = 1;
  String _lastSearchText = '';

  // Sana Özel Ürünler (API'den)
  List<ProductModel> _specialProducts = [];
  bool _isLoadingSpecialProducts = true;

  // Önceden Gezdiklerim
  final List<Map<String, dynamic>> _recentlyViewed = [
    {'image': 'assets/kategorileri/soguksikimyaglar.png', 'isAsset': true},
    {'image': 'assets/kategorileri/dogalbitkiler.png', 'isAsset': true},
    {'image': 'assets/kategorileri/dogalgidaveicecekler.png', 'isAsset': true},
    {'image': 'assets/kategorileri/aromaterapi.png', 'isAsset': true},
    {'image': 'assets/kategorileri/ciltvevucuturunleri.png', 'isAsset': true},
    {'image': 'assets/kategorileri/organikkozmatik.png', 'isAsset': true},
  ];

  // Popüler Aramalar
  final List<Map<String, dynamic>> _popularSearches = [
    {'text': 'çörek otu yağı', 'isHot': true},
    {'text': 'ıhlamur', 'isHot': true},
    {'text': 'organik bal', 'isHot': false},
    {'text': 'lavanta yağı', 'isHot': false},
    {'text': 'arı sütü', 'isHot': false},
    {'text': 'propolis', 'isHot': false},
    {'text': 'zerdeçal', 'isHot': false},
    {'text': 'kekik suyu', 'isHot': false},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchTextChanged);
    // Sayfa açıldığında arama kutusuna otomatik focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    _loadSpecialProducts();
  }

  /// Sayfayı yenile - MainScreen'den çağrılır
  void refresh() {
    _loadSpecialProducts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll listener for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreSearchResults();
    }
  }

  /// Arama metni değiştiğinde (debounce ile)
  void _onSearchTextChanged() {
    final text = _searchController.text.trim();
    if (text.length >= 2 && text != _lastSearchText) {
      _performSearch(text);
    } else if (text.isEmpty && _searchResults.isNotEmpty) {
      setState(() {
        _searchResults = [];
        _lastSearchText = '';
      });
    }
  }

  /// Özel ürünleri yükle (çok satanlar)
  Future<void> _loadSpecialProducts() async {
    final response = await _productService.getAllProducts(
      ProductFilter(sortKey: ProductSortKey.sortBestSellers, page: 1),
    );

    if (mounted) {
      setState(() {
        _isLoadingSpecialProducts = false;
        if (response != null) {
          _specialProducts = response.products.take(10).toList();
        }
      });
    }
  }

  /// Arama yap
  Future<void> _performSearch(String searchText) async {
    if (searchText.length < 2) return;

    setState(() {
      _isSearching = true;
      _currentPage = 1;
      _searchResults = [];
      _lastSearchText = searchText;
    });

    final response = await _productService.searchProducts(
      searchText: searchText,
      page: 1,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
        if (response != null) {
          _searchResults = response.products;
          _isLastPage = response.isLastPage;
        }
      });
    }
  }

  /// Daha fazla arama sonucu yükle
  Future<void> _loadMoreSearchResults() async {
    if (_isLoadingMore || _isLastPage || _lastSearchText.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    final response = await _productService.searchProducts(
      searchText: _lastSearchText,
      page: nextPage,
    );

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        if (response != null) {
          _currentPage = nextPage;
          _searchResults.addAll(response.products);
          _isLastPage = response.isLastPage;
        }
      });
    }
  }

  void _navigateToProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.productID),
      ),
    );
  }

  Future<void> _handleAddToCart(String productName) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Sepete eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.mediumImpact();
    if (!mounted) return;

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
    ProductModel product, {
    bool isSearchResult = true,
  }) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Favorilere eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.lightImpact();
    if (!mounted) return;

    final response = await _favoriteService.toggleFavorite(
      productId: product.productID,
    );

    if (!mounted) return;

    if (response != null && response.success) {
      setState(() {
        if (isSearchResult) {
          final index = _searchResults.indexWhere(
            (p) => p.productID == product.productID,
          );
          if (index != -1) {
            _searchResults[index] = _searchResults[index].copyWith(
              isFavorite: response.isFavorite,
            );
          }
        } else {
          final index = _specialProducts.indexWhere(
            (p) => p.productID == product.productID,
          );
          if (index != -1) {
            _specialProducts[index] = _specialProducts[index].copyWith(
              isFavorite: response.isFavorite,
            );
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  response?.message ?? 'Favori işlemi başarısız oldu',
                ),
              ),
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
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _searchResults.isNotEmpty || _isSearching
                  ? _buildSearchResults()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSpacing.lg),
                          _buildRecentlyViewed(),
                          SizedBox(height: AppSpacing.xl),
                          _buildSpecialProducts(),
                          SizedBox(height: AppSpacing.xl),
                          _buildPopularSearches(),
                          SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Arama Kutusu
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(22),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.trim().length >= 2) {
                          _performSearch(value.trim());
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Marka, ürün veya kategori ara",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _lastSearchText = '';
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    )
                  else
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: () {
              if (widget.showBackButton) {
                Navigator.pop(context);
              } else {
                final text = _searchController.text.trim();
                if (text.length >= 2) {
                  _performSearch(text);
                }
                FocusScope.of(context).unfocus();
              }
            },
            child: Text(
              widget.showBackButton ? 'İptal' : 'Ara',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Arama sonuçları widget'ı
  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppSpacing.md),
            Text(
              'Aranıyor...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.md),
            Text(
              '"$_lastSearchText" için sonuç bulunamadı',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text(
            '${_searchResults.length} sonuç bulundu',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.xl,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.53,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _searchResults.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _searchResults.length) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              final product = _searchResults[index];
              return ProductCard(
                title: product.productName,
                weight: product.productExcerpt.isNotEmpty
                    ? product.productExcerpt
                    : '',
                price: product.priceAsDouble,
                oldPrice: product.hasDiscount
                    ? product.discountPriceAsDouble
                    : null,
                imageUrl: product.productImage,
                rating: product.ratingAsDouble,
                reviewCount: product.totalComments > 0
                    ? product.totalComments
                    : null,
                isFavorite: product.isFavorite,
                onTap: () => _navigateToProductDetail(product),
                onAddToCart: () => _handleAddToCart(product.productName),
                onFavorite: () =>
                    _handleFavorite(product, isSearchResult: true),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialProducts() {
    if (_isLoadingSpecialProducts) {
      return SizedBox(
        height: 330,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_specialProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sana Özel Ürünler',
                style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // Tümünü gör
                },
                child: Row(
                  children: [
                    Text(
                      'Tümünü Gör',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ProductCardList(
          height: 330,
          products: _specialProducts.map((product) {
            return ProductCard(
              title: product.productName,
              weight: product.productExcerpt.isNotEmpty
                  ? product.productExcerpt
                  : '',
              price: product.priceAsDouble,
              oldPrice: product.hasDiscount
                  ? product.discountPriceAsDouble
                  : null,
              imageUrl: product.productImage,
              rating: product.ratingAsDouble,
              reviewCount: product.totalComments > 0
                  ? product.totalComments
                  : null,
              badgeText: product.hasDiscount ? 'KAMPANYA' : null,
              badgeColor: const Color(0xFF7B2CBF),
              isFavorite: product.isFavorite,
              onTap: () => _navigateToProductDetail(product),
              onAddToCart: () => _handleAddToCart(product.productName),
              onFavorite: () => _handleFavorite(product, isSearchResult: false),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Önceden Gezdiklerim',
                style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // Tümünü gör
                },
                child: Row(
                  children: [
                    Text(
                      'Tümünü Gör',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _recentlyViewed.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return _buildRecentlyViewedItem(_recentlyViewed[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewedItem(Map<String, dynamic> item) {
    final String imageUrl = item['image'] ?? '';
    final bool isAsset = item['isAsset'] == true;

    return GestureDetector(
      onTap: () {
        // Ürün detayına git
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isAsset
              ? Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.spa_outlined,
                      color: Colors.grey.shade300,
                      size: 30,
                    ),
                  ),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.spa_outlined,
                      color: Colors.grey.shade300,
                      size: 30,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPopularSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Popüler Aramalar',
                style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _popularSearches.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final search = _popularSearches[index];
              return _buildPopularSearchChip(
                search['text'],
                isHot: search['isHot'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSearchChip(String text, {bool isHot = false}) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHot) ...[
              Icon(
                Icons.local_fire_department,
                color: const Color(0xFFFF5722),
                size: 16,
              ),
              SizedBox(width: AppSpacing.xs),
            ],
            Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

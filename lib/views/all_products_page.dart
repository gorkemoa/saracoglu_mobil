import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../models/product/product_model.dart';
import 'product_detail_page.dart';

/// Ürün listesi türleri
enum ProductListType { newProducts, campaignProducts, allProducts, category }

/// Tüm ürünler / Yeni ürünler / Kampanyalı ürünler sayfası
class AllProductsPage extends StatefulWidget {
  final ProductListType listType;
  final String title;
  final int? categoryId;
  final String? categoryName;

  const AllProductsPage({
    super.key,
    this.listType = ProductListType.allProducts,
    this.title = 'Tüm Ürünler',
    this.categoryId,
    this.categoryName,
  });

  /// Yeni ürünler sayfası için factory constructor
  factory AllProductsPage.newProducts() {
    return const AllProductsPage(
      listType: ProductListType.newProducts,
      title: 'Yeni Ürünler',
    );
  }

  /// Kampanyalı ürünler sayfası için factory constructor
  factory AllProductsPage.campaignProducts() {
    return const AllProductsPage(
      listType: ProductListType.campaignProducts,
      title: 'Kampanyalı Ürünler',
    );
  }

  /// Kategori ürünleri sayfası için factory constructor
  factory AllProductsPage.category({
    required int categoryId,
    required String categoryName,
  }) {
    return AllProductsPage(
      listType: ProductListType.category,
      title: categoryName,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();

  List<ProductModel> _products = [];
  List<SortOption> _sortOptions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isLastPage = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  ProductSortKey _sortKey = ProductSortKey.sortNewToOld;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadSortOptions();
    _loadProducts();
  }

  /// Sıralama seçeneklerini yükle
  Future<void> _loadSortOptions() async {
    final options = await _productService.getSortList();
    if (mounted) {
      setState(() {
        _sortOptions = options;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll listener for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  /// İlk sayfa ürünlerini yükle
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _products = [];
    });

    // Yeni ürünler ve kampanyalı ürünler için tüm sayfaları yükle
    if (widget.listType == ProductListType.newProducts ||
        widget.listType == ProductListType.campaignProducts) {
      await _loadAllPages();
      return;
    }

    final response = await _fetchProducts(page: 1);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response != null) {
          _products = response.products;
          _totalPages = response.totalPages;
          _totalItems = response.totalItems;
          _isLastPage = response.isLastPage;
        } else {
          _errorMessage = 'Ürünler yüklenemedi';
        }
      });
    }
  }

  /// Tüm sayfaları yükle (410 dönene kadar)
  Future<void> _loadAllPages() async {
    List<ProductModel> allProducts = [];
    int currentPage = 1;
    bool isLast = false;

    while (!isLast && currentPage <= 20) {
      final response = await _fetchProducts(page: currentPage);

      if (response == null) {
        break;
      }

      allProducts.addAll(response.products);

      if (response.isLastPage) {
        isLast = true;
      } else {
        currentPage++;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _products = allProducts;
        _totalItems = allProducts.length;
        _totalPages = currentPage;
        _isLastPage = true; // Tüm sayfalar yüklendi
      });
    }
  }

  /// Daha fazla ürün yükle (pagination)
  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || _isLastPage || _currentPage >= _totalPages) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    final response = await _fetchProducts(page: nextPage);

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        if (response != null) {
          _currentPage = nextPage;
          _products.addAll(response.products);
          _isLastPage = response.isLastPage;
        }
      });
    }
  }

  /// Ürünleri API'den getir
  Future<ProductListResponse?> _fetchProducts({required int page}) async {
    switch (widget.listType) {
      case ProductListType.newProducts:
        return _productService.getNewProducts(page: page);

      case ProductListType.campaignProducts:
        return _productService.getCampaignProducts(page: page);

      case ProductListType.category:
        if (widget.categoryId != null) {
          return _productService.getCategoryProducts(
            categoryId: widget.categoryId!,
            page: page,
            sortKey: _sortKey,
          );
        }
        return _productService.getAllProducts(
          ProductFilter(sortKey: _sortKey, page: page),
        );

      case ProductListType.allProducts:
        return _productService.getAllProducts(
          ProductFilter(sortKey: _sortKey, page: page),
        );
    }
  }

  /// Sıralama değiştiğinde
  void _onSortChanged(ProductSortKey? newSortKey) {
    if (newSortKey != null && newSortKey != _sortKey) {
      setState(() {
        _sortKey = newSortKey;
      });
      _loadProducts();
    }
  }

  void _navigateToProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          // product: product,
        ),
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

  Future<void> _handleFavorite(String productName) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Favorilere eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.lightImpact();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('$productName favorilere eklendi')),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.title,
        style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: AppColors.textPrimary),
          onPressed: _showSortBottomSheet,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: _buildFilterBar(),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_totalItems ürün',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: _showSortBottomSheet,
            child: Row(
              children: [
                Icon(Icons.sort, size: 16, color: AppColors.textSecondary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  _getSortDisplayName(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Seçili sıralamanın görüntülenecek adını döndür
  String _getSortDisplayName() {
    if (_sortOptions.isNotEmpty) {
      final option = _sortOptions.firstWhere(
        (o) => o.sortKey == _sortKey,
        orElse: () =>
            SortOption(key: _sortKey.value, value: _sortKey.displayName),
      );
      return option.value;
    }
    return _sortKey.displayName;
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildSortBottomSheet(),
    );
  }

  Widget _buildSortBottomSheet() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sıralama', style: AppTypography.h4),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (_sortOptions.isNotEmpty)
            ..._sortOptions.map((option) => _buildSortOptionFromApi(option))
          else
            ...ProductSortKey.values.map(
              (sortKey) => _buildSortOption(sortKey),
            ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildSortOptionFromApi(SortOption option) {
    final isSelected = _sortKey == option.sortKey;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primary : AppColors.textTertiary,
      ),
      title: Text(
        option.value,
        style: AppTypography.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _onSortChanged(option.sortKey);
      },
    );
  }

  Widget _buildSortOption(ProductSortKey sortKey) {
    final isSelected = _sortKey == sortKey;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primary : AppColors.textTertiary,
      ),
      title: Text(
        sortKey.displayName,
        style: AppTypography.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _onSortChanged(sortKey);
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_products.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.primary,
      child: _buildProductGrid(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Ürünler yükleniyor...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
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
            onPressed: _loadProducts,
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Ürün bulunamadı',
            style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Daha sonra tekrar deneyin',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.56,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator for pagination
        if (index >= _products.length) {
          return _buildLoadingMoreIndicator();
        }

        final product = _products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    String? badgeText;
    Color? badgeColor;

    if (widget.listType == ProductListType.newProducts) {
      badgeText = 'YENİ';
      badgeColor = const Color(0xFF4CAF50);
    } else if (widget.listType == ProductListType.campaignProducts ||
        product.hasDiscount) {
      badgeText = product.discountBadgeText ?? 'KAMPANYA';
      badgeColor = const Color(0xFF7B2CBF);
    }

    return ProductCard(
      title: product.productName,
      weight: product.productExcerpt.isNotEmpty ? product.productExcerpt : '',
      price: product.priceAsDouble,
      oldPrice: product.hasDiscount ? product.discountPriceAsDouble : null,
      imageUrl: product.productImage,
      rating: product.ratingAsDouble,
      reviewCount: product.totalComments > 0 ? product.totalComments : null,
      badgeText: badgeText,
      badgeColor: badgeColor,
      isFavorite: product.isFavorite,
      onTap: () => _navigateToProductDetail(product),
      onAddToCart: () => _handleAddToCart(product.productName),
      onFavorite: () => _handleFavorite(product.productName),
    );
  }

  Widget _buildLoadingMoreIndicator() {
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
}

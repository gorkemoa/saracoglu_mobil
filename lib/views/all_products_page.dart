import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../services/product_service.dart';
import '../services/basket_service.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart';
import '../models/product/product_model.dart';
import '../models/product/category_model.dart';
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
  // Services
  final ProductService _productService = ProductService();
  final BasketService _basketService = BasketService();
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();

  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // State
  late ProductFilter _filter;
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<SortOption> _sortOptions = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isLastPage = false;

  int _totalItems = 0;
  String? _errorMessage;

  // Deboucer for price input prevents too many rebuilds if we add auto-search later
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeFilter();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _initializeFilter() {
    // Initial filter configuration based on page type
    ProductFilterType type = ProductFilterType.allProduct;
    int filterId = 0;
    ProductSortKey sort = ProductSortKey.sortNewToOld;

    switch (widget.listType) {
      case ProductListType.category:
        type = ProductFilterType.category;
        filterId = widget.categoryId ?? 0;
        break;
      case ProductListType.campaignProducts:
        sort = ProductSortKey.sortDiscounted;
        break;
      case ProductListType.newProducts:
        sort = ProductSortKey.sortNewToOld;
        break;
      case ProductListType.allProducts:
        break;
    }

    _filter = ProductFilter(
      userToken: _authService.token ?? '',
      filterType: type,
      filterID: filterId,
      sortKey: sort,
      page: 1,
    );
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Load Metadata (Categories, Sort Options) in parallel
      await Future.wait([_loadCategories(), _loadSortOptions()]);

      // Load Products
      await _loadProducts();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Veriler yüklenirken bir sorun oluştu.';
      });
    }
  }

  Future<void> _loadCategories() async {
    final cats = await _productService.getCategories();
    if (mounted) {
      setState(() => _categories = cats);
    }
  }

  Future<void> _loadSortOptions() async {
    final options = await _productService.getSortList();
    if (mounted) {
      setState(() => _sortOptions = options);
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _filter = _filter.copyWith(page: 1);
        _products.clear();
        _isLastPage = false;
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final response = await _productService.getAllProducts(_filter);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isLoadingMore = false;

      if (response != null) {
        if (_filter.page == 1) {
          _products = response.products;
          _totalItems = response.totalItems;
        } else {
          _products.addAll(response.products);
          // Sadece geçerli bir toplam sayı varsa güncelle (410 hatasında 0 gelebilir)
          if (response.totalItems > 0) {
            _totalItems = response.totalItems;
          }
        }
        _isLastPage = response.isLastPage;
      } else {
        if (_filter.page == 1) {
          _errorMessage =
              'Ürünler getirilemedi.\nLütfen internet bağlantınızı kontrol edin.';
        }
      }
    });

    // If it's a campaign or new products page, we might want to automatically
    // fetch more pages to fill the screen if the first page is scanty,
    // but standard pagination logic usually suffices.
  }

  void _onScroll() {
    if (_isLastPage || _isLoading || _isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      setState(() => _isLoadingMore = true);
      _filter = _filter.copyWith(page: _filter.page + 1);
      _loadProducts();
    }
  }

  Future<void> _applyFilters({
    ProductSortKey? sortKey,
    List<int>? categories,
    String? minPrice,
    String? maxPrice,
  }) async {
    setState(() {
      _filter = _filter.copyWith(
        sortKey: sortKey,
        categories: categories,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: 1, // Reset to page 1
      );
    });
    _loadProducts(refresh: true);
  }

  // --- Actions ---

  void _navigateToProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.productID),
      ),
    );
  }

  Future<void> _handleAddToCart(ProductModel product) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Sepete eklemek için giriş yapın',
    ))
      return;

    HapticFeedback.mediumImpact();
    final response = await _basketService.addToBasket(
      productId: product.productID,
    );

    if (!mounted) return;
    _showSnackBar(
      response?.message ?? 'İşlem başarısız',
      isSuccess: response?.success ?? false,
    );
  }

  Future<void> _handleFavorite(ProductModel product) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Favorilere eklemek için giriş yapın',
    ))
      return;

    HapticFeedback.lightImpact();
    final response = await _favoriteService.toggleFavorite(
      productId: product.productID,
    );

    if (!mounted) return;

    if (response != null && response.success) {
      setState(() {
        final index = _products.indexWhere(
          (p) => p.productID == product.productID,
        );
        if (index != -1) {
          _products[index] = _products[index].copyWith(
            isFavorite: response.isFavorite,
          );
        }
      });
    } else {
      _showSnackBar(response?.message ?? 'İşlem başarısız', isSuccess: false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          _buildFilterBar(),
        ],
        body: _buildBody(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.title,
        style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: AppColors.border, height: 1.0),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SliverPersistentHeader(
      delegate: _FilterBarDelegate(
        child: Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '$_totalItems Ürün',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Sort Button
              InkWell(
                onTap: () => _showFilterModal(initialTab: 0),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sort,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text('Sıralama', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              // Filter Button
              InkWell(
                onTap: () => _showFilterModal(initialTab: 1),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text('Filtrele', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async =>
          _applyFilters(), // Reset filters or just reload? Let's just reload with current filters.
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.54,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= _products.length) return null;
                return _buildProductItem(_products[index]);
              }, childCount: _products.length),
            ),
          ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          // Add some bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    // Badge Logic
    String? badgeText;
    Color? badgeColor;

    if (widget.listType == ProductListType.newProducts) {
      badgeText = 'YENİ';
      badgeColor = const Color(0xFF4CAF50);
    } else if (product.hasDiscount) {
      badgeText = product.discountBadgeText;
      badgeColor = const Color(0xFF7B2CBF);
    }

    return ProductCard(
      title: product.productName,
      weight: product.productExcerpt,
      price: product.priceAsDouble,
      oldPrice: product.hasDiscount ? product.discountPriceAsDouble : null,
      imageUrl: product.productImage,
      rating: product.ratingAsDouble,
      reviewCount: product.totalComments > 0 ? product.totalComments : null,
      badgeText: badgeText,
      badgeColor: badgeColor,
      isFavorite: product.isFavorite,
      onTap: () => _navigateToProductDetail(product),
      onAddToCart: () => _handleAddToCart(product),
      onFavorite: () => _handleFavorite(product),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç Bulunamadı',
            style: AppTypography.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Arama kriterlerinize uygun ürün yok.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              // Clear filters
              _initializeFilter();
              _loadInitialData();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            child: const Text('Filtreleri Temizle'),
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
          const Icon(Icons.wifi_off_rounded, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Bir Hata Oluştu', style: AppTypography.h3),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadProducts(refresh: true),
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

  // --- Filter Modal ---

  void _showFilterModal({int initialTab = 0}) {
    // Current temp state
    ProductSortKey tempSortKey = _filter.sortKey;
    List<int> tempCategories = List.from(_filter.categories);

    // Fill controllers with current values
    _minPriceController.text = _filter.minPrice;
    _maxPriceController.text = _filter.maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Modal Handle & Title
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filtrele ve Sırala', style: AppTypography.h3),
                      TextButton(
                        onPressed: () {
                          // Clear all
                          setStateModal(() {
                            tempSortKey = ProductSortKey.sortNewToOld;
                            tempCategories.clear();
                            _minPriceController.clear();
                            _maxPriceController.clear();
                          });
                        },
                        child: Text(
                          'Temizle',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Tabs
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    initialIndex: initialTab,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          tabs: const [
                            Tab(text: 'Sıralama'),
                            Tab(text: 'Kategoriler'),
                            Tab(text: 'Fiyat'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // SORT TAB
                              ListView(
                                padding: const EdgeInsets.all(16),
                                children: _sortOptions.isNotEmpty
                                    ? _sortOptions
                                          .map(
                                            (opt) => _buildSortOption(
                                              opt.value,
                                              opt.sortKey,
                                              tempSortKey,
                                              (val) => setStateModal(
                                                () => tempSortKey = val,
                                              ),
                                            ),
                                          )
                                          .toList()
                                    : ProductSortKey.values
                                          .map(
                                            (key) => _buildSortOption(
                                              key.displayName,
                                              key,
                                              tempSortKey,
                                              (val) => setStateModal(
                                                () => tempSortKey = val,
                                              ),
                                            ),
                                          )
                                          .toList(),
                              ),

                              // CATEGORY TAB
                              widget.listType == ProductListType.category
                                  ? Center(
                                      child: Text(
                                        "Kategori sayfasındasınız.\nDiğer kategorileri görmek için\nana menüye dönünüz.",
                                        textAlign: TextAlign.center,
                                        style: AppTypography.bodyMedium,
                                      ),
                                    )
                                  : ListView(
                                      padding: const EdgeInsets.all(16),
                                      children: _categories.map((cat) {
                                        final isSelected = tempCategories
                                            .contains(cat.catID);
                                        return CheckboxListTile(
                                          title: Text(
                                            cat.catName,
                                            style: AppTypography.bodyMedium,
                                          ),
                                          value: isSelected,
                                          activeColor: AppColors.primary,
                                          onChanged: (bool? value) {
                                            setStateModal(() {
                                              if (value == true) {
                                                tempCategories.add(cat.catID);
                                              } else {
                                                tempCategories.remove(
                                                  cat.catID,
                                                );
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),

                              // PRICE TAB
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fiyat Aralığı',
                                      style: AppTypography.h4,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _minPriceController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'En Az TL',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.currency_lira,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: _maxPriceController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'En Çok TL',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.currency_lira,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Apply Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters(
                            sortKey: tempSortKey,
                            categories: tempCategories,
                            minPrice: _minPriceController.text,
                            maxPrice: _maxPriceController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Uygula',
                          style: AppTypography.h4.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortOption(
    String label,
    ProductSortKey key,
    ProductSortKey groupValue,
    Function(ProductSortKey) onChanged,
  ) {
    return RadioListTile<ProductSortKey>(
      title: Text(label, style: AppTypography.bodyMedium),
      value: key,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}

// Helper for Sticky Header
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterBarDelegate({required this.child});

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: maxExtent, child: child);
  }

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) {
    return false;
  }
}

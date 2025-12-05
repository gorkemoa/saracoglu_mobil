import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../models/product/product_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// Ürün servisi
/// Ürün listesi, filtreleme ve sayfalama işlemlerini yönetir
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Kullanıcı token'ını al (giriş yapmışsa)
  String get _userToken => _authService.token ?? '';

  /// Tüm ürünleri getir
  /// [filter] - Filtre parametreleri
  /// Returns: ProductListResponse veya null (hata durumunda)
  Future<ProductListResponse?> getAllProducts(ProductFilter filter) async {
    try {
      // userToken boşsa otomatik olarak doldur
      final actualFilter = filter.userToken.isEmpty
          ? filter.copyWith(userToken: _userToken)
          : filter;

      _logger.i('📦 Ürünler getiriliyor - Sayfa: ${actualFilter.page}');
      _logger.d('📤 Request Body: ${actualFilter.toJson()}');

      final result = await _networkService.post(
        ApiConstants.getAllProducts,
        body: actualFilter.toJson(),
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      // 410 status code = son sayfa
      if (result.statusCode == 410) {
        _logger.i('📦 Son sayfaya ulaşıldı (410)');
        if (result.data != null) {
          return ProductListResponse.fromJson(result.data!, isLastPage: true);
        }
        return ProductListResponse(
          totalPages: 0,
          totalItems: 0,
          emptyMessage: 'Son sayfaya ulaşıldı',
          products: [],
          isLastPage: true,
        );
      }

      if (result.isSuccess && result.data != null) {
        final response = ProductListResponse.fromJson(result.data!);
        _logger.i(
          '✅ ${response.products.length} ürün getirildi (Toplam: ${response.totalItems}, Sayfa: ${actualFilter.page}/${response.totalPages})',
        );
        return response;
      }

      _logger.w('⚠️ Ürünler getirilemedi: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Ürün getirme hatası', error: e);
      return null;
    }
  }

  /// Yeni ürünleri getir (Yeniden eskiye sıralı) - tek sayfa
  /// [page] - Sayfa numarası
  Future<ProductListResponse?> getNewProducts({int page = 1}) async {
    final filter = ProductFilter(
      userToken: _userToken,
      filterType: ProductFilterType.allProduct,
      sortKey: ProductSortKey.sortNewToOld,
      page: page,
    );
    return getAllProducts(filter);
  }

  /// Kampanyalı ürünleri getir - tek sayfa
  /// [page] - Sayfa numarası
  Future<ProductListResponse?> getCampaignProducts({
    int page = 1,
    int? campaignCategoryId,
  }) async {
    // Kampanyalı ürünler için kategori filtresi kullanılıyorsa
    if (campaignCategoryId != null) {
      final filter = ProductFilter(
        userToken: _userToken,
        filterType: ProductFilterType.category,
        filterID: campaignCategoryId,
        sortKey: ProductSortKey.sortDiscounted,
        page: page,
      );
      return getAllProducts(filter);
    }

    // İndirimli ürünler sıralaması ile getir
    final filter = ProductFilter(
      userToken: _userToken,
      filterType: ProductFilterType.allProduct,
      sortKey: ProductSortKey.sortDiscounted,
      page: page,
    );

    final response = await getAllProducts(filter);
    if (response != null) {
      // Sadece indirimli ürünleri filtrele
      final campaignProducts = response.products
          .where((p) => p.hasDiscount)
          .toList();

      return ProductListResponse(
        totalPages: response.totalPages,
        totalItems: campaignProducts.length,
        emptyMessage: response.emptyMessage,
        products: campaignProducts,
        isLastPage: response.isLastPage,
      );
    }
    return null;
  }

  /// Kategori ürünlerini getir
  /// [categoryId] - Kategori ID
  /// [page] - Sayfa numarası
  Future<ProductListResponse?> getCategoryProducts({
    required int categoryId,
    int page = 1,
    ProductSortKey sortKey = ProductSortKey.sortNewToOld,
  }) async {
    final filter = ProductFilter(
      userToken: _userToken,
      filterType: ProductFilterType.category,
      filterID: categoryId,
      sortKey: sortKey,
      page: page,
    );
    return getAllProducts(filter);
  }

  /// Ürün ara
  /// [searchText] - Arama metni
  /// [page] - Sayfa numarası
  Future<ProductListResponse?> searchProducts({
    required String searchText,
    int page = 1,
    ProductSortKey sortKey = ProductSortKey.sortNewToOld,
  }) async {
    final filter = ProductFilter(
      userToken: _userToken,
      filterType: ProductFilterType.allProduct,
      searchText: searchText,
      sortKey: sortKey,
      page: page,
    );
    return getAllProducts(filter);
  }

  /// Fiyat aralığına göre ürün getir
  Future<ProductListResponse?> getProductsByPriceRange({
    required String minPrice,
    required String maxPrice,
    int page = 1,
    ProductSortKey sortKey = ProductSortKey.sortMinPrice,
  }) async {
    final filter = ProductFilter(
      userToken: _userToken,
      filterType: ProductFilterType.allProduct,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortKey: sortKey,
      page: page,
    );
    return getAllProducts(filter);
  }

  /// Tüm sayfaları çekerek tüm ürünleri getir (410 dönene kadar)
  /// [filter] - Base filter (page değeri override edilecek)
  /// [maxPages] - Maksimum çekilecek sayfa sayısı (sonsuz döngüden korunma)
  Future<List<ProductModel>> getAllPagesProducts(
    ProductFilter filter, {
    int maxPages = 20,
  }) async {
    List<ProductModel> allProducts = [];
    int currentPage = 1;

    _logger.i('📦 Tüm sayfalar yükleniyor (410 dönene kadar)...');

    while (currentPage <= maxPages) {
      // Her sayfa için userToken'ı güncelle
      final pageFilter = filter.copyWith(
        page: currentPage,
        userToken: _userToken,
      );
      final response = await getAllProducts(pageFilter);

      // 410 döndü veya hata varsa dur
      if (response == null) {
        _logger.i('📦 Sayfa $currentPage: Hata oluştu, durduruluyor');
        break;
      }

      if (response.isLastPage) {
        // Son sayfadaki ürünleri de ekle
        if (response.products.isNotEmpty) {
          allProducts.addAll(response.products);
          _logger.i(
            '📦 Sayfa $currentPage: ${response.products.length} ürün eklendi (SON SAYFA - 410)',
          );
        } else {
          _logger.i('📦 Sayfa $currentPage: Son sayfa (410), ürün yok');
        }
        break;
      }

      allProducts.addAll(response.products);
      _logger.i(
        '📦 Sayfa $currentPage/${response.totalPages}: ${response.products.length} ürün eklendi',
      );

      currentPage++;
    }

    _logger.i(
      '✅ Toplam ${allProducts.length} ürün yüklendi ($currentPage sayfa tarandı)',
    );
    return allProducts;
  }

  /// Tüm yeni ürünleri getir (tüm sayfalar)
  /// [maxProducts] - Maksimum döndürülecek ürün sayısı
  Future<List<ProductModel>> getAllNewProducts({int maxProducts = 20}) async {
    final filter = ProductFilter(
      userToken: _userToken,
      filterType: ProductFilterType.allProduct,
      sortKey: ProductSortKey.sortNewToOld,
      page: 1,
    );

    final allProducts = await getAllPagesProducts(filter);
    return allProducts.take(maxProducts).toList();
  }

  /// Tüm kampanyalı ürünleri getir (tüm sayfalar, indirimli olanlar)
  /// [maxProducts] - Maksimum döndürülecek ürün sayısı
  Future<List<ProductModel>> getAllCampaignProducts({
    int maxProducts = 20,
  }) async {
    final filter = ProductFilter(
      userToken: _userToken,
      filterType: ProductFilterType.allProduct,
      sortKey: ProductSortKey.sortDiscounted, // İndirimli ürünler sıralaması
      page: 1,
    );

    final allProducts = await getAllPagesProducts(filter);

    // Sadece indirimli ürünleri filtrele
    final campaignProducts = allProducts
        .where((p) => p.hasDiscount)
        .take(maxProducts)
        .toList();

    _logger.i('🔥 ${campaignProducts.length} kampanyalı ürün bulundu');
    return campaignProducts;
  }

  /// Sıralama listesini API'den getir
  /// Cache mekanizması ile tek seferlik çekilir
  List<SortOption>? _cachedSortList;

  Future<List<SortOption>> getSortList() async {
    // Cache varsa döndür
    if (_cachedSortList != null) {
      return _cachedSortList!;
    }

    try {
      _logger.i('📋 Sıralama listesi getiriliyor...');

      final result = await _networkService.get(ApiConstants.getSortList);

      if (result.isSuccess && result.data != null) {
        final data = result.data!['data'] as List?;
        if (data != null) {
          _cachedSortList = data
              .map((item) => SortOption.fromJson(item as Map<String, dynamic>))
              .toList();
          _logger.i('✅ ${_cachedSortList!.length} sıralama seçeneği yüklendi');
          return _cachedSortList!;
        }
      }

      _logger.w('⚠️ Sıralama listesi getirilemedi, varsayılan kullanılıyor');
      return _getDefaultSortList();
    } catch (e) {
      _logger.e('❌ Sıralama listesi hatası', error: e);
      return _getDefaultSortList();
    }
  }

  /// Varsayılan sıralama listesi (API erişilemezse)
  List<SortOption> _getDefaultSortList() {
    return [
      SortOption(key: 'sortDefault', value: 'Varsayılan'),
      SortOption(key: 'sortMinPrice', value: 'En Düşük Fiyat'),
      SortOption(key: 'sortMaxPrice', value: 'En Yüksek Fiyat'),
      SortOption(key: 'sortBestSellers', value: 'Çok Satanlar'),
      SortOption(key: 'sortBestReviewed', value: 'Çok Değerlendirilenler'),
      SortOption(key: 'sortDiscounted', value: 'İndirimli Ürünler'),
      SortOption(key: 'sortNewToOld', value: 'Yeniden Eskiye'),
      SortOption(key: 'sortOldToNew', value: 'Eskiden Yeniye'),
    ];
  }

  /// Cache'i temizle (gerektiğinde)
  void clearSortListCache() {
    _cachedSortList = null;
  }

  /// Ürün detayını getir
  /// [productId] - Ürün ID
  /// [variantId] - Varyant ID (opsiyonel)
  Future<ProductDetailResponse?> getProductDetail({
    required int productId,
    int? variantId,
  }) async {
    try {
      _logger.i('📦 Ürün detayı getiriliyor - ID: $productId');

      // Query parametrelerini oluştur
      String endpoint = '${ApiConstants.getProduct}/$productId';
      List<String> queryParams = [];

      // userToken ekle (opsiyonel ama favoriler için gerekli)
      if (_userToken.isNotEmpty) {
        queryParams.add('userToken=$_userToken');
      }

      // variantID ekle (opsiyonel)
      if (variantId != null) {
        queryParams.add('variantID=$variantId');
      }

      if (queryParams.isNotEmpty) {
        endpoint = '$endpoint?${queryParams.join('&')}';
      }

      _logger.d('📤 Request URL: $endpoint');

      final result = await _networkService.get(endpoint);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = ProductDetailResponse.fromJson(result.data!);
        if (response.success && response.product != null) {
          _logger.i(
            '✅ Ürün detayı getirildi: ${response.product!.productName}',
          );
          return response;
        }
      }

      _logger.w('⚠️ Ürün detayı getirilemedi: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Ürün detayı getirme hatası', error: e);
      return null;
    }
  }

  /// Ürün yorumlarını getir
  /// [productId] - Zorunlu: Ürün ID
  Future<ProductCommentsResponse?> getProductComments({
    required int productId,
  }) async {
    try {
      final endpoint = '${ApiConstants.getProductComments}/$productId';

      _logger.d('📤 Request URL: $endpoint');

      final result = await _networkService.get(endpoint);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = ProductCommentsResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Yorumlar getirildi: ${response.comments.length} yorum');
          return response;
        }
      }

      _logger.w('⚠️ Yorumlar getirilemedi: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Yorum getirme hatası', error: e);
      return null;
    }
  }
}

/// Ürün modeli
/// API'den gelen ürün verilerini temsil eder
class ProductModel {
  final int productID;
  final String productName;
  final String productExcerpt;
  final String productImage;
  final int productStock;
  final String productPrice;
  final String productPriceDiscount;
  final int productDiscountType;
  final String productDiscount;
  final String productDiscountIcon;
  final int totalComments;
  final String rating;
  final String varControl;
  final bool isFavorite;

  ProductModel({
    required this.productID,
    required this.productName,
    required this.productExcerpt,
    required this.productImage,
    required this.productStock,
    required this.productPrice,
    required this.productPriceDiscount,
    required this.productDiscountType,
    required this.productDiscount,
    required this.productDiscountIcon,
    required this.totalComments,
    required this.rating,
    required this.varControl,
    required this.isFavorite,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productID: json['productID'] ?? 0,
      productName: json['productName'] ?? '',
      productExcerpt: json['productExcerpt'] ?? '',
      productImage: json['productImage'] ?? '',
      productStock: json['productStock'] ?? 0,
      productPrice: json['productPrice']?.toString() ?? '0',
      productPriceDiscount: json['productPriceDiscount']?.toString() ?? '0,00',
      productDiscountType: json['productDiscountType'] ?? 0,
      productDiscount: json['productDiscount']?.toString() ?? '',
      productDiscountIcon: json['productDiscountIcon'] ?? '',
      totalComments: json['totalComments'] ?? 0,
      rating: json['rating']?.toString() ?? '',
      varControl: json['varControl'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'productExcerpt': productExcerpt,
      'productImage': productImage,
      'productStock': productStock,
      'productPrice': productPrice,
      'productPriceDiscount': productPriceDiscount,
      'productDiscountType': productDiscountType,
      'productDiscount': productDiscount,
      'productDiscountIcon': productDiscountIcon,
      'totalComments': totalComments,
      'rating': rating,
      'varControl': varControl,
      'isFavorite': isFavorite,
    };
  }

  /// Fiyatı double olarak döndürür
  double get priceAsDouble {
    return double.tryParse(
          productPrice.replaceAll(',', '.').replaceAll(' ', ''),
        ) ??
        0.0;
  }

  /// İndirimli fiyatı double olarak döndürür
  double get discountPriceAsDouble {
    final price =
        double.tryParse(
          productPriceDiscount.replaceAll(',', '.').replaceAll(' ', ''),
        ) ??
        0.0;
    return price;
  }

  /// İndirim var mı kontrolü
  bool get hasDiscount =>
      productDiscountType != 0 && productDiscount.isNotEmpty;

  /// İndirim badge metni
  String? get discountBadgeText {
    if (!hasDiscount) return null;
    return '$productDiscountIcon$productDiscount';
  }

  /// Rating'i double olarak döndürür
  double? get ratingAsDouble {
    if (rating.isEmpty) return null;
    return double.tryParse(rating.replaceAll(',', '.'));
  }

  /// Stokta mı kontrolü
  bool get isInStock => productStock > 0;

  ProductModel copyWith({
    int? productID,
    String? productName,
    String? productExcerpt,
    String? productImage,
    int? productStock,
    String? productPrice,
    String? productPriceDiscount,
    int? productDiscountType,
    String? productDiscount,
    String? productDiscountIcon,
    int? totalComments,
    String? rating,
    String? varControl,
    bool? isFavorite,
  }) {
    return ProductModel(
      productID: productID ?? this.productID,
      productName: productName ?? this.productName,
      productExcerpt: productExcerpt ?? this.productExcerpt,
      productImage: productImage ?? this.productImage,
      productStock: productStock ?? this.productStock,
      productPrice: productPrice ?? this.productPrice,
      productPriceDiscount: productPriceDiscount ?? this.productPriceDiscount,
      productDiscountType: productDiscountType ?? this.productDiscountType,
      productDiscount: productDiscount ?? this.productDiscount,
      productDiscountIcon: productDiscountIcon ?? this.productDiscountIcon,
      totalComments: totalComments ?? this.totalComments,
      rating: rating ?? this.rating,
      varControl: varControl ?? this.varControl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Ürün listesi yanıt modeli
class ProductListResponse {
  final int totalPages;
  final int totalItems;
  final String emptyMessage;
  final List<ProductModel> products;
  final bool isLastPage;

  ProductListResponse({
    required this.totalPages,
    required this.totalItems,
    required this.emptyMessage,
    required this.products,
    this.isLastPage = false,
  });

  factory ProductListResponse.fromJson(
    Map<String, dynamic> json, {
    bool isLastPage = false,
  }) {
    final data = json['data'] as Map<String, dynamic>?;

    List<ProductModel> productList = [];
    if (data != null && data['products'] != null) {
      productList = (data['products'] as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ProductListResponse(
      totalPages: data?['totalPages'] ?? 0,
      totalItems: data?['totalItems'] ?? 0,
      emptyMessage: data?['emptyMessage'] ?? '',
      products: productList,
      isLastPage: isLastPage,
    );
  }

  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;
}

/// Ürün filtre tipleri
enum ProductFilterType { allProduct, category }

extension ProductFilterTypeExtension on ProductFilterType {
  String get value {
    switch (this) {
      case ProductFilterType.allProduct:
        return 'allproduct';
      case ProductFilterType.category:
        return 'category';
    }
  }
}

/// Ürün sıralama tipleri (Backend'den gelen değerlerle uyumlu)
enum ProductSortKey {
  sortDefault,
  sortMinPrice,
  sortMaxPrice,
  sortBestSellers,
  sortBestReviewed,
  sortDiscounted,
  sortNewToOld,
  sortOldToNew,
}

extension ProductSortKeyExtension on ProductSortKey {
  String get value {
    switch (this) {
      case ProductSortKey.sortDefault:
        return 'sortDefault';
      case ProductSortKey.sortMinPrice:
        return 'sortMinPrice';
      case ProductSortKey.sortMaxPrice:
        return 'sortMaxPrice';
      case ProductSortKey.sortBestSellers:
        return 'sortBestSellers';
      case ProductSortKey.sortBestReviewed:
        return 'sortBestReviewed';
      case ProductSortKey.sortDiscounted:
        return 'sortDiscounted';
      case ProductSortKey.sortNewToOld:
        return 'sortNewToOld';
      case ProductSortKey.sortOldToNew:
        return 'sortOldToNew';
    }
  }

  String get displayName {
    switch (this) {
      case ProductSortKey.sortDefault:
        return 'Varsayılan';
      case ProductSortKey.sortMinPrice:
        return 'En Düşük Fiyat';
      case ProductSortKey.sortMaxPrice:
        return 'En Yüksek Fiyat';
      case ProductSortKey.sortBestSellers:
        return 'Çok Satanlar';
      case ProductSortKey.sortBestReviewed:
        return 'Çok Değerlendirilenler';
      case ProductSortKey.sortDiscounted:
        return 'İndirimli Ürünler';
      case ProductSortKey.sortNewToOld:
        return 'Yeniden Eskiye';
      case ProductSortKey.sortOldToNew:
        return 'Eskiden Yeniye';
    }
  }

  /// API key'den enum'a dönüştür
  static ProductSortKey fromKey(String key) {
    switch (key) {
      case 'sortDefault':
        return ProductSortKey.sortDefault;
      case 'sortMinPrice':
        return ProductSortKey.sortMinPrice;
      case 'sortMaxPrice':
        return ProductSortKey.sortMaxPrice;
      case 'sortBestSellers':
        return ProductSortKey.sortBestSellers;
      case 'sortBestReviewed':
        return ProductSortKey.sortBestReviewed;
      case 'sortDiscounted':
        return ProductSortKey.sortDiscounted;
      case 'sortNewToOld':
        return ProductSortKey.sortNewToOld;
      case 'sortOldToNew':
        return ProductSortKey.sortOldToNew;
      default:
        return ProductSortKey.sortDefault;
    }
  }
}

/// Sıralama seçeneği modeli (API'den gelen)
class SortOption {
  final String key;
  final String value;

  SortOption({required this.key, required this.value});

  factory SortOption.fromJson(Map<String, dynamic> json) {
    return SortOption(key: json['key'] ?? '', value: json['value'] ?? '');
  }

  ProductSortKey get sortKey => ProductSortKeyExtension.fromKey(key);
}

/// Ürün filtre modeli
class ProductFilter {
  final String userToken;
  final ProductFilterType filterType;
  final int filterID;
  final List<int> categories;
  final List<int> variants;
  final List<int> contents;
  final String minPrice;
  final String maxPrice;
  final ProductSortKey sortKey;
  final String searchText;
  final int page;

  ProductFilter({
    this.userToken = '',
    this.filterType = ProductFilterType.allProduct,
    this.filterID = 0,
    this.categories = const [],
    this.variants = const [],
    this.contents = const [],
    this.minPrice = '',
    this.maxPrice = '',
    this.sortKey = ProductSortKey.sortNewToOld,
    this.searchText = '',
    this.page = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'filterType': filterType.value,
      'filterID': filterID,
      'categories': categories,
      'variants': variants,
      'contents': contents,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'sortKey': sortKey.value,
      'searchText': searchText,
      'page': page,
    };
  }

  ProductFilter copyWith({
    String? userToken,
    ProductFilterType? filterType,
    int? filterID,
    List<int>? categories,
    List<int>? variants,
    List<int>? contents,
    String? minPrice,
    String? maxPrice,
    ProductSortKey? sortKey,
    String? searchText,
    int? page,
  }) {
    return ProductFilter(
      userToken: userToken ?? this.userToken,
      filterType: filterType ?? this.filterType,
      filterID: filterID ?? this.filterID,
      categories: categories ?? this.categories,
      variants: variants ?? this.variants,
      contents: contents ?? this.contents,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortKey: sortKey ?? this.sortKey,
      searchText: searchText ?? this.searchText,
      page: page ?? this.page,
    );
  }
}

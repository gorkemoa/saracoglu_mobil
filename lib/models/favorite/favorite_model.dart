/// Favori ürün modeli
class FavoriteProduct {
  final int favoriteID;
  final int userID;
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
  final String createdDate;
  final bool isFavorite;

  FavoriteProduct({
    required this.favoriteID,
    required this.userID,
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
    required this.createdDate,
    required this.isFavorite,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      favoriteID: json['favoriteID'] ?? 0,
      userID: json['userID'] ?? 0,
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
      createdDate: json['createdDate'] ?? '',
      isFavorite: json['isFavorite'] ?? true,
    );
  }

  /// Fiyatı double olarak döndürür
  double get priceAsDouble {
    String cleanPrice = productPrice
        .replaceAll('TL', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  /// İndirimli fiyatı double olarak döndürür
  double get discountPriceAsDouble {
    String cleanPrice = productPriceDiscount
        .replaceAll('TL', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  /// İndirim var mı kontrolü
  bool get hasDiscount =>
      productDiscountType != 0 && productDiscount.isNotEmpty;

  /// Rating'i double olarak döndürür
  double? get ratingAsDouble {
    if (rating.isEmpty) return null;
    return double.tryParse(rating.replaceAll(',', '.'));
  }

  /// Stokta mı kontrolü
  bool get isInStock => productStock > 0;
}

/// Favoriler listesi response modeli
class FavoritesResponse {
  final int totalItems;
  final String emptyMessage;
  final List<FavoriteProduct> favoriteProducts;
  final bool error;
  final bool success;

  FavoritesResponse({
    required this.totalItems,
    required this.emptyMessage,
    required this.favoriteProducts,
    required this.error,
    required this.success,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    List<FavoriteProduct> products = [];
    if (data != null && data['favoriteProducts'] != null) {
      products = (data['favoriteProducts'] as List)
          .map((item) => FavoriteProduct.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return FavoritesResponse(
      totalItems: data?['totalItems'] ?? 0,
      emptyMessage: data?['emptyMessage'] ?? '',
      favoriteProducts: products,
      error: json['error'] ?? true,
      success: json['success'] ?? false,
    );
  }

  bool get isEmpty => favoriteProducts.isEmpty;
  bool get isNotEmpty => favoriteProducts.isNotEmpty;
}

/// Favori toggle request modeli
class ToggleFavoriteRequest {
  final String userToken;
  final int productID;

  ToggleFavoriteRequest({required this.userToken, required this.productID});

  Map<String, dynamic> toJson() {
    return {'userToken': userToken, 'productID': productID};
  }
}

/// Favori toggle response modeli
class ToggleFavoriteResponse {
  final bool error;
  final bool success;
  final String message;
  final bool isFavorite;

  ToggleFavoriteResponse({
    required this.error,
    required this.success,
    required this.message,
    required this.isFavorite,
  });

  factory ToggleFavoriteResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return ToggleFavoriteResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isFavorite: data?['isFavorite'] ?? false,
    );
  }
}

/// Sepete ürün ekleme request modeli
class AddToBasketRequest {
  final String userToken;
  final int productID;
  final int quantity;
  final int variantID;

  AddToBasketRequest({
    required this.userToken,
    required this.productID,
    this.quantity = 1,
    this.variantID = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'productID': productID,
      'quantity': quantity,
      'variantID': variantID,
    };
  }
}

/// Sepete ürün ekleme response modeli
class AddToBasketResponse {
  final bool error;
  final bool success;
  final String message;

  AddToBasketResponse({
    required this.error,
    required this.success,
    required this.message,
  });

  factory AddToBasketResponse.fromJson(Map<String, dynamic> json) {
    return AddToBasketResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

/// Kullanıcı sepet listesi response modeli
class UserBasketResponse {
  final bool error;
  final bool success;
  final BasketData? data;

  UserBasketResponse({required this.error, required this.success, this.data});

  factory UserBasketResponse.fromJson(Map<String, dynamic> json) {
    return UserBasketResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? BasketData.fromJson(json['data']) : null,
    );
  }
}

/// Sepet verileri modeli
class BasketData {
  final String vatRate;
  final String cartTotal;
  final String subtotal;
  final String vatAmount;
  final String cargoPrice;
  final String discountAmount;
  final String grandTotal;
  final String cargoLimitPrice;
  final String remainingForFreeCargo;
  final bool isFreeShipping;
  final int totalItems;
  final List<BasketItem> baskets;

  BasketData({
    required this.vatRate,
    required this.cartTotal,
    required this.subtotal,
    required this.vatAmount,
    required this.cargoPrice,
    required this.discountAmount,
    required this.grandTotal,
    required this.cargoLimitPrice,
    required this.remainingForFreeCargo,
    required this.isFreeShipping,
    required this.totalItems,
    required this.baskets,
  });

  factory BasketData.fromJson(Map<String, dynamic> json) {
    return BasketData(
      vatRate: json['vatRate'] ?? '',
      cartTotal: json['cartTotal'] ?? '0,00 TL',
      subtotal: json['subtotal'] ?? '0,00 TL',
      vatAmount: json['vatAmount'] ?? '0,00 TL',
      cargoPrice: json['cargoPrice'] ?? '0,00 TL',
      discountAmount: json['discountAmount'] ?? '0,00 TL',
      grandTotal: json['grandTotal'] ?? '0,00 TL',
      cargoLimitPrice: json['cargoLimitPrice'] ?? '0,00 TL',
      remainingForFreeCargo: json['remainingForFreeCargo'] ?? '0,00 TL',
      isFreeShipping: json['isFreeShipping'] ?? false,
      totalItems: json['totalItems'] ?? 0,
      baskets:
          (json['baskets'] as List<dynamic>?)
              ?.map((e) => BasketItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// Kargo ücretsiz mi?
  bool get hasFreeShipping => isFreeShipping;

  /// Sepet boş mu?
  bool get isEmpty => baskets.isEmpty;
}

/// Sepet ürün modeli
class BasketItem {
  final int userID;
  final int cartID;
  final int productID;
  final int variantID;
  final String productTitle;
  final String productShortDesc;
  final String productDesc;
  final String productImage;
  final int cartQuantity;
  final String productPrice;
  final String productPriceDiscount;
  final String productDiscount;
  final String productDiscountIcon;
  final String retailPrice;
  final String totalPrice;
  final List<dynamic> variant;
  final String cartDate;

  BasketItem({
    required this.userID,
    required this.cartID,
    required this.productID,
    required this.variantID,
    required this.productTitle,
    required this.productShortDesc,
    required this.productDesc,
    required this.productImage,
    required this.cartQuantity,
    required this.productPrice,
    required this.productPriceDiscount,
    required this.retailPrice,
    required this.totalPrice,
    required this.productDiscount,
    required this.productDiscountIcon,
    required this.variant,
    required this.cartDate,
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    return BasketItem(
      userID: json['userID'] ?? 0,
      cartID: json['cartID'] ?? 0,
      productID: json['productID'] ?? 0,
      variantID: json['variantID'] ?? 0,
      productTitle: json['productTitle'] ?? '',
      productShortDesc: json['productShortDesc'] ?? '',
      productDesc: json['productDesc'] ?? '',
      productImage: json['productImage'] ?? '',
      cartQuantity: json['cartQuantity'] ?? 0,
      productPrice: json['productPrice'] ?? '0,00 TL',
      productPriceDiscount: json['productPriceDiscount'] ?? '',
      retailPrice: json['retailPrice'] ?? '0,00 TL',
      totalPrice: json['totalPrice'] ?? '0,00 TL',
      productDiscount: json['productDiscount'] ?? '',
      productDiscountIcon: json['productDiscountIcon'] ?? '',
      variant: json['variant'] ?? [],
      cartDate: json['cartDate'] ?? '',
    );
  }

  /// Fiyatı double olarak al (parsing)
  double get priceAsDouble {
    return _parsePrice(productPrice);
  }

  /// İndirimli fiyatı double olarak al (parsing)
  double get discountPriceAsDouble {
    return _parsePrice(productPriceDiscount);
  }

  /// Toplam fiyatı double olarak al (parsing)
  double get totalPriceAsDouble {
    return _parsePrice(totalPrice);
  }

  /// İndirim yüzdesi
  int? get discountPercentage {
    if (productDiscount.isNotEmpty) {
      return int.tryParse(productDiscount);
    }
    return null;
  }

  /// İndirimli ürün mü?
  bool get hasDiscount =>
      productPriceDiscount.isNotEmpty && productDiscount.isNotEmpty;

  /// Fiyat string'ini double'a çevir
  double _parsePrice(String priceStr) {
    if (priceStr.isEmpty) return 0.0;
    // "385,00 TL" -> 385.00
    String cleaned = priceStr
        .replaceAll('TL', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}

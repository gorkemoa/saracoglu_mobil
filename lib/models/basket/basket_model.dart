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

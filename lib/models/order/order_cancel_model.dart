class OrderCancelResponse {
  final bool success;
  final bool error;
  final String? message;
  final OrderCancelData? data;

  OrderCancelResponse({
    required this.success,
    required this.error,
    this.message,
    this.data,
  });

  factory OrderCancelResponse.fromJson(Map<String, dynamic> json) {
    return OrderCancelResponse(
      success: json['success'] ?? false,
      error: json['error'] ?? false,
      message: json['success_message'] ?? json['message'],
      data: json['data'] != null
          ? OrderCancelData.fromJson(json['data'])
          : null,
    );
  }

  factory OrderCancelResponse.errorResponse(String message) {
    return OrderCancelResponse(success: false, error: true, message: message);
  }
}

class OrderCancelData {
  final int orderID;
  final String orderStatus;
  final bool hasActiveProducts;
  final List<CanceledProduct> canceledProducts;

  OrderCancelData({
    required this.orderID,
    required this.orderStatus,
    required this.hasActiveProducts,
    required this.canceledProducts,
  });

  factory OrderCancelData.fromJson(Map<String, dynamic> json) {
    return OrderCancelData(
      orderID: json['orderID'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
      hasActiveProducts: json['hasActiveProducts'] ?? false,
      canceledProducts: json['canceledProducts'] != null
          ? (json['canceledProducts'] as List)
                .map((e) => CanceledProduct.fromJson(e))
                .toList()
          : [],
    );
  }
}

class CanceledProduct {
  final int productID;
  final int productQuantity;
  final String productStatus;

  CanceledProduct({
    required this.productID,
    required this.productQuantity,
    required this.productStatus,
  });

  factory CanceledProduct.fromJson(Map<String, dynamic> json) {
    return CanceledProduct(
      productID: json['productID'] ?? 0,
      productQuantity: json['productQuantity'] ?? 0,
      productStatus: json['productStatus'] ?? '',
    );
  }
}

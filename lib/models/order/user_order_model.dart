/// Sipariş ürünü modeli
class OrderProduct {
  final int productID;
  final String productName;
  final String productVariants;
  final String productVarControl;
  final String productImage;
  final int productStatus;
  final String productStatusText;
  final int productQuantity;
  final int productCancelQuantity;
  final int productCurrentQuantity;
  final String productPrice;
  final String productCargoAmount;
  final String productCancelDate;
  final bool productIsCanceled;
  final String productCancelDesc;

  OrderProduct({
    required this.productID,
    required this.productName,
    required this.productVariants,
    required this.productVarControl,
    required this.productImage,
    required this.productStatus,
    required this.productStatusText,
    required this.productQuantity,
    required this.productCancelQuantity,
    required this.productCurrentQuantity,
    required this.productPrice,
    required this.productCargoAmount,
    required this.productCancelDate,
    required this.productIsCanceled,
    required this.productCancelDesc,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productID: json['productID'] ?? 0,
      productName: json['productName'] ?? '',
      productVariants: json['productVariants'] ?? '',
      productVarControl: json['productVarControl'] ?? '',
      productImage: json['productImage'] ?? '',
      productStatus: json['productStatus'] ?? 0,
      productStatusText: json['productStatusText'] ?? '',
      productQuantity: json['productQuantity'] ?? 0,
      productCancelQuantity: json['productCancelQuantity'] ?? 0,
      productCurrentQuantity: json['productCurrentQuantity'] ?? 0,
      productPrice: json['productPrice'] ?? '',
      productCargoAmount: json['productCargoAmount'] ?? '',
      productCancelDate: json['productCancelDate'] ?? '',
      productIsCanceled: json['productIsCanceled'] ?? false,
      productCancelDesc: json['productCancelDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'productVariants': productVariants,
      'productVarControl': productVarControl,
      'productImage': productImage,
      'productStatus': productStatus,
      'productStatusText': productStatusText,
      'productQuantity': productQuantity,
      'productCancelQuantity': productCancelQuantity,
      'productCurrentQuantity': productCurrentQuantity,
      'productPrice': productPrice,
      'productCargoAmount': productCargoAmount,
      'productCancelDate': productCancelDate,
      'productIsCanceled': productIsCanceled,
      'productCancelDesc': productCancelDesc,
    };
  }
}

/// Sipariş modeli
class UserOrder {
  final int orderID;
  final String orderCode;
  final String orderAmount;
  final String orderDiscount;
  final String orderDesc;
  final String orderPayment;
  final int orderStatusID;
  final String orderStatusTitle;
  final String orderStatusColor;
  final String orderDate;
  final String orderDeliveryDate;
  final String orderInvoice;
  final bool isCanceled;
  final int totalProduct;
  final List<OrderProduct> products;

  UserOrder({
    required this.orderID,
    required this.orderCode,
    required this.orderAmount,
    required this.orderDiscount,
    required this.orderDesc,
    required this.orderPayment,
    required this.orderStatusID,
    required this.orderStatusTitle,
    required this.orderStatusColor,
    required this.orderDate,
    required this.orderDeliveryDate,
    required this.orderInvoice,
    required this.isCanceled,
    required this.totalProduct,
    required this.products,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      orderID: json['orderID'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderAmount: json['orderAmount'] ?? '',
      orderDiscount: json['orderDiscount'] ?? '',
      orderDesc: json['orderDesc'] ?? '',
      orderPayment: json['orderPayment'] ?? '',
      orderStatusID: json['orderStatusID'] ?? 0,
      orderStatusTitle: json['orderStatusTitle'] ?? '',
      orderStatusColor: json['orderStatusColor'] ?? '#000000',
      orderDate: json['orderDate'] ?? '',
      orderDeliveryDate: json['orderDeliveryDate'] ?? '',
      orderInvoice: json['orderInvoice'] ?? '',
      isCanceled: json['isCanceled'] ?? false,
      totalProduct: json['totalProduct'] ?? 0,
      products: json['products'] != null
          ? (json['products'] as List)
                .map((p) => OrderProduct.fromJson(p))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'orderCode': orderCode,
      'orderAmount': orderAmount,
      'orderDiscount': orderDiscount,
      'orderDesc': orderDesc,
      'orderPayment': orderPayment,
      'orderStatusID': orderStatusID,
      'orderStatusTitle': orderStatusTitle,
      'orderStatusColor': orderStatusColor,
      'orderDate': orderDate,
      'orderDeliveryDate': orderDeliveryDate,
      'orderInvoice': orderInvoice,
      'isCanceled': isCanceled,
      'totalProduct': totalProduct,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }

  /// Sipariş aktif mi? (Yeni, Tedarik, Hazırlanıyor, Kargoya Verildi)
  bool get isActive => orderStatusID >= 1 && orderStatusID <= 4;

  /// Sipariş tamamlandı mı? (Onaylandı)
  bool get isCompleted => orderStatusID == 5;

  /// Sipariş iptal edildi mi? (İptal veya üye tarafından iptal)
  bool get isCancelledStatus => orderStatusID == 6 || orderStatusID == 7;

  /// İade durumunda mı? (İade talep, kargo, inceleme, edildi, reddedildi)
  bool get isReturnStatus => orderStatusID >= 8 && orderStatusID <= 12;

  /// Toplam iptal/iade edilen ürün sayısı
  int get totalCanceledProduct =>
      products.fold(0, (sum, product) => sum + product.productCancelQuantity);
}

/// Kullanıcı siparişleri response modeli
class UserOrdersResponse {
  final bool isSuccess;
  final String? message;
  final String? emptyMessage;
  final int totalOrders;
  final List<UserOrder> orders;

  UserOrdersResponse({
    required this.isSuccess,
    this.message,
    this.emptyMessage,
    required this.totalOrders,
    required this.orders,
  });

  factory UserOrdersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final isSuccess = json['success'] == true;

    if (data == null) {
      return UserOrdersResponse(
        isSuccess: isSuccess,
        message: json['message'],
        totalOrders: 0,
        orders: [],
      );
    }

    return UserOrdersResponse(
      isSuccess: isSuccess,
      message: data['message'],
      emptyMessage: data['emptyMessage'],

      totalOrders: data['totalOrders'] ?? 0,
      orders: data['orders'] != null
          ? (data['orders'] as List).map((o) => UserOrder.fromJson(o)).toList()
          : [],
    );
  }

  factory UserOrdersResponse.errorResponse(String message) {
    return UserOrdersResponse(
      isSuccess: false,
      message: message,
      totalOrders: 0,
      orders: [],
    );
  }

  /// Aktif siparişler (statusID: 1-4)
  List<UserOrder> get activeOrders => orders.where((o) => o.isActive).toList();

  /// Tamamlanan siparişler (statusID: 5)
  List<UserOrder> get completedOrders =>
      orders.where((o) => o.isCompleted).toList();

  /// İptal edilen siparişler (statusID: 6-7)
  List<UserOrder> get cancelledOrders =>
      orders.where((o) => o.isCancelledStatus).toList();

  /// İade siparişleri (statusID: 8-12)
  List<UserOrder> get returnOrders =>
      orders.where((o) => o.isReturnStatus).toList();
}

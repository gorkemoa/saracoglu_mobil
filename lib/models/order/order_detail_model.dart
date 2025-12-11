/// Sipariş detay ürünü modeli (daha detaylı bilgiler içerir)
class OrderDetailProduct {
  final int productID;
  final String productName;
  final String productVariants;
  final String varControl;
  final String productImage;
  final int productStatus;
  final String productStatusText;
  final String productStatusName;
  final String productStatusColor;
  final int productQuantity;
  final int productCancelQuantity;
  final int productCurrentQuantity;
  final String cargoCompany;
  final String trackingNumber;
  final String trackingURL;
  final String productPrice;
  final String productCargoPrice;
  final String productNotes;
  final String cancelDesc;
  final String cancelDate;
  final bool isCancelable;
  final bool isCargo;
  final bool isRating;
  final bool isCanceled;

  OrderDetailProduct({
    required this.productID,
    required this.productName,
    required this.productVariants,
    required this.varControl,
    required this.productImage,
    required this.productStatus,
    required this.productStatusText,
    required this.productStatusName,
    required this.productStatusColor,
    required this.productQuantity,
    required this.productCancelQuantity,
    required this.productCurrentQuantity,
    required this.cargoCompany,
    required this.trackingNumber,
    required this.trackingURL,
    required this.productPrice,
    required this.productCargoPrice,
    required this.productNotes,
    required this.cancelDesc,
    required this.cancelDate,
    required this.isCancelable,
    required this.isCargo,
    required this.isRating,
    required this.isCanceled,
  });

  factory OrderDetailProduct.fromJson(Map<String, dynamic> json) {
    return OrderDetailProduct(
      productID: json['productID'] ?? 0,
      productName: json['productName'] ?? '',
      productVariants: json['productVariants'] ?? '',
      varControl: json['varControl'] ?? '',
      productImage: json['productImage'] ?? '',
      productStatus: json['productStatus'] ?? 0,
      productStatusText: json['productStatusText'] ?? '',
      productStatusName: json['productStatusName'] ?? '',
      productStatusColor: json['productStatusColor'] ?? '#000000',
      productQuantity: json['productQuantity'] ?? 0,
      productCancelQuantity: json['productCancelQuantity'] ?? 0,
      productCurrentQuantity: json['productCurrentQuantity'] ?? 0,
      cargoCompany: json['cargoCompany'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      trackingURL: json['trackingURL'] ?? '',
      productPrice: json['productPrice'] ?? '',
      productCargoPrice: json['productCargoPrice'] ?? '',
      productNotes: json['productNotes'] ?? '',
      cancelDesc: json['cancelDesc'] ?? '',
      cancelDate: json['cancelDate'] ?? '',
      isCancelable: json['isCancelable'] ?? false,
      isCargo: json['isCargo'] ?? false,
      isRating: json['isRating'] ?? false,
      isCanceled: json['isCanceled'] ?? false,
    );
  }
}

/// Sipariş adresi modeli
class OrderAddress {
  final int addressID;
  final String addressTitle;
  final String addressName;
  final int addressTypeID;
  final String addressType;
  final String addressPhone;
  final String addressEmail;
  final String addressCity;
  final int addressCityID;
  final String addressDistrict;
  final int addressDistrictID;
  final String addressNeighbourhood;
  final int addressNeighbourhoodID;
  final String address;
  final String invoiceAddress;
  final String identityNumber;
  final String realCompanyName;
  final String taxNumber;
  final String taxAdministration;

  OrderAddress({
    required this.addressID,
    required this.addressTitle,
    required this.addressName,
    required this.addressTypeID,
    required this.addressType,
    required this.addressPhone,
    required this.addressEmail,
    required this.addressCity,
    required this.addressCityID,
    required this.addressDistrict,
    required this.addressDistrictID,
    required this.addressNeighbourhood,
    required this.addressNeighbourhoodID,
    required this.address,
    required this.invoiceAddress,
    required this.identityNumber,
    required this.realCompanyName,
    required this.taxNumber,
    required this.taxAdministration,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      addressID: json['addressID'] ?? 0,
      addressTitle: json['addressTitle'] ?? '',
      addressName: json['addressName'] ?? '',
      addressTypeID: json['addressTypeID'] ?? 0,
      addressType: json['addressType'] ?? '',
      addressPhone: json['addressPhone'] ?? '',
      addressEmail: json['addressEmail'] ?? '',
      addressCity: json['addressCity'] ?? '',
      addressCityID: json['addressCityID'] ?? 0,
      addressDistrict: json['addressDistrict'] ?? '',
      addressDistrictID: json['addressDistrictID'] ?? 0,
      addressNeighbourhood: json['addressNeighbourhood'] ?? '',
      addressNeighbourhoodID: json['addressNeighbourhoodID'] ?? 0,
      address: json['address'] ?? '',
      invoiceAddress: json['invoiceAddress'] ?? '',
      identityNumber: json['identityNumber'] ?? '',
      realCompanyName: json['realCompanyName'] ?? '',
      taxNumber: json['taxNumber'] ?? '',
      taxAdministration: json['taxAdministration'] ?? '',
    );
  }
}

/// Sipariş adresleri modeli
class OrderAddresses {
  final OrderAddress? shipping;
  final OrderAddress? billing;

  OrderAddresses({this.shipping, this.billing});

  factory OrderAddresses.fromJson(Map<String, dynamic> json) {
    return OrderAddresses(
      shipping: json['shipping'] != null
          ? OrderAddress.fromJson(json['shipping'])
          : null,
      billing: json['billing'] != null
          ? OrderAddress.fromJson(json['billing'])
          : null,
    );
  }
}

/// Kart bilgisi modeli
class OrderCardInfo {
  final String cardNumber;
  final String cardHolder;
  final String cardAssociation;
  final String cardBankName;

  OrderCardInfo({
    required this.cardNumber,
    required this.cardHolder,
    required this.cardAssociation,
    required this.cardBankName,
  });

  factory OrderCardInfo.fromJson(Map<String, dynamic> json) {
    return OrderCardInfo(
      cardNumber: json['cardNumber'] ?? '',
      cardHolder: json['cardHolder'] ?? '',
      cardAssociation: json['cardAssociation'] ?? '',
      cardBankName: json['cardBankName'] ?? '',
    );
  }
}

/// Sipariş detay modeli
class OrderDetail {
  final int orderID;
  final String orderCode;
  final String orderAmount;
  final String orderDiscount;
  final String orderDesc;
  final String orderPaymentType;
  final int stateOrder;
  final String orderStatusID;
  final String orderStatus;
  final String orderStatusColor;
  final String orderDate;
  final String deliveryDate;
  final String orderInvoice;
  final bool isCanceled;
  final bool isCancelVisible;
  final String salesAgreement;
  final List<OrderDetailProduct> products;
  final OrderAddresses? addresses;
  final OrderCardInfo? cardInfo;

  OrderDetail({
    required this.orderID,
    required this.orderCode,
    required this.orderAmount,
    required this.orderDiscount,
    required this.orderDesc,
    required this.orderPaymentType,
    required this.stateOrder,
    required this.orderStatusID,
    required this.orderStatus,
    required this.orderStatusColor,
    required this.orderDate,
    required this.deliveryDate,
    required this.orderInvoice,
    required this.isCanceled,
    required this.isCancelVisible,
    required this.salesAgreement,
    required this.products,
    this.addresses,
    this.cardInfo,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderID: json['orderID'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderAmount: json['orderAmount'] ?? '',
      orderDiscount: json['orderDiscount'] ?? '',
      orderDesc: json['orderDesc'] ?? '',
      orderPaymentType: json['orderPaymentType'] ?? '',
      stateOrder: json['stateOrder'] ?? 0,
      orderStatusID: json['orderStatusID']?.toString() ?? '',
      orderStatus: json['orderStatus'] ?? '',
      orderStatusColor: json['orderStatusColor'] ?? '#000000',
      orderDate: json['orderDate'] ?? '',
      deliveryDate: json['deliveryDate'] ?? '',
      orderInvoice: json['orderInvoice'] ?? '',
      isCanceled: json['isCanceled'] ?? false,
      isCancelVisible: json['isCancelVisible'] ?? false,
      salesAgreement: json['SalesAgreement'] ?? '',
      products: json['products'] != null
          ? (json['products'] as List)
                .map((p) => OrderDetailProduct.fromJson(p))
                .toList()
          : [],
      addresses: json['addresses'] != null
          ? OrderAddresses.fromJson(json['addresses'])
          : null,
      cardInfo: json['cardInfo'] != null
          ? OrderCardInfo.fromJson(json['cardInfo'])
          : null,
    );
  }

  int get statusID => int.tryParse(orderStatusID) ?? 0;
}

/// Sipariş detay response modeli
class OrderDetailResponse {
  final bool isSuccess;
  final String? message;
  final OrderDetail? order;

  OrderDetailResponse({required this.isSuccess, this.message, this.order});

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final isSuccess = json['success'] == true;

    return OrderDetailResponse(
      isSuccess: isSuccess,
      message: json['message'],
      order: data != null ? OrderDetail.fromJson(data) : null,
    );
  }

  factory OrderDetailResponse.errorResponse(String message) {
    return OrderDetailResponse(isSuccess: false, message: message);
  }
}

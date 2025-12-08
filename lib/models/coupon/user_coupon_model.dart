/// Kupon modeli (API'den gelen)
class UserCoupon {
  final int couponID;
  final String couponCode;
  final String couponType;
  final int couponRepeat;
  final String couponDesc;
  final String couponDiscountType;
  final double couponDiscount;
  final String minBasketAmount;
  final List<String> couponProducts;
  final String couponStatusName;
  final String couponStatus;
  final String couponStartDate;
  final String couponEndDate;
  final bool isUsed;
  final int usageCount;

  UserCoupon({
    required this.couponID,
    required this.couponCode,
    required this.couponType,
    required this.couponRepeat,
    required this.couponDesc,
    required this.couponDiscountType,
    required this.couponDiscount,
    required this.minBasketAmount,
    required this.couponProducts,
    required this.couponStatusName,
    required this.couponStatus,
    required this.couponStartDate,
    required this.couponEndDate,
    required this.isUsed,
    required this.usageCount,
  });

  factory UserCoupon.fromJson(Map<String, dynamic> json) {
    return UserCoupon(
      couponID: json['couponID'] ?? 0,
      couponCode: json['couponCode'] ?? '',
      couponType: json['couponType'] ?? '',
      couponRepeat: json['couponRepeat'] ?? 0,
      couponDesc: json['couponDesc'] ?? '',
      couponDiscountType: json['couponDiscountType'] ?? '',
      couponDiscount: (json['couponDiscount'] ?? 0).toDouble(),
      minBasketAmount: json['minBasketAmount'] ?? '',
      couponProducts: json['couponProducts'] != null
          ? List<String>.from(json['couponProducts'])
          : [],
      couponStatusName: json['couponStatusName'] ?? '',
      couponStatus: json['couponStatus'] ?? '0',
      couponStartDate: json['couponStartDate'] ?? '',
      couponEndDate: json['couponEndDate'] ?? '',
      isUsed: json['isUsed'] ?? false,
      usageCount: json['usageCount'] ?? 0,
    );
  }

  /// Kupon aktif mi?
  bool get isActive => couponStatus == '1' && !isUsed;

  /// İndirim gösterimi (örn: %30 veya 50 TL)
  String get discountDisplay {
    if (couponDiscountType == '%') {
      return '%${couponDiscount.toStringAsFixed(0)}';
    } else {
      return '${couponDiscount.toStringAsFixed(0)} TL';
    }
  }
}

/// Kullanıcı kuponları response modeli
class UserCouponsResponse {
  final bool isSuccess;
  final String? message;
  final String? emptyMessage;
  final int totalItems;
  final List<UserCoupon> coupons;

  UserCouponsResponse({
    required this.isSuccess,
    this.message,
    this.emptyMessage,
    required this.totalItems,
    required this.coupons,
  });

  factory UserCouponsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final couponsData = data?['coupons'] as List<dynamic>? ?? [];

    return UserCouponsResponse(
      isSuccess: json['success'] == true,
      message: json['message']?.toString(),
      emptyMessage: data?['emptyMessage']?.toString(),
      totalItems: data?['totalItems'] ?? 0,
      coupons: couponsData.map((e) => UserCoupon.fromJson(e)).toList(),
    );
  }

  factory UserCouponsResponse.errorResponse(String message) {
    return UserCouponsResponse(
      isSuccess: false,
      message: message,
      totalItems: 0,
      coupons: [],
    );
  }
}

/// Kupon kullanma response modeli
/// API Response: {"error": false, "success": true, "data": "337,50 TL indirim uygulanmıştır.", "200": "OK"}
class UseCouponResponse {
  final bool success;
  final String message;

  UseCouponResponse({required this.success, required this.message});

  factory UseCouponResponse.fromJson(Map<String, dynamic> json) {
    return UseCouponResponse(
      success: json['success'] == true,
      message:
          json['data']?.toString() ??
          json['error_message'] ??
          json['message'] ??
          '',
    );
  }

  factory UseCouponResponse.errorResponse(String message) {
    return UseCouponResponse(success: false, message: message);
  }
}

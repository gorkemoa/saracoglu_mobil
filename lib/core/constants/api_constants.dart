import 'dart:convert';

/// API Endpoint sabitleri
/// Tüm API endpoint'leri burada merkezi olarak yönetilir
class ApiConstants {
  ApiConstants._();

  /// Base URL - Production
  static const String baseUrl = 'https://api.office701.com/prof-saracoglu/';

  /// Basic Auth Credentials (401)
  static const String _basicAuthUsername = 'Pr1VAhHSICWHJN8nlvp9K5ycPoyMJM';
  static const String _basicAuthPassword = 'pRParvCAqTxtmsI17I1FBpPH57Edl0';

  /// Basic Auth Header değeri
  static String get basicAuthHeader {
    final credentials = '$_basicAuthUsername:$_basicAuthPassword';
    final encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }

  /// Auth Endpoints
  static const String login = 'service/auth/login';
  static const String register = 'service/auth/register';
  static const String checkCode = 'service/auth/code/checkCode';
  static const String sendVerificationCode = 'service/auth/code/authSendCode';
  static const String forgotPassword = 'service/auth/forgotPassword';

  /// User Endpoints
  /// getUser endpoint - kullanımı: '${ApiConstants.getUser}/$userId'
  static const String getUser = 'service/user/id';

  /// updateUser endpoint - kullanımı: '${ApiConstants.updateUser}/$userId/account'
  static const String updateUser = 'service/user/update';

  /// updatePassword endpoint
  static const String updatePassword = 'service/user/update/password';

  /// deleteUser endpoint
  static const String deleteUser = 'service/user/account/delete';

  /// getNotifications endpoint - kullanımı: '${ApiConstants.getNotifications}/$userId/notifications'
  static const String getNotifications = 'service/user/account';

  /// Notification Actions Endpoints
  /// Tüm bildirimleri okundu olarak işaretle
  static const String allReadNotifications =
      'service/user/account/notification/allRead';

  /// Tek bildirimi okundu olarak işaretle
  static const String readNotification =
      'service/user/account/notification/read';

  /// Tek bildirimi sil
  static const String deleteNotification =
      'service/user/account/notification/delete';

  /// Tüm bildirimleri sil
  static const String deleteAllNotifications =
      'service/user/account/notification/allDelete';

  /// Address Endpoints
  static const String addAddress = 'service/user/account/address/add';
  static const String getUserAddresses = 'service/user/account/address/list';
  static const String updateAddress = 'service/user/account/address/update';
  static const String deleteAddress = 'service/user/account/address/delete';

  /// Coupon Endpoints
  static const String getUserCoupons = 'service/user/account/coupon/list';
  static const String useCoupon = 'service/user/account/coupon/use';
  static const String cancelCoupon = 'service/user/account/coupon/cancel';

  /// Location Endpoints
  static const String getCities = 'service/general/general/cities/all';

  /// İlçeler - kullanımı: '${ApiConstants.getDistricts}/$cityNo/districts'
  static const String getDistricts = 'service/general/general';

  /// Mahalleler - kullanımı: '${ApiConstants.getNeighbourhoods}/$districtNo/neighbourhood'
  static const String getNeighbourhoods = 'service/general/general';

  /// Product Endpoints
  static const String getAllProducts = 'service/products/product/list/all';
  static const String getSortList = 'service/products/product/list/sortList';

  /// GetProduct - kullanımı: '${ApiConstants.getProduct}/$productId?userToken=xxx'
  static const String getProduct = 'service/products/product/detail';

  /// GetCategories - kullanımı: '${ApiConstants.getCategories}/0' (0 = tüm kategoriler)
  static const String getCategories = 'service/products/category/list';

  /// GetProductComments - kullanımı: '${ApiConstants.getProductComments}/$productId'
  static const String getProductComments = 'service/products/product/comments';

  /// Favorites Endpoints
  static const String getUserFavorites = 'service/user/account/favorites/list';
  static const String toggleFavorite =
      'service/user/account/favorites/addDelete';
  static const String clearFavorites = 'service/user/account/favorites/clear';

  /// Comment Endpoints
  static const String getUserComments = 'service/user/account/comment/list';
  static const String addComment = 'service/user/account/comment/add';

  /// Basket Endpoints
  static const String addToBasket = 'service/user/account/basket/add';
  static const String getUserBaskets = 'service/user/account/basket/list';
  static const String updateBasket = 'service/user/account/basket/update';
  static const String deleteBasket = 'service/user/account/basket/delete';
  static const String clearBasket = 'service/user/account/basket/clear';

  /// Order Endpoints
  static const String getUserOrders = 'service/user/account/order/list';
  static const String getOrderDetail = 'service/user/account/order/detail';
  static const String cancelOrder = 'service/user/account/order/cancel/';
  static const String getOrderStatusList =
      'service/general/general/order/statusList';

  /// Contact Endpoints
  static const String getContactSubjects =
      'service/general/general/contact/subjects';
  static const String sendContactMessage =
      'service/user/account/contact/sendMessage';
  static const String getUserContactForms = 'service/user/account/contact/list';
  static const String getContactInfos = 'service/general/general/contact/infos';

  /// FAQ Endpoints
  static const String getFAQCategories = 'service/general/general/faq/catList';
  static const String getFAQList = 'service/general/general/faq/list';

  /// Banner Endpoints
  static const String getBanners = 'service/general/general/banner/list';

  /// Payment Endpoints
  /// PayTR ile ödeme isteği - NOT: API geliştirme aşamasında, ileride güncellenecek
  static const String paytrPayment = 'service/payment/payment/request/paytr';

  /// Taksit sorgulama - Kartın ilk 8 hanesi ile
  static const String getInstallments = 'service/payment/payment/installments';

  /// Contracts Endpoints
  /// Mesafeli Satış Sözleşmesi - kullanımı: '${ApiConstants.getSalesAgreement}?userToken=xxx&shipAddressID=1&billAddressID=1'
  static const String getSalesAgreement =
      'service/general/general/contracts/salesAgreement';

  /// Gizlilik Politikası - kullanımı: '${ApiConstants.getPrivacyPolicy}'
  static const String getPrivacyPolicy =
      'service/general/general/contracts/privacyPolicy';

  /// Üyelik Sözleşmesi - kullanımı: '${ApiConstants.getMembershipAgreement}'
  static const String getMembershipAgreement =
      'service/general/general/contracts/membershipAgreement';

  /// KVKK Aydınlatma Metni
  static const String getKVKKPolicy =
      'service/general/general/contracts/kvkkAgreement';
}

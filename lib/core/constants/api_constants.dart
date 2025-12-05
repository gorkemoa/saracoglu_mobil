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

  /// Address Endpoints
  static const String addAddress = 'service/user/account/address/add';
  static const String getUserAddresses = 'service/user/account/address/list';
  static const String updateAddress = 'service/user/account/address/update';
  static const String deleteAddress = 'service/user/account/address/delete';

  /// Coupon Endpoints
  static const String getUserCoupons = 'service/user/account/coupon/list';

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
  /// GetProductComments - kullanımı: '${ApiConstants.getProductComments}/$productId'
  static const String getProductComments = 'service/products/product/comments';

  /// Favorites Endpoints
  static const String getUserFavorites = 'service/user/account/favorites/list';
  static const String toggleFavorite = 'service/user/account/favorites/addDelete';
  static const String clearFavorites = 'service/user/account/favorites/clear';

  /// Comment Endpoints
  static const String getUserComments = 'service/user/account/comment/list';

  /// Basket Endpoints
  static const String addToBasket = 'service/user/account/basket/add';
  static const String getUserBaskets = 'service/user/account/basket/list';
  static const String updateBasket = 'service/user/account/basket/update';
  static const String deleteBasket = 'service/user/account/basket/delete';
  static const String clearBasket = 'service/user/account/basket/clear';
}

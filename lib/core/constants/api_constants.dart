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


  /// User Endpoints
  /// getUser endpoint - kullanımı: '${ApiConstants.getUser}/$userId'
  static const String getUser = 'service/user/id';
  /// updateUser endpoint - kullanımı: '${ApiConstants.updateUser}/$userId/account'
  static const String updateUser = 'service/user/update';
  /// updatePassword endpoint
  static const String updatePassword = 'service/user/update/password';
  /// deleteUser endpoint
  static const String deleteUser = 'service/user/account/delete';



}

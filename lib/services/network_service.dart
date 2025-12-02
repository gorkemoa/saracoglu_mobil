import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../core/constants/api_constants.dart';

/// 403 hatası callback tipi
typedef OnUnauthorizedCallback = void Function();

/// Network sonuç wrapper'ı
/// API çağrılarının sonucunu sarmalayan generic sınıf
class NetworkResult<T> {
  final T? data;
  final String? errorMessage;
  final int? statusCode;
  final bool isSuccess;

  NetworkResult._({
    this.data,
    this.errorMessage,
    this.statusCode,
    required this.isSuccess,
  });

  factory NetworkResult.success(T data, {int? statusCode}) {
    return NetworkResult._(
      data: data,
      isSuccess: true,
      statusCode: statusCode,
    );
  }

  factory NetworkResult.failure(String message, {int? statusCode}) {
    return NetworkResult._(
      errorMessage: message,
      isSuccess: false,
      statusCode: statusCode,
    );
  }
}

/// Base Network Service
/// Tüm HTTP isteklerini yöneten temel servis
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  /// Logger instance
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  String? _authToken;
  
  /// 403 hatası callback - Token geçersiz olduğunda çağrılır
  OnUnauthorizedCallback? onUnauthorized;

  /// Auth token'ı set et
  void setAuthToken(String token) {
    _authToken = token;
    _logger.i('🔐 Auth Token set edildi');
  }

  /// Auth token'ı temizle
  void clearAuthToken() {
    _authToken = null;
    _logger.i('🔓 Auth Token temizlendi');
  }

  /// Default headers - Basic Auth dahil
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': ApiConstants.basicAuthHeader, // Basic Auth (401)
    };
    
    // Eğer user token varsa, Bearer token olarak ekle
    if (_authToken != null) {
      headers['X-User-Token'] = _authToken!;
    }
    
    return headers;
  }

  /// GET isteği
  Future<NetworkResult<Map<String, dynamic>>> get(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    _logger.d('📤 GET Request: $url');
    
    try {
      final response = await http
          .get(url, headers: _headers);

      _logger.d('📥 GET Response [${response.statusCode}]: $endpoint');
      
      return _handleResponse(response, endpoint);
    } catch (e) {
      _logger.e('❌ GET Error: $endpoint', error: e);
      return NetworkResult.failure(_getErrorMessage(e));
    }
  }

  /// POST isteği
  Future<NetworkResult<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    _logger.d('📤 POST Request: $url');
    _logger.d('📦 Body: ${jsonEncode(body)}');
    
    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          );

      _logger.d('📥 POST Response [${response.statusCode}]: $endpoint');
      
      return _handleResponse(response, endpoint);
    } catch (e) {
      _logger.e('❌ POST Error: $endpoint', error: e);
      return NetworkResult.failure(_getErrorMessage(e));
    }
  }

  /// PUT isteği
  Future<NetworkResult<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    _logger.d('📤 PUT Request: $url');
    _logger.d('📦 Body: ${jsonEncode(body)}');
    
    try {
      final response = await http
          .put(
            url,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          );

      _logger.d('📥 PUT Response [${response.statusCode}]: $endpoint');
      
      return _handleResponse(response, endpoint);
    } catch (e) {
      _logger.e('❌ PUT Error: $endpoint', error: e);
      return NetworkResult.failure(_getErrorMessage(e));
    }
  }

  /// DELETE isteği
  Future<NetworkResult<Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    _logger.d('📤 DELETE Request: $url');
    if (body != null) {
      _logger.d('📦 Body: ${jsonEncode(body)}');
    }
    
    try {
      final response = await http.delete(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );

      _logger.d('📥 DELETE Response [${response.statusCode}]: $endpoint');
      
      return _handleResponse(response, endpoint);
    } catch (e) {
      _logger.e('❌ DELETE Error: $endpoint', error: e);
      return NetworkResult.failure(_getErrorMessage(e));
    }
  }

  /// Response handler
  NetworkResult<Map<String, dynamic>> _handleResponse(
    http.Response response,
    String endpoint,
  ) {
    final statusCode = response.statusCode;

    try {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      _logger.d('📄 Response Body: ${response.body}');

      // 401 hatası - Unauthorized (Basic Auth hatası)
      if (statusCode == 401) {
        _logger.w('⚠️ 401 Unauthorized: $endpoint');
        return NetworkResult.failure(
          'Yetkilendirme hatası',
          statusCode: statusCode,
        );
      }

      // 403 hatası - Forbidden (Token geçersiz/süresi dolmuş)
      if (statusCode == 403) {
        _logger.w('⚠️ 403 Forbidden - Token geçersiz: $endpoint');
        // Callback'i çağır (login sayfasına yönlendirme için)
        onUnauthorized?.call();
        return NetworkResult.failure(
          'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
          statusCode: statusCode,
        );
      }

      // 417 hatası - Expectation Failed (Backend'den gelen hata mesajı)
      if (statusCode == 417) {
        final message = jsonData['error_message'] ?? 
                        jsonData['message'] ?? 
                        jsonData['data']?['message'] ?? 
                        'Bir hata oluştu';
        _logger.w('⚠️ 417 Validation Error: $message');
        return NetworkResult.failure(message, statusCode: statusCode);
      }

      // Başarılı yanıt
      if (statusCode >= 200 && statusCode < 300) {
        _logger.i('✅ Success: $endpoint');
        return NetworkResult.success(jsonData, statusCode: statusCode);
      }

      // Diğer hatalar
      final message = jsonData['message'] ?? 
                      jsonData['data']?['message'] ?? 
                      'Bir hata oluştu';
      _logger.w('⚠️ Error [$statusCode]: $message');
      return NetworkResult.failure(message, statusCode: statusCode);
    } catch (e) {
      _logger.e('❌ Response Parse Error: $endpoint', error: e);
      return NetworkResult.failure(
        'Yanıt işlenirken hata oluştu',
        statusCode: statusCode,
      );
    }
  }

  /// Hata mesajı oluştur
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'İnternet bağlantınızı kontrol edin';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Bağlantı zaman aşımına uğradı';
    }
    return 'Bir hata oluştu: ${error.toString()}';
  }
}

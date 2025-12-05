import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../models/basket/basket_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// Sepet Servisi
/// Kullanıcının sepet işlemlerini yönetir
class BasketService {
  static final BasketService _instance = BasketService._internal();
  factory BasketService() => _instance;
  BasketService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  /// User token'ı AuthService'den al
  String get _userToken => _authService.token ?? '';

  /// Kullanıcının sepetini getir
  Future<UserBasketResponse?> getUserBaskets() async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Sepeti görüntülemek için giriş yapılmalı');
        return null;
      }

      final url = '${ApiConstants.getUserBaskets}?userToken=$_userToken';
      _logger.d('📤 Get User Baskets Request: $url');

      final result = await _networkService.get(url);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = UserBasketResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i(
            '✅ Sepet getirildi: ${response.data?.baskets.length ?? 0} ürün',
          );
          return response;
        } else {
          _logger.w('⚠️ Sepet getirme başarısız');
          return response;
        }
      }

      _logger.w('⚠️ Sepet getirme başarısız: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Sepet getirme hatası', error: e);
      return null;
    }
  }

  /// Sepete ürün ekle
  /// [productId] - Ürün ID
  /// [quantity] - Adet (varsayılan 1)
  /// [variantId] - Varyant ID (yoksa 0)
  Future<AddToBasketResponse?> addToBasket({
    required int productId,
    int quantity = 1,
    int variantId = 0,
  }) async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Sepete eklemek için giriş yapılmalı');
        return null;
      }

      final request = AddToBasketRequest(
        userToken: _userToken,
        productID: productId,
        quantity: quantity,
        variantID: variantId,
      );

      _logger.d('📤 Add to Basket Request: ${request.toJson()}');

      final result = await _networkService.post(
        ApiConstants.addToBasket,
        body: request.toJson(),
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = AddToBasketResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Sepete eklendi: ${response.message}');
          return response;
        } else {
          _logger.w('⚠️ Sepete ekleme başarısız: ${response.message}');
          return response;
        }
      }

      _logger.w('⚠️ Sepete ekleme başarısız: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Sepete ekleme hatası', error: e);
      return null;
    }
  }

  /// Sepetteki ürün miktarını güncelle
  /// [basketId] - Sepet öğesi ID
  /// [quantity] - Yeni miktar
  Future<BasketActionResponse> updateBasket({
    required int basketId,
    required int quantity,
  }) async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Sepeti güncellemek için giriş yapılmalı');
        return BasketActionResponse(success: false, message: 'Giriş yapılmalı');
      }

      final body = {
        'userToken': _userToken,
        'basketID': basketId,
        'quantity': quantity,
      };

      _logger.d('📤 Update Basket Request: $body');

      final result = await _networkService.post(
        ApiConstants.updateBasket,
        body: body,
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = BasketActionResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Sepet güncellendi: ${response.message}');
        } else {
          _logger.w('⚠️ Sepet güncelleme başarısız: ${response.message}');
        }
        return response;
      }

      _logger.w('⚠️ Sepet güncelleme başarısız: ${result.errorMessage}');
      return BasketActionResponse(
        success: false,
        message: result.errorMessage ?? 'Bir hata oluştu',
      );
    } catch (e) {
      _logger.e('❌ Sepet güncelleme hatası', error: e);
      return BasketActionResponse(success: false, message: 'Bir hata oluştu');
    }
  }

  /// Sepetten ürün sil
  /// [basketId] - Silinecek sepet öğesi ID
  Future<BasketActionResponse> deleteFromBasket({required int basketId}) async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Sepetten silmek için giriş yapılmalı');
        return BasketActionResponse(success: false, message: 'Giriş yapılmalı');
      }

      final body = {'userToken': _userToken, 'basketID': basketId};

      _logger.d('📤 Delete Basket Request: $body');

      final result = await _networkService.post(
        ApiConstants.deleteBasket,
        body: body,
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = BasketActionResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Sepetten silindi: ${response.message}');
        } else {
          _logger.w('⚠️ Sepetten silme başarısız: ${response.message}');
        }
        return response;
      }

      _logger.w('⚠️ Sepetten silme başarısız: ${result.errorMessage}');
      return BasketActionResponse(
        success: false,
        message: result.errorMessage ?? 'Bir hata oluştu',
      );
    } catch (e) {
      _logger.e('❌ Sepetten silme hatası', error: e);
      return BasketActionResponse(success: false, message: 'Bir hata oluştu');
    }
  }

  /// Sepeti tamamen temizle
  Future<BasketActionResponse> clearBasket() async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Sepeti temizlemek için giriş yapılmalı');
        return BasketActionResponse(success: false, message: 'Giriş yapılmalı');
      }

      final body = {'userToken': _userToken};

      _logger.d('📤 Clear Basket Request: $body');

      final result = await _networkService.post(
        ApiConstants.clearBasket,
        body: body,
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = BasketActionResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Sepet temizlendi: ${response.message}');
        } else {
          _logger.w('⚠️ Sepet temizleme başarısız: ${response.message}');
        }
        return response;
      }

      _logger.w('⚠️ Sepet temizleme başarısız: ${result.errorMessage}');
      return BasketActionResponse(
        success: false,
        message: result.errorMessage ?? 'Bir hata oluştu',
      );
    } catch (e) {
      _logger.e('❌ Sepet temizleme hatası', error: e);
      return BasketActionResponse(success: false, message: 'Bir hata oluştu');
    }
  }
}

/// Sepet işlemleri için ortak response modeli
class BasketActionResponse {
  final bool success;
  final String message;

  BasketActionResponse({required this.success, required this.message});

  factory BasketActionResponse.fromJson(Map<String, dynamic> json) {
    return BasketActionResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
    );
  }
}

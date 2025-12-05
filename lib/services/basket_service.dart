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
}

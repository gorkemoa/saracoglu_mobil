import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../models/favorite/favorite_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// Favoriler Servisi
/// Kullanıcının favori ürünlerini yönetir
class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  /// User token'ı AuthService'den al
  String get _userToken => _authService.token ?? '';

  /// Kullanıcının favori ürünlerini getir
  Future<FavoritesResponse?> getUserFavorites() async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Favoriler için giriş yapılmalı');
        return null;
      }

      final endpoint = '${ApiConstants.getUserFavorites}?userToken=$_userToken';

      _logger.d('📤 Request URL: $endpoint');

      final result = await _networkService.get(endpoint);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = FavoritesResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Favoriler getirildi: ${response.totalItems} ürün');
          return response;
        }
      }

      _logger.w('⚠️ Favoriler getirilemedi: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Favoriler getirme hatası', error: e);
      return null;
    }
  }

  /// Ürünü favorilere ekle veya çıkar (toggle)
  /// [productId] - Ürün ID
  /// Döndürülen response'da isFavorite true ise eklendi, false ise çıkarıldı
  Future<ToggleFavoriteResponse?> toggleFavorite({
    required int productId,
  }) async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Favori işlemi için giriş yapılmalı');
        return null;
      }

      final request = ToggleFavoriteRequest(
        userToken: _userToken,
        productID: productId,
      );

      _logger.d('📤 Toggle Favorite Request: ${request.toJson()}');

      final result = await _networkService.put(
        ApiConstants.toggleFavorite,
        body: request.toJson(),
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = ToggleFavoriteResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Favori işlemi başarılı: ${response.message}');
          return response;
        }
      }

      _logger.w('⚠️ Favori işlemi başarısız: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Favori toggle hatası', error: e);
      return null;
    }
  }

  /// Tüm favorileri temizle
  Future<ClearFavoritesResponse?> clearFavorites() async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Favori temizleme için giriş yapılmalı');
        return null;
      }

      final request = ClearFavoritesRequest(userToken: _userToken);

      _logger.d('📤 Clear Favorites Request: ${request.toJson()}');

      final result = await _networkService.delete(
        ApiConstants.clearFavorites,
        body: request.toJson(),
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = ClearFavoritesResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Tüm favoriler temizlendi: ${response.message}');
          return response;
        }
      }

      _logger.w('⚠️ Favori temizleme başarısız: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Favori temizleme hatası', error: e);
      return null;
    }
  }
}

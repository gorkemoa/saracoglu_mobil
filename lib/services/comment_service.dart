import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../models/comment/user_comment_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// Yorum Servisi
/// Kullanıcının yorumlarını yönetir
class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  CommentService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  /// User token'ı AuthService'den al
  String get _userToken => _authService.token ?? '';

  /// Kullanıcının yorumlarını getir
  Future<UserCommentsResponse?> getUserComments() async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Yorumlar için giriş yapılmalı');
        return null;
      }

      final endpoint = '${ApiConstants.getUserComments}?userToken=$_userToken';

      _logger.d('📤 Request URL: $endpoint');

      final result = await _networkService.get(endpoint);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = UserCommentsResponse.fromJson(result.data!);
        if (response.success) {
          _logger.i('✅ Yorumlar getirildi: ${response.totalItems} yorum');
          return response;
        }
      }

      _logger.w('⚠️ Yorumlar getirilemedi: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Yorumlar getirme hatası', error: e);
      return null;
    }
  }

  /// Yorum güncelle
  Future<bool> updateComment({
    required int productID,
    required int commentID,
    required String comment,
    required int commentRating,
    bool showName = true,
  }) async {
    try {
      if (_userToken.isEmpty) return false;

      final body = {
        "userToken": _userToken,
        "productID": productID,
        "commentID": commentID,
        "comment": comment,
        "commentRating": commentRating,
        "showName": showName,
      };

      final result = await _networkService.put(
        ApiConstants.updateComment,
        body: body,
      );

      if (result.isSuccess && result.data != null) {
        final success = result.data!['success'] == true;
        if (success) {
          _logger.i('✅ Yorum güncellendi');
        }
        return success;
      }

      return false;
    } catch (e) {
      _logger.e('❌ Yorum güncelleme hatası', error: e);
      return false;
    }
  }

  /// Yorum sil
  Future<bool> deleteComment(int commentID) async {
    try {
      if (_userToken.isEmpty) return false;

      final body = {"userToken": _userToken, "commentID": commentID};

      final result = await _networkService.delete(
        ApiConstants.deleteComment,
        body: body,
      );

      if (result.isSuccess && result.data != null) {
        final success = result.data!['success'] == true;
        if (success) {
          _logger.i('✅ Yorum silindi');
        }
        return success;
      }

      return false;
    } catch (e) {
      _logger.e('❌ Yorum silme hatası', error: e);
      return false;
    }
  }
}

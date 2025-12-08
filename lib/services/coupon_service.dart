import '../core/constants/api_constants.dart';
import '../models/coupon/user_coupon_model.dart';
import 'network_service.dart';
import 'auth_service.dart';
import 'package:logger/logger.dart';

/// Kupon yönetimi servisi - Singleton pattern
class CouponService {
  static final CouponService _instance = CouponService._internal();
  factory CouponService() => _instance;
  CouponService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  /// Kullanıcının kuponlarını getir
  Future<UserCouponsResponse> getCoupons() async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return UserCouponsResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      final result = await _networkService.get(
        '${ApiConstants.getUserCoupons}?userToken=$token',
      );

      if (result.isSuccess && result.data != null) {
        return UserCouponsResponse.fromJson(result.data!);
      } else {
        return UserCouponsResponse.errorResponse(
          result.errorMessage ?? 'Kuponlar yüklenirken bir hata oluştu',
        );
      }
    } catch (e) {
      return UserCouponsResponse.errorResponse(
        'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Kupon kullan
  /// [couponCode] - Kullanılacak kupon kodu
  Future<UseCouponResponse> useCoupon(String couponCode) async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return UseCouponResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      final body = {'userToken': token, 'couponCode': couponCode};

      _logger.d('📤 Use Coupon Request: $body');

      final result = await _networkService.post(
        ApiConstants.useCoupon,
        body: body,
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.data != null) {
        return UseCouponResponse.fromJson(result.data!);
      } else {
        return UseCouponResponse.errorResponse(
          result.errorMessage ?? 'Kupon uygulanırken bir hata oluştu',
        );
      }
    } catch (e) {
      _logger.e('❌ Kupon kullanma hatası', error: e);
      return UseCouponResponse.errorResponse(
        'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Kuponu iptal et
  Future<UseCouponResponse> cancelCoupon() async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return UseCouponResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      final body = {'userToken': token};

      _logger.d('📤 Cancel Coupon Request: $body');

      final result = await _networkService.put(
        ApiConstants.cancelCoupon,
        body: body,
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.data != null) {
        return UseCouponResponse.fromJson(result.data!);
      } else {
        return UseCouponResponse.errorResponse(
          result.errorMessage ?? 'Kupon iptal edilirken bir hata oluştu',
        );
      }
    } catch (e) {
      _logger.e('❌ Kupon iptal hatası', error: e);
      return UseCouponResponse.errorResponse(
        'Bir hata oluştu: ${e.toString()}',
      );
    }
  }
}

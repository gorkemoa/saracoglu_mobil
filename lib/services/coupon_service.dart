import '../core/constants/api_constants.dart';
import '../models/coupon/user_coupon_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// Kupon yönetimi servisi - Singleton pattern
class CouponService {
  static final CouponService _instance = CouponService._internal();
  factory CouponService() => _instance;
  CouponService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();

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
      return UserCouponsResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
    }
  }
}

import '../core/constants/api_constants.dart';
import '../models/order/user_order_model.dart';
import '../models/order/order_detail_model.dart';
import 'network_service.dart';
import 'auth_service.dart';
import 'package:logger/logger.dart';

/// Sipariş yönetimi servisi - Singleton pattern
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  /// Kullanıcının siparişlerini getir
  Future<UserOrdersResponse> getOrders() async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return UserOrdersResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      _logger.d('📤 Get Orders Request: userToken=$token');

      final result = await _networkService.get(
        '${ApiConstants.getUserOrders}?userToken=$token',
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        return UserOrdersResponse.fromJson(result.data!);
      } else {
        return UserOrdersResponse.errorResponse(
          result.errorMessage ?? 'Siparişler yüklenirken bir hata oluştu',
        );
      }
    } catch (e) {
      _logger.e('❌ Sipariş getirme hatası', error: e);
      return UserOrdersResponse.errorResponse(
        'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Sipariş detayını getir
  Future<OrderDetailResponse> getOrderDetail(int orderID) async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return OrderDetailResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      _logger.d('📤 Get Order Detail Request: orderID=$orderID');

      final result = await _networkService.get(
        '${ApiConstants.getOrderDetail}?userToken=$token&orderID=$orderID',
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        return OrderDetailResponse.fromJson(result.data!);
      } else {
        return OrderDetailResponse.errorResponse(
          result.errorMessage ?? 'Sipariş detayı yüklenirken bir hata oluştu',
        );
      }
    } catch (e) {
      _logger.e('❌ Sipariş detay getirme hatası', error: e);
      return OrderDetailResponse.errorResponse(
        'Bir hata oluştu: ${e.toString()}',
      );
    }
  }
}

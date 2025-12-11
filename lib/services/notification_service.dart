import '../core/constants/api_constants.dart';
import '../models/notification/notification_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// Bildirim servisi - Singleton pattern
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();

  /// Kullanıcının bildirimlerini getir
  Future<List<NotificationModel>> getNotifications({
    required int userId,
  }) async {
    try {
      final endpoint = '${ApiConstants.getNotifications}/$userId/notifications';
      
      final response = await _networkService.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        
        // API yanıtı: {data: {notifications: [...]}}
        final data = responseData['data'] as Map<String, dynamic>?;
        final notificationsList = data?['notifications'] as List<dynamic>?;

        if (notificationsList != null) {
          return notificationsList
              .map((json) => NotificationModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Bildirimler alınamadı: $e');
      return [];
    }
  }

  /// Okunmamış bildirim sayısını getir
  int getUnreadCount(List<NotificationModel> notifications) {
    return notifications.where((n) => !n.isRead).length;
  }

  /// Tüm bildirimleri okundu olarak işaretle
  Future<NotificationActionResponse> markAllAsRead() async {
    try {
      final userToken = _authService.token;
      if (userToken == null) {
        return NotificationActionResponse(success: false, message: 'Oturum bulunamadı');
      }

      final response = await _networkService.put(
        ApiConstants.allReadNotifications,
        body: {'userToken': userToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return NotificationActionResponse(
          success: data['success'] ?? false,
          message: data['success_message'] ?? 'İşlem tamamlandı',
        );
      }

      return NotificationActionResponse(success: false, message: 'İşlem başarısız');
    } catch (e) {
      print('Bildirimler okundu işaretlenemedi: $e');
      return NotificationActionResponse(success: false, message: 'Bir hata oluştu');
    }
  }

  /// Tek bildirimi okundu olarak işaretle
  Future<NotificationActionResponse> markAsRead({required int notificationId}) async {
    try {
      final userToken = _authService.token;
      if (userToken == null) {
        return NotificationActionResponse(success: false, message: 'Oturum bulunamadı');
      }

      final response = await _networkService.put(
        ApiConstants.readNotification,
        body: {
          'userToken': userToken,
          'notID': notificationId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return NotificationActionResponse(
          success: data['success'] ?? false,
          message: data['success_message'] ?? 'İşlem tamamlandı',
        );
      }

      return NotificationActionResponse(success: false, message: 'İşlem başarısız');
    } catch (e) {
      print('Bildirim okundu işaretlenemedi: $e');
      return NotificationActionResponse(success: false, message: 'Bir hata oluştu');
    }
  }

  /// Tek bildirimi sil
  Future<NotificationActionResponse> deleteNotification({required int notificationId}) async {
    try {
      final userToken = _authService.token;
      if (userToken == null) {
        return NotificationActionResponse(success: false, message: 'Oturum bulunamadı');
      }

      final response = await _networkService.delete(
        ApiConstants.deleteNotification,
        body: {
          'userToken': userToken,
          'notID': notificationId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return NotificationActionResponse(
          success: data['success'] ?? false,
          message: data['success_message'] ?? 'İşlem tamamlandı',
        );
      }

      return NotificationActionResponse(success: false, message: 'İşlem başarısız');
    } catch (e) {
      print('Bildirim silinemedi: $e');
      return NotificationActionResponse(success: false, message: 'Bir hata oluştu');
    }
  }

  /// Tüm bildirimleri sil
  Future<NotificationActionResponse> deleteAllNotifications() async {
    try {
      final userToken = _authService.token;
      if (userToken == null) {
        return NotificationActionResponse(success: false, message: 'Oturum bulunamadı');
      }

      final response = await _networkService.delete(
        ApiConstants.deleteAllNotifications,
        body: {'userToken': userToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return NotificationActionResponse(
          success: data['success'] ?? false,
          message: data['success_message'] ?? 'İşlem tamamlandı',
        );
      }

      return NotificationActionResponse(success: false, message: 'İşlem başarısız');
    } catch (e) {
      print('Bildirimler silinemedi: $e');
      return NotificationActionResponse(success: false, message: 'Bir hata oluştu');
    }
  }
}

/// Bildirim işlem yanıtı
class NotificationActionResponse {
  final bool success;
  final String message;

  NotificationActionResponse({
    required this.success,
    required this.message,
  });
}

import '../core/constants/api_constants.dart';
import '../models/notification/notification_model.dart';
import 'network_service.dart';

/// Bildirim servisi - Singleton pattern
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final NetworkService _networkService = NetworkService();

  /// Kullanıcının bildirimlerini getir
  Future<List<NotificationModel>> getNotifications({
    required int userId,
  }) async {
    try {
      final response = await _networkService.get(
        '${ApiConstants.getNotifications}/$userId/notifications',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final notificationsList = data['notifications'] as List<dynamic>?;

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
}

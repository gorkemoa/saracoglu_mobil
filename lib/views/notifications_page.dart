import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../models/notification/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  final NavigationService _navigationService = NavigationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final notifications = await _notificationService.getNotifications(
      userId: user.id,
    );

    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  /// Tüm bildirimleri okundu olarak işaretle
  Future<void> _markAllAsRead() async {
    final response = await _notificationService.markAllAsRead();
    if (response.success) {
      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
      });
      _showSuccessSnackBar(response.message);
    } else {
      _showErrorSnackBar(response.message);
    }
  }

  /// Tek bildirimi okundu olarak işaretle
  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    final response = await _notificationService.markAsRead(
      notificationId: notification.id,
    );

    if (response.success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    }
  }

  /// Tek bildirimi sil
  Future<void> _deleteNotification(NotificationModel notification) async {
    final response = await _notificationService.deleteNotification(
      notificationId: notification.id,
    );

    if (response.success) {
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });
      _showSuccessSnackBar(response.message);
    } else {
      _showErrorSnackBar(response.message);
    }
  }

  /// Tüm bildirimleri sil
  Future<void> _deleteAllNotifications() async {
    final confirmed = await _showConfirmDialog(
      title: 'Tüm Bildirimleri Sil',
      message: 'Tüm bildirimler silinecek. Bu işlem geri alınamaz.',
    );

    if (confirmed != true) return;

    final response = await _notificationService.deleteAllNotifications();

    if (response.success) {
      setState(() {
        _notifications.clear();
      });
      _showSuccessSnackBar(response.message);
    } else {
      _showErrorSnackBar(response.message);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLG),
        title: Text(title, style: AppTypography.h4),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    final hasUnread = _notifications.any((n) => !n.isRead);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              if (hasUnread)
                ListTile(
                  leading: Icon(Icons.done_all, color: AppColors.primary),
                  title: Text(
                    'Tümünü Okundu İşaretle',
                    style: AppTypography.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _markAllAsRead();
                  },
                ),
              if (_notifications.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.delete_sweep, color: AppColors.error),
                  title: Text('Tümünü Sil', style: AppTypography.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteAllNotifications();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bildirimler',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount okunmamış',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
              onPressed: _showOptionsMenu,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : _notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppColors.primary,
              child: ListView.separated(
                padding: EdgeInsets.all(AppSpacing.md),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Henüz bildiriminiz yok',
            style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Yeni bildirimler burada görünecek',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final isUnread = !notification.isRead;

    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'order_created':
      case 'order_processing':
      case 'order_shipped':
      case 'order_delivered':
      case 'return_requested':
      case 'return_approved':
      case 'return_rejected':
      case 'return_received':
      case 'order_ready': // Keep existing just in case
        iconData = Icons.local_shipping;
        iconColor = AppColors.primary;
        if (notification.type.contains('delivered') ||
            notification.type == 'return_approved' ||
            notification.type == 'return_received') {
          iconColor = AppColors.success;
          iconData = Icons.check_circle;
        } else if (notification.type.contains('rejected')) {
          iconColor = AppColors.error;
          iconData = Icons.cancel;
        }
        break;
      case 'campaign':
        iconData = Icons.local_offer;
        iconColor = AppColors.warning;
        break;
      case 'product':
        iconData = Icons.shopping_bag;
        iconColor = AppColors.primary;
        break;
      case 'marketing':
        iconData = Icons.campaign;
        iconColor = AppColors.info;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.textSecondary;
    }

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadius.borderRadiusMD,
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: GestureDetector(
        onTap: () {
          _markAsRead(notification);
          _navigationService.handleNotificationTap(context, notification);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isUnread
                ? AppColors.primary.withOpacity(0.05)
                : AppColors.surface,
            borderRadius: AppRadius.borderRadiusMD,
            border: Border.all(
              color: isUnread
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.border,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(width: AppSpacing.xxs),
                          Text(
                            notification.createDate,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

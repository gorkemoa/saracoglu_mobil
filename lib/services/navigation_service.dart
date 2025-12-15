import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/notification/notification_model.dart';
import '../views/profile/order_detail_page.dart';
import '../views/product_detail_page.dart';
import '../views/all_products_page.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// Global navigator key to allow navigation without context reference
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Handle notification tap from Model
  Future<void> handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) async {
    await _navigateBasedOnType(
      context,
      type: notification.type,
      typeId: notification.typeId,
      url: notification.url,
      title: notification.title,
    );
  }

  /// Navigate based on type and id
  Future<void> _navigateBasedOnType(
    BuildContext context, {
    required String type,
    required int typeId,
    String? url,
    String? title,
  }) async {
    switch (type) {
      // Order Related Types
      case 'order_created':
      case 'order_processing':
      case 'order_shipped':
      case 'order_delivered':
      case 'return_requested':
      case 'return_approved':
      case 'return_rejected': // Added missing types from user request
      case 'return_received': // Added missing types from user request
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderID: typeId,
              orderCode: '', // Placeholder, will be fetched in page
            ),
          ),
        );
        break;

      // Product Type
      case 'product':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: typeId),
          ),
        );
        break;

      // Campaign Type
      case 'campaign':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllProductsPage.category(
              categoryId: typeId,
              categoryName: title ?? 'Kampanya',
            ),
          ),
        );
        break;

      // Marketing / URL Type
      case 'marketing':
        if (url != null && url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        break;

      default:
        // Default behavior if unknown type (stay on page or do nothing)
        debugPrint('Unknown notification type: $type');
        break;
    }
  }

  /// Handle notification from background/terminated state (using global key)
  Future<void> handleDeepLink({
    required String type,
    required int typeId,
    String? url,
    String? title,
  }) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      await _navigateBasedOnType(
        context,
        type: type,
        typeId: typeId,
        url: url,
        title: title,
      );
    } else {
      debugPrint('Navigation context is null');
    }
  }
}

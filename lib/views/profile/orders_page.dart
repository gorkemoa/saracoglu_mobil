import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class OrderStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String shipped = 'shipped';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
}

class OrderItem {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final String status;
  final double totalPrice;
  final int itemCount;
  final String? imageUrl;
  final bool isAssetImage;

  OrderItem({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.totalPrice,
    required this.itemCount,
    this.imageUrl,
    this.isAssetImage = true,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Onay Bekliyor';
      case OrderStatus.processing:
        return 'Hazırlanıyor';
      case OrderStatus.shipped:
        return 'Kargoya Verildi';
      case OrderStatus.delivered:
        return 'Teslim Edildi';
      case OrderStatus.cancelled:
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.processing:
        return AppColors.info;
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.processing:
        return Icons.inventory_2_outlined;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<OrderItem> _orders = [
    OrderItem(
      id: '1',
      orderNumber: 'SRC2024001234',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.shipped,
      totalPrice: 489.90,
      itemCount: 3,
      imageUrl: 'assets/kategorileri/aromaterapi.png',
    ),
    OrderItem(
      id: '2',
      orderNumber: 'SRC2024001233',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.delivered,
      totalPrice: 329.90,
      itemCount: 2,
      imageUrl: 'assets/kategorileri/dogalbitkiler.png',
    ),
    OrderItem(
      id: '3',
      orderNumber: 'SRC2024001232',
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      status: OrderStatus.delivered,
      totalPrice: 199.90,
      itemCount: 1,
      imageUrl: 'assets/kategorileri/soguksikimyaglar.png',
    ),
    OrderItem(
      id: '4',
      orderNumber: 'SRC2024001231',
      orderDate: DateTime.now().subtract(const Duration(days: 15)),
      status: OrderStatus.cancelled,
      totalPrice: 149.90,
      itemCount: 1,
      imageUrl: 'assets/kategorileri/organikkozmatik.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderItem> get _activeOrders => _orders.where((o) => 
    o.status == OrderStatus.pending || 
    o.status == OrderStatus.processing || 
    o.status == OrderStatus.shipped
  ).toList();

  List<OrderItem> get _completedOrders => _orders.where((o) => 
    o.status == OrderStatus.delivered
  ).toList();

  List<OrderItem> get _cancelledOrders => _orders.where((o) => 
    o.status == OrderStatus.cancelled
  ).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: AppColors.surface,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
            ),
            title: Text(
              'Siparişlerim',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: 'Aktif (${_activeOrders.length})'),
                Tab(text: 'Tamamlanan (${_completedOrders.length})'),
                Tab(text: 'İptal (${_cancelledOrders.length})'),
              ],
            ),
          ),

          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_activeOrders),
                _buildOrderList(_completedOrders),
                _buildOrderList(_cancelledOrders),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderItem> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: orders.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Sipariş Bulunamadı',
              style: AppTypography.h4,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Bu kategoride henüz siparişiniz bulunmuyor.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Sipariş detayına git
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusSM,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            // Üst kısım - Sipariş bilgileri
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ürün görseli
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.borderRadiusXS,
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.borderRadiusXS,
                      child: order.imageUrl != null
                          ? Image.asset(
                              order.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // Sipariş detayları
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatDate(order.orderDate),
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${order.itemCount} ürün',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Fiyat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₺${order.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Alt kısım - Durum
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: order.statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.sm)),
              ),
              child: Row(
                children: [
                  Icon(order.statusIcon, color: order.statusColor, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    order.statusText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: order.statusColor,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: order.statusColor, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.background,
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textTertiary,
        size: 24,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

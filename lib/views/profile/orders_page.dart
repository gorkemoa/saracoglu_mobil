import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/order/user_order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  
  bool _isLoading = true;
  String? _errorMessage;
  UserOrdersResponse? _ordersResponse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _orderService.getOrders();

    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _ordersResponse = response;
      } else {
        _errorMessage = response.message;
      }
    });
  }

  List<UserOrder> get _activeOrders => _ordersResponse?.activeOrders ?? [];
  List<UserOrder> get _completedOrders => _ordersResponse?.completedOrders ?? [];
  List<UserOrder> get _cancelledOrders => _ordersResponse?.cancelledOrders ?? [];
  List<UserOrder> get _returnOrders => _ordersResponse?.returnOrders ?? [];

  Color _getStatusColor(int statusID) {
    switch (statusID) {
      case 1: // Yeni Sipariş
        return AppColors.info;
      case 2: // Tedarik Sürecinde
        return AppColors.warning;
      case 3: // Hazırlanıyor
        return AppColors.warning;
      case 4: // Kargoya Verildi
        return AppColors.primary;
      case 5: // Onaylandı
        return AppColors.success;
      case 6: // İptal Edildi
      case 7: // Üye Tarafından İptal Edildi
        return AppColors.error;
      case 8: // İade Talebi Var
      case 9: // İade Kargoya Verildi
      case 10: // İade İnceleniyor
        return AppColors.warning;
      case 11: // İade Edildi
        return AppColors.success;
      case 12: // İade Reddedildi
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _getStatusIcon(int statusID) {
    switch (statusID) {
      case 1: // Yeni Sipariş
        return Icons.fiber_new_outlined;
      case 2: // Tedarik Sürecinde
        return Icons.schedule;
      case 3: // Hazırlanıyor
        return Icons.inventory_2_outlined;
      case 4: // Kargoya Verildi
        return Icons.local_shipping_outlined;
      case 5: // Onaylandı
        return Icons.check_circle_outline;
      case 6: // İptal Edildi
      case 7: // Üye Tarafından İptal Edildi
        return Icons.cancel_outlined;
      case 8: // İade Talebi Var
        return Icons.assignment_return_outlined;
      case 9: // İade Kargoya Verildi
        return Icons.local_shipping_outlined;
      case 10: // İade İnceleniyor
        return Icons.search;
      case 11: // İade Edildi
        return Icons.check_circle_outline;
      case 12: // İade Reddedildi
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

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
              isScrollable: true,
              labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: 'Aktif (${_activeOrders.length})'),
                Tab(text: 'Tamamlanan (${_completedOrders.length})'),
                Tab(text: 'İptal (${_cancelledOrders.length})'),
                Tab(text: 'İade (${_returnOrders.length})'),
              ],
            ),
          ),

          // Content
          SliverFillRemaining(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrderList(_activeOrders),
                          _buildOrderList(_completedOrders),
                          _buildOrderList(_cancelledOrders),
                          _buildOrderList(_returnOrders),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Siparişler yükleniyor...',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage ?? 'Bir hata oluştu',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: Icon(Icons.refresh),
              label: Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<UserOrder> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: orders.length,
        separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
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
              _ordersResponse?.emptyMessage ?? 'Bu kategoride henüz siparişiniz bulunmuyor.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(UserOrder order) {
    final statusColor = _getStatusColor(order.orderStatusID);
    final statusIcon = _getStatusIcon(order.orderStatusID);
    final firstProduct = order.products.isNotEmpty ? order.products.first : null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: Sipariş detayına git
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
                      child: firstProduct?.productImage.isNotEmpty == true
                          ? Image.network(
                              firstProduct!.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
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
                          order.orderCode,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          order.orderDate,
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${order.totalProduct} ürün',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (order.orderPayment.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            order.orderPayment,
                            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Fiyat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.orderAmount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (order.orderDiscount.isNotEmpty && order.orderDiscount != '0,00 TL') ...[
                        SizedBox(height: 2),
                        Text(
                          '-${order.orderDiscount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Alt kısım - Durum
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.sm)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    order.orderStatusTitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: statusColor, size: 20),
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
}

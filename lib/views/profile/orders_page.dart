import '../../models/order/order_status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/order/user_order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  UserOrdersResponse? _ordersResponse;
  List<OrderStatusModel> _statusList = [];
  int? _selectedStatusFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Future.wait ile paralel istek at (Performans artışı)
      final results = await Future.wait([
        _orderService.getOrders(),
        _orderService.getOrderStatusList(),
      ]);

      final ordersResponse = results[0] as UserOrdersResponse;
      final statusResponse = results[1] as OrderStatusListResponse;

      setState(() {
        _isLoading = false;

        if (ordersResponse.isSuccess) {
          _ordersResponse = ordersResponse;
        } else {
          _errorMessage = ordersResponse.message;
        }

        if (statusResponse.isSuccess) {
          _statusList = statusResponse.statusList;
        }
        // Status listesi kritik hata sebebi değil, orders geldiyse devam et
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Veriler yüklenirken bir hata oluştu';
      });
    }
  }

  List<UserOrder> get _allOrders => _ordersResponse?.orders ?? [];

  List<UserOrder> get _filteredOrders {
    var orders = _allOrders;

    // Durum filtreleme
    if (_selectedStatusFilter != null) {
      orders = orders
          .where((order) => order.orderStatusID == _selectedStatusFilter)
          .toList();
    }

    // Arama filtreleme
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) {
        final orderCodeMatch = order.orderCode.toLowerCase().contains(
          _searchQuery,
        );
        final productMatch = order.products.any(
          (product) => product.productName.toLowerCase().contains(_searchQuery),
        );
        final statusMatch = order.orderStatusTitle.toLowerCase().contains(
          _searchQuery,
        );
        return orderCodeMatch || productMatch || statusMatch;
      }).toList();
    }

    return orders;
  }

  Color _parseColor(String colorString) {
    if (colorString.isEmpty) return AppColors.textTertiary;
    try {
      var hexColor = colorString.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      if (hexColor.length == 8) {
        return Color(int.parse("0x$hexColor"));
      }
    } catch (e) {
      // debugPrint('Color parse error: $e');
    }
    return AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Siparişlerim',
          style: AppTypography.h5.copyWith(
            fontSize: 16,
          ), // Kept 16 but using theme font
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _buildSearchBar(),
                _buildStatusLegend(),
                SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                ? _buildErrorState()
                : _buildOrderList(_filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: AppColors.textTertiary,
          ), // Reduced from 48
          SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage ?? 'Bir hata oluştu',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: _loadOrders,
            style: TextButton.styleFrom(textStyle: AppTypography.buttonMedium),
            child: Text('Tekrar Dene'),
          ),
        ],
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
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48, // Reduced from 64
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Henüz siparişiniz yok',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(UserOrder order) {
    final statusColor = _parseColor(order.orderStatusColor);
    final isCompleted = order.orderStatusID == 5; // Assuming 5 is Delivered

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderID: order.orderID,
              orderCode: order.orderCode,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius
              .borderRadiusSM, // Smaller radius for "smaller" look or standard
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date and Total | Details Link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderDate,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Toplam: ',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: order.orderAmount,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors
                                  .primary, // Orange from theme (AppColors.warning)
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(
                          orderID: order.orderID,
                          orderCode: order.orderCode,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                    ), // Görseldeki hafif aşağı hizalama
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Dikey ortalama
                        children: [
                          Text(
                            'Detaylar',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 2), //
                            child: Icon(
                              Icons.chevron_right,
                              size: AppSizes.iconXS,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1, color: AppColors.divider),
            ),
            // Status Line and Action Button
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check : Icons.local_shipping_outlined,
                  color: statusColor,
                  size: AppSizes.iconXS, // 16px
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    order.orderStatusTitle,
                    style: AppTypography.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isCompleted)
                  _buildOutlinedButton(
                    'Değerlendir',
                    Icons.star_border,
                    AppColors.primary,
                    () {
                      // Review action
                    },
                  ),
              ],
            ),

            SizedBox(height: AppSpacing.sm),

            // Product Images
            SizedBox(
              height: 48, // Reduced from 60
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: order.products.take(4).length,
                separatorBuilder: (_, __) => SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final product = order.products[index];
                  return Container(
                    width: 36, // Reduced from 48
                    height: 48, // Reduced from 60
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: AppRadius.borderRadiusXS,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          product.productImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported,
                            size: 12, // Reduced
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: AppSpacing.sm),

            // Footer Info RIDVAN DÜZELTECEK LÜTFEN ŞİKAYET ETME BENİ
            Text(
              '${order.orderStatusText}',
              style: AppTypography.bodySmall.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ), // Reduced vertical padding
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderRadiusXS,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: color), // Reduced from 14
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Reduced from 12
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              child: Row(
                children: [
                  SizedBox(width: AppSpacing.sm),

                  // SEARCH TEXTFIELD
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        setState(() => _searchQuery = v);
                      },
                      decoration: InputDecoration(
                        hintText: "Sipariş Ara",
                        hintStyle: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textTertiary,
                          size: AppSizes.iconSM,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                          left: 20,
                          right: AppSpacing.sm,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AppColors.textTertiary,
                                  size: 14,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              )
                            : null,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegend() {
    if (_statusList.isEmpty) {
      return SizedBox.shrink();
    }

    final statusTitles = _statusList;

    return Container(
      height: 40, // Reduced from 48
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: statusTitles.length + 1,
        itemBuilder: (context, index) {
          final isAllFilter = index == 0;
          final statusId = isAllFilter
              ? null
              : statusTitles[index - 1].statusID;
          final statusName = isAllFilter
              ? 'Tümü'
              : statusTitles[index - 1].statusName;
          final isSelected = _selectedStatusFilter == statusId;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedStatusFilter = statusId;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              decoration: BoxDecoration(
                border: isSelected
                    ? Border(
                        bottom: BorderSide(
                          color: isAllFilter
                              ? AppColors.primary
                              : _parseColor(
                                  statusTitles[index - 1].statusColor,
                                ),
                          width: 2,
                        ),
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                statusName,
                style: isSelected
                    ? AppTypography.labelLarge.copyWith(
                        color: isAllFilter
                            ? AppColors.primary
                            : _parseColor(statusTitles[index - 1].statusColor),
                        fontSize: 13,
                      )
                    : AppTypography.bodySmall,
              ),
            ),
          );
        },
      ),
    );
  }
}

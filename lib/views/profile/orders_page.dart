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
        final orderCodeMatch =
            order.orderCode.toLowerCase().contains(_searchQuery);
        final productMatch = order.products.any(
            (product) => product.productName.toLowerCase().contains(_searchQuery));
        final statusMatch =
            order.orderStatusTitle.toLowerCase().contains(_searchQuery);
        return orderCodeMatch || productMatch || statusMatch;
      }).toList();
    }

    return orders;
  }

  Color _getStatusColor(int statusID) {
    switch (statusID) {
      case 1:
      case 2:
      case 3:
      case 4:
        return AppColors.info;
      case 5:
        return AppColors.success;
      case 6:
      case 7:
      case 12:
        return AppColors.error;
      case 8:
      case 9:
      case 10:
        return AppColors.warning;
      case 11:
        return AppColors.success;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          'Siparişlerim',
          style: AppTypography.h5.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(112),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildStatusLegend(),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildOrderList(_filteredOrders),
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
          Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
          SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage ?? 'Bir hata oluştu',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          TextButton(onPressed: _loadOrders, child: Text('Tekrar Dene')),
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
            size: 64,
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
    final statusColor = _getStatusColor(order.orderStatusID);

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
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Sipariş No, Tarih ve Durum
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderCode,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        order.orderDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.orderStatusTitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.sm),
            Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
            SizedBox(height: AppSpacing.sm),

            // Ürünler - Yatay scroll veya stack
            _buildProductsRow(order.products),

            SizedBox(height: AppSpacing.sm),
            Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
            SizedBox(height: AppSpacing.sm),

            // Footer - Toplam ve Butonlar
            Row(
              children: [
                // Toplam
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '${order.totalProduct} ürün',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        order.orderAmount,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Butonlar
                Row(
                  children: [
                    _buildSmallButton('Detay', true, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(
                            orderID: order.orderID,
                            orderCode: order.orderCode,
                          ),
                        ),
                      );
                    }),
                    SizedBox(width: 8),
                    _buildSmallButton(
                      order.orderStatusID <= 4 ? 'Takip' : 'Tekrar Al',
                      false,
                      () {
                        // TODO: Kargo takip veya tekrar sipariş
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsRow(List<OrderProduct> products) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          // Ürün görselleri (stack olarak)
          SizedBox(
            width: products.length > 1 ? 72 : 48,
            height: 48,
            child: Stack(
              children: products.take(3).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return Positioned(
                  left: index * 20.0,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: product.productImage.isNotEmpty
                          ? Image.network(
                              product.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          // Ürün isimleri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: products.take(2).map((product) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      if (product.productIsCanceled)
                        Container(
                          width: 6,
                          height: 6,
                          margin: EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          product.productName,
                          style: TextStyle(
                            fontSize: 12,
                            color: product.productIsCanceled
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'x${product.productQuantity}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isPrimary ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : AppColors.textSecondary,
          ),
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
        size: 16,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 8, AppSpacing.md, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Sipariş kodu veya ürün ara...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatusLegend() {
    if (_ordersResponse == null) {
      return SizedBox.shrink();
    }

    final statusTitles = _ordersResponse!.statusTitles;

    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: statusTitles.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAllFilter = index == 0;
          final statusId =
              isAllFilter ? null : statusTitles[index - 1].statusID;
          final statusName =
              isAllFilter ? 'Tümü' : statusTitles[index - 1].statusName;
          final isSelected = _selectedStatusFilter == statusId;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedStatusFilter = statusId;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  statusName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

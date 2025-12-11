import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order/order_detail_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderID;
  final String orderCode;

  const OrderDetailPage({
    super.key,
    required this.orderID,
    required this.orderCode,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService _orderService = OrderService();

  bool _isLoading = true;
  String? _errorMessage;
  OrderDetail? _orderDetail;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _orderService.getOrderDetail(widget.orderID);

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.order != null) {
        _orderDetail = response.order;
      } else {
        _errorMessage = response.message;
      }
    });
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

  IconData _getStatusIcon(int statusID) {
    switch (statusID) {
      case 1:
        return Icons.pending_outlined;
      case 2:
        return Icons.check_circle_outline;
      case 3:
        return Icons.inventory_2_outlined;
      case 4:
        return Icons.local_shipping_outlined;
      case 5:
        return Icons.task_alt;
      case 6:
      case 7:
      case 12:
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;

    // URL validasyonu - HTML içeriği veya geçersiz URL kontrolü
    if (url.contains('<') || url.contains('>') || !url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geçersiz URL formatı'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URL açılamadı'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
        title: Text('Sipariş Detayı', style: AppTypography.h5),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.lg),
            Text(
              _errorMessage ?? 'Sipariş detayları yüklenemedi',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _loadOrderDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final order = _orderDetail!;

    return RefreshIndicator(
      onRefresh: _loadOrderDetail,
      color: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Sipariş Durumu
          _buildStatusHeader(order),

          // Ürünler
          _buildProductsSection(order),

          // Sipariş Bilgileri
          _buildInfoCard('Sipariş Bilgileri', [
            _InfoItem('Sipariş No', order.orderCode),
            _InfoItem('Tarih', order.orderDate),
            _InfoItem('Ödeme', order.orderPaymentType),
          ]),

          // Teslimat Adresi
          if (order.addresses?.shipping != null)
            _buildAddressCard('Teslimat Adresi', order.addresses!.shipping!),

          // Fatura Adresi
          if (order.addresses?.billing != null &&
              order.addresses!.billing!.address !=
                  order.addresses!.shipping!.address)
            _buildAddressCard('Fatura Adresi', order.addresses!.billing!),

          // Ödeme Detayı
          if (order.cardInfo != null)
            _buildPaymentCard(order.cardInfo!, order.orderPaymentType),

          // Sipariş Özeti
          _buildPriceSummary(order),

          // Sipariş Notu
          if (order.orderDesc.isNotEmpty) _buildNoteSection(order.orderDesc),

          // Alt Butonlar
          _buildBottomActions(order),

          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(OrderDetail order) {
    final statusColor = _getStatusColor(order.statusID);

    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(order.statusID),
              color: statusColor,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderStatus,
                  style: AppTypography.h5.copyWith(color: statusColor),
                ),
                if (order.deliveryDate.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    order.deliveryDate,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(OrderDetail order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            'Ürünler (${order.products.length})',
            style: AppTypography.h5,
          ),
        ),
        ...order.products.map((product) => _buildProductItem(product)),
      ],
    );
  }

  Widget _buildProductItem(OrderDetailProduct product) {
    final statusColor = _getProductStatusColor(product.productStatus);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs / 2,
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün Görseli
              ClipRRect(
                borderRadius: AppRadius.borderRadiusSM,
                child: Image.network(
                  product.productImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.background,
                    child: Icon(Icons.image_outlined, size: 32),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),

              // Ürün Bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: AppTypography.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.productVariants.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        product.productVariants,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          '${product.productQuantity} Adet',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          product.productPrice,
                          style: AppTypography.h5.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Durum
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: AppRadius.borderRadiusSM,
            ),
            child: Row(
              children: [
                Icon(
                  _getProductStatusIcon(product.productStatus),
                  size: 16,
                  color: statusColor,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  product.productStatusName.isNotEmpty
                      ? product.productStatusName
                      : product.productStatusText,
                  style: AppTypography.labelSmall.copyWith(color: statusColor),
                ),
              ],
            ),
          ),

          // Kargo Takip
          if (product.trackingNumber.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () => _openUrl(product.trackingURL),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: AppColors.info,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.cargoCompany.isNotEmpty
                                ? product.cargoCompany
                                : 'Kargo',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            product.trackingNumber,
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Değerlendirme Butonu (Teslim edilen ürünler için)
          if (product.productStatus == 5 && !product.isCanceled) ...[
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showReviewDialog(product),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(color: AppColors.warning),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
                icon: Icon(Icons.star_outline, size: 18),
                label: Text('Ürünü Değerlendir'),
              ),
            ),
          ],

          // İptal/İade Butonu
          if ((product.productStatus == 1 || product.productStatus == 2) &&
              !product.isCanceled) ...[
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(product),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
                icon: Icon(Icons.cancel_outlined, size: 18),
                label: Text('Ürünü İptal/İade Et'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(OrderDetailProduct product) async {
    final TextEditingController reasonController = TextEditingController();
    int selectedQuantity = 1;
    // Varsayılan iptal tipi: Vazgeçtim (4)
    int selectedReasonId = 4;

    // Basit iptal sebepleri
    final reasons = [
      {'id': 4, 'label': 'Vazgeçtim'},
      {'id': 1, 'label': 'Yanlış Ürün'},
      {'id': 2, 'label': 'Hasarlı Ürün'},
      {'id': 3, 'label': 'Diğer'},
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text('Ürün İptal/İade Talebi', style: AppTypography.h4),
                SizedBox(height: AppSpacing.md),

                // Ürün Bilgisi
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.borderRadiusSM,
                      child: Image.network(
                        product.productImage,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          color: AppColors.background,
                          child: Icon(Icons.image_outlined, size: 20),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: AppTypography.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${product.productQuantity} Adet',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),

                // Adet Seçimi (Birden fazla ise)
                if (int.tryParse(product.productQuantity.toString()) != null &&
                    int.parse(product.productQuantity.toString()) > 1) ...[
                  Text('İade Edilecek Adet', style: AppTypography.labelMedium),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      IconButton(
                        onPressed: selectedQuantity > 1
                            ? () => setModalState(() => selectedQuantity--)
                            : null,
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        selectedQuantity.toString(),
                        style: AppTypography.h4,
                      ),
                      IconButton(
                        onPressed:
                            selectedQuantity <
                                int.parse(product.productQuantity.toString())
                            ? () => setModalState(() => selectedQuantity++)
                            : null,
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                // Sebep Seçimi
                Text('İptal Nedeni', style: AppTypography.labelMedium),
                SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<int>(
                  value: selectedReasonId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.borderRadiusSM,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                  ),
                  items: reasons
                      .map(
                        (r) => DropdownMenuItem<int>(
                          value: r['id'] as int,
                          child: Text(r['label'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setModalState(() => selectedReasonId = val);
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // Açıklama
                Text('Açıklama', style: AppTypography.labelMedium),
                SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'İptal nedeninizi detaylandırın...',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.borderRadiusSM,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Vazgeç'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelOrder(
                            productID: product.productID,
                            quantity: selectedQuantity,
                            reasonId: selectedReasonId,
                            description: reasonController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Talebi Gönder'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _cancelOrder({
    required int productID,
    required int quantity,
    required int reasonId,
    required String description,
  }) async {
    // Açıklama kontrolü
    if (description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen bir iptal nedeni giriniz'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          Center(child: CircularProgressIndicator(color: AppColors.error)),
    );

    final response = await _orderService.cancelOrder(
      orderID: widget.orderID,
      products: [
        {
          "productID": productID,
          "productQuantity": quantity,
          "cancelType": reasonId,
          "cancelDesc": description,
        },
      ],
    );

    // Dialog kapa
    if (mounted) Navigator.pop(context);

    if (mounted) {
      if (response.success) {
        // Başarılı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'İptal talebiniz alındı'),
            backgroundColor: AppColors.success,
          ),
        );
        // Sayfayı yenile
        _loadOrderDetail();
      } else {
        // Hata
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'İşlem başarısız'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getProductStatusColor(int status) {
    switch (status) {
      case 1:
        return AppColors.warning;
      case 2:
      case 3:
        return AppColors.info;
      case 4:
      case 5:
        return AppColors.success;
      case 6:
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _getProductStatusIcon(int status) {
    switch (status) {
      case 1:
        return Icons.pending_outlined;
      case 2:
        return Icons.check_circle_outline;
      case 3:
        return Icons.inventory_2_outlined;
      case 4:
        return Icons.local_shipping_outlined;
      case 5:
        return Icons.task_alt;
      case 6:
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildInfoCard(String title, List<_InfoItem> items) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h5),
          SizedBox(height: AppSpacing.md),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(item.value, style: AppTypography.labelMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String title, OrderAddress address) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h5),
          SizedBox(height: AppSpacing.md),
          Text(address.addressName, style: AppTypography.labelMedium),
          SizedBox(height: 4),
          Text(
            address.addressPhone,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            [
              address.address,
              address.addressNeighbourhood,
              address.addressDistrict,
              address.addressCity,
            ].where((s) => s.isNotEmpty).join(', '),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(OrderCardInfo cardInfo, String paymentType) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ödeme', style: AppTypography.h5),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.credit_card, color: AppColors.textSecondary, size: 20),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cardInfo.cardNumber, style: AppTypography.labelMedium),
                    SizedBox(height: 4),
                    Text(
                      paymentType,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(OrderDetail order) {
    final hasDiscount =
        order.orderDiscount.isNotEmpty &&
        order.orderDiscount != '0' &&
        !order.orderDiscount.contains('0,00') &&
        !order.orderDiscount.contains('0.00');

    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sipariş Özeti', style: AppTypography.h5),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ürün Sayısı',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${order.products.length} Adet',
                style: AppTypography.labelMedium,
              ),
            ],
          ),
          if (hasDiscount) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İndirim',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '-${order.orderDiscount}',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: AppSpacing.md),
          Divider(height: 1),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Toplam', style: AppTypography.h5),
              Text(
                order.orderAmount,
                style: AppTypography.h4.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(String note) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusMD,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.note_outlined, size: 20, color: AppColors.warning),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sipariş Notu',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4),
                Text(note, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(OrderDetail order) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: Column(
        children: [
          if (order.salesAgreement.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => _showSalesAgreement(order.salesAgreement),
              child: Text(
                'Mesafeli Satış Sözleşmesi',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSalesAgreement(String htmlContent) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            children: [
              // Başlık
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mesafeli Satış Sözleşmesi',
                        style: AppTypography.h5,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // İçerik
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: _buildHtmlContent(htmlContent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHtmlContent(String html) {
    // Basit HTML parse (temel etiketler için)
    String cleanedText = html
        .replaceAll(RegExp(r'<[^>]*>'), '') // HTML etiketlerini kaldır
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&Iuml;', 'İ')
        .replaceAll('&iuml;', 'i')
        .replaceAll('&Gbreve;', 'Ğ')
        .replaceAll('&gbreve;', 'ğ')
        .replaceAll('&Scedil;', 'Ş')
        .replaceAll('&scedil;', 'ş')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .trim();

    return Text(cleanedText, style: AppTypography.bodyMedium);
  }

  void _showReviewDialog(OrderDetailProduct product) {
    int selectedRating = 0;
    final TextEditingController commentController = TextEditingController();
    bool showName = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Ürünü Değerlendir'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ürün Bilgisi
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.productImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: AppColors.background,
                          child: Icon(Icons.image_outlined, size: 24),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        product.productName,
                        style: AppTypography.labelMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),

                // Puan
                Text('Puanınız', style: AppTypography.labelMedium),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                      icon: Icon(
                        selectedRating > index ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 32,
                      ),
                    );
                  }),
                ),
                SizedBox(height: AppSpacing.md),

                // Yorum
                Text('Yorumunuz', style: AppTypography.labelMedium),
                SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Ürün hakkında düşüncelerinizi paylaşın...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),

                // İsim göster
                CheckboxListTile(
                  title: Text('Adımı göster', style: AppTypography.bodyMedium),
                  value: showName,
                  onChanged: (value) {
                    setState(() {
                      showName = value ?? true;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: selectedRating > 0 && commentController.text.isNotEmpty
                  ? () {
                      Navigator.pop(context);
                      _submitReview(
                        product.productID,
                        commentController.text,
                        selectedRating,
                        showName,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(
    int productID,
    String comment,
    int rating,
    bool showName,
  ) async {
    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final result = await _orderService.addComment(
        productID: productID,
        comment: comment,
        commentRating: rating,
        showName: showName,
      );

      // Loading kapat
      Navigator.pop(context);

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorumunuz başarıyla kaydedildi'),
            backgroundColor: AppColors.success,
          ),
        );
        // Sayfayı yenile
        _loadOrderDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Yorum eklenirken hata oluştu'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Loading kapat
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}

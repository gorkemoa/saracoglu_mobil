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
  final Set<int> _selectedProductIds = {};

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
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildBottomAction() {
    // Bulk selection removed as per redesign
    return SizedBox.shrink();
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
          // 1. Sipariş Özeti (Header)
          _buildOrderSummaryHeader(order),
          Divider(thickness: 8, color: AppColors.background), // Kalın ayırıcı
          // 2. Tahmini Teslimat

          // 3. Sipariş Durum Çubuğu (Progress Bar)
          _buildOrderProgressBar(order),

          Divider(thickness: 8, color: AppColors.background),

          // 4. Kargo ve Teslimat Detayı (Metin olarak)
          // 4. Kargo ve Teslimat Detayı (Metin olarak)
          // Removed global cargo info as per redesign - now inside product items

          // 5. Ürünler Listesi
          ...order.products.map((product) => _buildProductItem(product)),

          Divider(thickness: 8, color: AppColors.background),

          // 6. Adres Bilgileri
          if (order.addresses?.shipping != null)
            _buildAddressSection(
              order.addresses!.shipping!,
              'Teslimat Adresi',
              cargoCompany: order.products.isNotEmpty
                  ? order.products
                        .firstWhere(
                          (p) => p.cargoCompany.isNotEmpty,
                          orElse: () => order.products.first,
                        )
                        .cargoCompany
                  : null,
            ),

          if (order.addresses?.billing != null)
            _buildAddressSection(order.addresses!.billing!, 'Fatura Adresi'),

          Divider(thickness: 8, color: AppColors.background),

          // 7. Ödeme Bilgileri
          if (order.cardInfo != null) _buildPaymentSection(order),

          Divider(thickness: 8, color: AppColors.background),

          // 8. Sözleşmeler
          _buildContractsSection(order),

          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryHeader(OrderDetail order) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Sipariş No:', '#${order.orderCode}'),
          SizedBox(height: AppSpacing.xs),
          _buildSummaryRow(
            'Sipariş Tarihi:',
            order.orderDate,
          ), // Tarih formatı gerekebilir
          SizedBox(height: AppSpacing.xs),
          _buildSummaryRow(
            'Sipariş Özeti:',
            '${order.products.length} Ürün',
            valueColor: AppColors.primary,
          ),
          SizedBox(height: AppSpacing.xs),
          // Sipariş Detayı: API'den gelen statüs texti veya özeti
          _buildSummaryRow(
            'Sipariş Durumu:',
            order.orderStatus,
            valueColor: AppColors.primary,
          ),
          SizedBox(height: AppSpacing.xs),
          _buildSummaryRow(
            'Toplam:',
            order.orderAmount,
            valueColor: AppColors.textPrimary,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderProgressBar(OrderDetail order) {
    // Statüs ID'ye göre adım belirleme
    // 1: Sipariş Alındı
    // 2: Hazırlanıyor
    // 3: Hazırlanıyor (Tedarik sürecinde vb.)
    // 4: Kargoya Verildi
    // 5: Teslim Edildi
    int currentStep = 0;
    if (order.statusID >= 1) currentStep = 1;
    if (order.statusID >= 2) currentStep = 2;
    if (order.statusID >= 4) currentStep = 3;
    if (order.statusID == 5) currentStep = 4;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepWidth = constraints.maxWidth / 4;
          return Stack(
            children: [
              // Çizgi
              Positioned(
                top: 12,
                left: stepWidth / 2,
                right: stepWidth / 2,
                child: Container(height: 2, color: AppColors.border),
              ),
              // Aktif Çizgi
              Positioned(
                top: 12,
                left: stepWidth / 2,
                right:
                    stepWidth / 2 +
                    (stepWidth * (4 - currentStep)), // Basit mantık
                child: Container(height: 2, color: AppColors.success),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepItem('Siparişiniz\nAlındı', 1, currentStep),
                  _buildStepItem('Siparişiniz\nHazırlanıyor', 2, currentStep),
                  _buildStepItem('Kargoya\nVerildi', 3, currentStep),
                  _buildStepItem('Teslim\nEdildi', 4, currentStep),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepItem(String title, int step, int currentStep) {
    bool isActive = step <= currentStep;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.success : AppColors.border,
                width: 2,
              ),
            ),
            child: isActive
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: isActive ? AppColors.success : AppColors.textTertiary,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // _buildCargoCompanyInfo removed - content moved to _buildProductItem

  Widget _buildProductItem(OrderDetailProduct product) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(color: AppColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery & Cargo Header for Product
          if (product.deliveryDate.isNotEmpty ||
              product.cargoCompany.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.deliveryDate.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 16,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Teslimat: ${product.deliveryDate}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (product.cargoCompany.isNotEmpty) ...[
                    if (product.deliveryDate.isNotEmpty) SizedBox(height: 4),
                    Text(
                      'Kargo: ${product.cargoCompany}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: AppRadius.borderRadiusSM,
                child: Image.network(
                  product.productImage,
                  width: 70, // Slightly smaller
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 90,
                    color: AppColors.background,
                    child: Icon(Icons.image_outlined, size: 28),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2),
                    Text(
                      product.productName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Adet: ${product.productQuantity}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.productPrice,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Tracking Number
                    if (product.trackingNumber.isNotEmpty) ...[
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: product.trackingNumber),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Takip numarası kopyalandı'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Takip No: ${product.trackingNumber}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 8),
                    // Action Buttons Row
                    Row(
                      children: [
                        if (product.isCargo)
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (product.trackingURL.isNotEmpty) {
                                    _openUrl(product.trackingURL);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Kargo Takip',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (product.isCargo &&
                            (product.isRating ||
                                (!product.isCanceled && product.isCancelable)))
                          SizedBox(width: 8),
                        if (product.isRating)
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton(
                                onPressed: () => _showReviewDialog(product),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Değerlendir',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (product.isRating &&
                            (!product.isCanceled && product.isCancelable))
                          SizedBox(width: 8),
                        if (!product.isCanceled && product.isCancelable)
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton(
                                onPressed: () =>
                                    _showBulkCancelDialog([product]),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: AppColors.textSecondary,
                                  side: BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'İptal/İade',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (product.productNotes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Not: ${product.productNotes}',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showBulkCancelDialog([
    List<OrderDetailProduct>? explicitProducts,
  ]) async {
    // 1. Loading göster ve nedenleri çek
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          Center(child: CircularProgressIndicator(color: AppColors.error)),
    );

    final reasonsResponse = await _orderService.getCancelTypes();
    if (!mounted) return;
    Navigator.pop(context); // Loading kapat

    if (!reasonsResponse.isSuccess || reasonsResponse.types.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reasonsResponse.message ?? 'İptal nedenleri yüklenemedi',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final reasonTypes = reasonsResponse.types;
    int selectedReasonId = reasonTypes.first.typeID;
    final TextEditingController reasonController = TextEditingController();

    // Seçili ürünleri bul
    List<OrderDetailProduct> selectedProducts = [];

    if (explicitProducts != null && explicitProducts.isNotEmpty) {
      selectedProducts = explicitProducts;
    } else {
      selectedProducts = _orderDetail!.products
          .where((p) => _selectedProductIds.contains(p.productID))
          .toList();
    }

    // Her ürün için adet takibi (Default 1)
    // Key: productID, Value: quantity
    Map<int, int> productQuantities = {
      for (var p in selectedProducts) p.productID: 1,
    };

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
            child: SingleChildScrollView(
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
                  Text(
                    '${selectedProducts.length} Ürün İçin İptal/İade Talebi',
                    style: AppTypography.h4,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Seçili ürünlerin listesi ve adet seçimi
                  ...selectedProducts.map((product) {
                    final maxQty = product.productQuantity;
                    final currentQty =
                        productQuantities[product.productID] ?? 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.borderRadiusSM,
                            child: Image.network(
                              product.productImage,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 40,
                                height: 40,
                                color: AppColors.background,
                                child: Icon(Icons.image_outlined, size: 20),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              product.productName,
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Adet Seçimi (Birden fazla ise)
                          if (maxQty > 1) ...[
                            IconButton(
                              onPressed: currentQty > 1
                                  ? () => setModalState(
                                      () =>
                                          productQuantities[product.productID] =
                                              currentQty - 1,
                                    )
                                  : null,
                              icon: Icon(Icons.remove_circle_outline, size: 20),
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.all(4),
                            ),
                            Text(
                              currentQty.toString(),
                              style: AppTypography.labelMedium,
                            ),
                            IconButton(
                              onPressed: currentQty < maxQty
                                  ? () => setModalState(
                                      () =>
                                          productQuantities[product.productID] =
                                              currentQty + 1,
                                    )
                                  : null,
                              icon: Icon(Icons.add_circle_outline, size: 20),
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.all(4),
                            ),
                          ] else
                            Text(
                              '1 Adet',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  Divider(),
                  SizedBox(height: AppSpacing.sm),

                  // Sebep Seçimi
                  Text(
                    'İptal Nedeni (Tümü İçin)',
                    style: AppTypography.labelMedium,
                  ),
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
                    items: reasonTypes
                        .map(
                          (r) => DropdownMenuItem<int>(
                            value: r.typeID,
                            child: Text(r.typeName),
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

                            // Map to list of objects
                            final productsPayload = selectedProducts
                                .map(
                                  (p) => {
                                    'productID': p.productID,
                                    'productQuantity':
                                        productQuantities[p.productID] ?? 1,
                                    'cancelType': selectedReasonId,
                                    'cancelDesc': reasonController
                                        .text, // Same desc for all
                                  },
                                )
                                .toList();

                            _performBulkCancel(productsPayload);
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
            ),
          );
        },
      ),
    );
  }

  Future<void> _performBulkCancel(
    List<Map<String, dynamic>> productsPayload,
  ) async {
    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          Center(child: CircularProgressIndicator(color: AppColors.error)),
    );

    final response = await _orderService.cancelOrder(
      orderID: widget.orderID,
      products: productsPayload,
    );

    // Kapat loading
    Navigator.pop(context);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'İptal/İade talebiniz alındı'),
          backgroundColor: AppColors.success,
        ),
      );
      // Sayfayı yenile ve seçimleri temizle
      _selectedProductIds.clear();
      _loadOrderDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'İşlem başarısız'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildAddressSection(
    OrderAddress address,
    String title, {
    String? cargoCompany,
  }) {
    final isDeliveryAddress = title.contains('Teslimat');

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (address.addressTitle.isNotEmpty)
                      Text(
                        address.addressTitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          Divider(
            height: AppSpacing.lg,
            color: AppColors.border.withOpacity(0.5),
          ),

          // Recipient Info
          _buildAddressInfoRow(
            Icons.person_outline,
            'Alıcı',
            address.addressName,
          ),
          SizedBox(height: AppSpacing.sm),

          // Address
          _buildAddressInfoRow(
            Icons.location_on_outlined,
            'Adres',
            '${address.address}\n${address.addressNeighbourhood.isNotEmpty ? address.addressNeighbourhood + ', ' : ''}${address.addressDistrict}/${address.addressCity}',
          ),
          SizedBox(height: AppSpacing.sm),

          // Phone
          _buildAddressInfoRow(
            Icons.phone_outlined,
            'Telefon',
            address.addressPhone,
          ),

          // Cargo Company (only for delivery address)
          if (isDeliveryAddress &&
              cargoCompany != null &&
              cargoCompany.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            _buildAddressInfoRow(
              Icons.local_shipping,
              'Kargo Firması',
              cargoCompany,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(OrderDetail order) {
    double discount = _parsePrice(order.orderDiscount);

    // Format strings

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ödeme Bilgileri',
                style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
              ),
              if (order.cardInfo != null)
                Row(
                  children: [
                    // Masterpass/Card Icon simulation
                    Text(order.cardInfo!.cardBankName),
                    SizedBox(width: 8),
                    Text(
                      '**** **** ${order.cardInfo!.cardNumber.length > 4 ? order.cardInfo!.cardNumber.substring(order.cardInfo!.cardNumber.length - 4) : order.cardInfo!.cardNumber} - ${order.orderInstallment}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Financial Rows
          _buildPaymentRow('Ara Toplam', order.orderSubTotal),
          _buildPaymentRow('Kargo', order.orderCargoAmount),

          if (discount > 0.01)
            _buildPaymentRow('İndirim', '-${order.orderDiscount}'),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, color: AppColors.border),
          ),

          _buildPaymentRow('Toplam:', order.orderAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary)
                : AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            value,
            style: isTotal
                ? AppTypography.h5.copyWith(color: AppColors.warning)
                : AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }

  // Helper methods for price parsing
  double _parsePrice(String priceStr) {
    if (priceStr.isEmpty) return 0.0;
    try {
      // Remove ' TL', 'TL', whitespace
      String clean = priceStr.replaceAll(' TL', '').replaceAll('TL', '').trim();

      // Handle Turkish locale: 1.234,56 -> 1234.56
      // Remove thousand separators (.)
      clean = clean.replaceAll('.', '');
      // Replace decimal separator (,) with (.)
      clean = clean.replaceAll(',', '.');

      return double.parse(clean);
    } catch (e) {
      debugPrint('Error parsing price: $priceStr - $e');
      return 0.0;
    }
  }

  Widget _buildContractsSection(OrderDetail order) {
    return ExpansionTile(
      title: Text('Sözleşmeler', style: AppTypography.h5),
      children: [
        ListTile(
          title: Text('Mesafeli Satış Sözleşmesi'),
          trailing: Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            if (order.salesAgreement.isNotEmpty) {
              _showSalesAgreement(order.salesAgreement);
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Sözleşme bulunamadı')));
            }
          },
        ),
      ],
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

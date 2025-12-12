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
    if (_selectedProductIds.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _showBulkCancelDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Seçili Ürünleri (${_selectedProductIds.length}) İade/İptal Et',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
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
          // 1. Sipariş Özeti (Header)
          _buildOrderSummaryHeader(order),
          Divider(thickness: 8, color: AppColors.background), // Kalın ayırıcı
          // 2. Tahmini Teslimat
          if (order.deliveryDate.isNotEmpty ||
              true) // Her zaman gösterelim veya koşula bağlayalım
            _buildDeliveryAndSellerInfo(order),

          Divider(thickness: 1, color: const Color.fromARGB(255, 11, 10, 10)),

          // 3. Sipariş Durum Çubuğu (Progress Bar)
          _buildOrderProgressBar(order),

          Divider(thickness: 8, color: AppColors.background),

          // 4. Kargo ve Teslimat Detayı (Metin olarak)
          if (order.products.any((p) => p.cargoCompany.isNotEmpty))
            _buildCargoCompanyInfo(order),

          // 5. Ürünler Listesi
          ...order.products.map((product) => _buildProductItem(product)),

          Divider(thickness: 8, color: AppColors.background),

          // 6. Adres Bilgileri
          if (order.addresses?.shipping != null)
            _buildAddressSection(
              order.addresses!.shipping!,
              'Teslimat Adresi',
            ), // Başlık değişebilir

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

  Widget _buildDeliveryAndSellerInfo(OrderDetail order) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.deliveryDate.isNotEmpty)
            _buildSummaryRow('Teslimat Tarihi:', order.deliveryDate),
          _buildSummaryRow('Teslimat No:', order.orderCode),

          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    'Siparişi Değerlendir',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildCargoCompanyInfo(OrderDetail order) {
    // Sadece ilk kargo bilgisini gösterelim veya genel bir bilgi
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.deliveryDate.isNotEmpty)
                Text(
                  'Aşağıdaki ürünler ${order.deliveryDate} tarihinde teslim edilecektir.',
                  style: AppTypography.bodySmall,
                ), // Örnek metin
              Text(
                'Kargo Firması: ${order.products.first.cargoCompany}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              if (order.products.first.trackingURL.isNotEmpty)
                _openUrl(order.products.first.trackingURL);
            },
            child: Text(
              'Teslimat Detay',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderDetailProduct product) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.isCancelReturn)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 24),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _selectedProductIds.contains(product.productID),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedProductIds.add(product.productID);
                          } else {
                            _selectedProductIds.remove(product.productID);
                          }
                        });
                      },
                      activeColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ClipRRect(
                borderRadius: AppRadius.borderRadiusSM,
                child: Image.network(
                  product.productImage,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 100,
                    color: AppColors.background,
                    child: Icon(Icons.image_outlined, size: 32),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.cargoCompany,

                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.productName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Adet: ${product.productQuantity}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      product.productPrice,
                      style: AppTypography.h5.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    if (product.isRating)
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _showReviewDialog(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                          ),
                          child: Text('Ürünü Değerlendir'),
                        ),
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
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showBulkCancelDialog() async {
    final TextEditingController reasonController = TextEditingController();
    // Varsayılan iptal tipi: Vazgeçtim (4)
    int selectedReasonId = 4;

    // Basit iptal sebepleri
    final reasons = [
      {'id': 4, 'label': 'Vazgeçtim'},
      {'id': 1, 'label': 'Yanlış Ürün'},
      {'id': 2, 'label': 'Hasarlı Ürün'},
      {'id': 3, 'label': 'Diğer'},
    ];

    // Seçili ürünleri bul
    final selectedProducts = _orderDetail!.products
        .where((p) => _selectedProductIds.contains(p.productID))
        .toList();

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

                            // Map to list of objects
                            final productsPayload = selectedProducts
                                .map(
                                  (p) => {
                                    'productID': p.productID,
                                    'quantity':
                                        productQuantities[p.productID] ?? 1,
                                    'reasonId': selectedReasonId,
                                    'description': reasonController
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

  Widget _buildAddressSection(OrderAddress address, String title) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Alıcı: ${address.addressName}',
            style: AppTypography.bodyMedium,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            address.addressTitle,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            address.address,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (address.addressCity.isNotEmpty)
            Text(
              '${address.addressDistrict} / ${address.addressCity}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          SizedBox(height: AppSpacing.xs),
          Text(address.addressPhone, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(OrderDetail order) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ödeme Bilgileri', style: AppTypography.h5),
              // Show card icon
              if (order.cardInfo != null)
                Row(
                  children: [
                    Icon(Icons.credit_card, color: AppColors.error),
                    SizedBox(width: 4),
                    Text(
                      '**** **** ${order.cardInfo!.cardNumber.length > 4 ? order.cardInfo!.cardNumber.substring(order.cardInfo!.cardNumber.length - 4) : order.cardInfo!.cardNumber}',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          //_buildPaymentRow('Ara Toplam', order.orderAmount),
          _buildPaymentRow('Toplam', order.orderAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.h5
                : AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            value,
            style: isTotal
                ? AppTypography.h5.copyWith(color: AppColors.warning)
                : AppTypography.bodyMedium,
          ),
        ],
      ),
    );
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

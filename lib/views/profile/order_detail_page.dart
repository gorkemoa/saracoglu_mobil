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
        return Icons.hourglass_empty_rounded;
      case 2:
        return Icons.check_circle_outline_rounded;
      case 3:
        return Icons.inventory_2_outlined;
      case 4:
        return Icons.local_shipping_outlined;
      case 5:
        return Icons.check_circle_rounded;
      case 6:
      case 7:
      case 12:
        return Icons.cancel_outlined;
      case 8:
      case 9:
      case 10:
        return Icons.assignment_return_outlined;
      case 11:
        return Icons.thumb_up_alt_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('\$label kopyalandı'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
      title: Text(
        widget.orderCode,
        style: AppTypography.h5.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: true,
      actions: [
        if (_orderDetail?.isCancelVisible == true)
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showCancelDialog();
            },
            icon: Icon(Icons.close_rounded, color: AppColors.error, size: 22),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 40,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text('Bir Hata Oluştu', style: AppTypography.h4),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    _errorMessage ?? 'Sipariş detayları yüklenemedi',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  ElevatedButton.icon(
                    onPressed: _loadOrderDetail,
                    icon: Icon(Icons.refresh),
                    label: Text(
                      'Tekrar Dene',
                      style: AppTypography.buttonMedium,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusSM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final order = _orderDetail!;
    final statusColor = _getStatusColor(order.statusID);

    return RefreshIndicator(
      onRefresh: _loadOrderDetail,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),

          // Durum Banner
          SliverToBoxAdapter(child: _buildStatusBanner(order, statusColor)),

          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sipariş Bilgileri
                  _buildOrderInfoCard(order),
                  SizedBox(height: AppSpacing.md),

                  // Ürünler
                  _buildSectionTitle(
                    'Ürünler',
                    Icons.shopping_bag_outlined,
                    order.products.length,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  ...order.products.map(
                    (product) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildProductCard(product),
                    ),
                  ),

                  // Teslimat Adresi
                  if (order.addresses?.shipping != null) ...[
                    SizedBox(height: AppSpacing.md),
                    _buildSectionTitle(
                      'Teslimat Adresi',
                      Icons.local_shipping_outlined,
                      null,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildAddressCard(
                      order.addresses!.shipping!,
                      isShipping: true,
                    ),
                  ],

                  // Fatura Adresi
                  if (order.addresses?.billing != null) ...[
                    SizedBox(height: AppSpacing.md),
                    _buildSectionTitle(
                      'Fatura Adresi',
                      Icons.receipt_long_outlined,
                      null,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildAddressCard(
                      order.addresses!.billing!,
                      isShipping: false,
                    ),
                  ],

                  // Ödeme Bilgisi
                  if (order.cardInfo != null) ...[
                    SizedBox(height: AppSpacing.md),
                    _buildSectionTitle(
                      'Ödeme Bilgisi',
                      Icons.payment_outlined,
                      null,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildPaymentCard(order.cardInfo!, order.orderPaymentType),
                  ],

                  // Sipariş Özeti
                  SizedBox(height: AppSpacing.md),
                  _buildSectionTitle(
                    'Sipariş Özeti',
                    Icons.summarize_outlined,
                    null,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  _buildSummaryCard(order),

                  // Sipariş Notu
                  if (order.orderDesc.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.md),
                    _buildSectionTitle(
                      'Sipariş Notu',
                      Icons.note_outlined,
                      null,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildNoteCard(order.orderDesc),
                  ],

                  // Alt Butonlar
                  SizedBox(height: AppSpacing.xl),
                  _buildActionButtons(order),

                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(OrderDetail order, Color statusColor) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(order.statusID),
              size: 24,
              color: statusColor,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderStatus,
                  style: AppTypography.labelLarge.copyWith(color: statusColor),
                ),
                if (order.deliveryDate.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    'Tahmini Teslimat: \${order.deliveryDate}',
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

  Widget _buildSectionTitle(String title, IconData icon, int? count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTypography.h5),
        if (count != null) ...[
          SizedBox(width: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '\$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderInfoCard(OrderDetail order) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Sipariş No',
            order.orderCode,
            Icons.tag_rounded,
            isCopyable: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Sipariş Tarihi',
            order.orderDate,
            Icons.calendar_today_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Ödeme Tipi',
            order.orderPaymentType,
            Icons.payment_outlined,
          ),
          if (order.orderInvoice.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoRow(
              'Fatura',
              'Görüntüle',
              Icons.description_outlined,
              isLink: true,
              onTap: () => _openUrl(order.orderInvoice),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isCopyable = false,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: isCopyable
                ? () {
                    HapticFeedback.lightImpact();
                    _copyToClipboard(value, label);
                  }
                : isLink
                ? onTap
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLink ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                if (isCopyable) ...[
                  SizedBox(width: 4),
                  Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                ],
                if (isLink) ...[
                  SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.border.withOpacity(0.5), height: 1);
  }

  Widget _buildProductCard(OrderDetailProduct product) {
    final statusColor = _getProductStatusColor(product.productStatus);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // Ürün Bilgileri
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ürün Görseli
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusSM,
                  child: Image.network(
                    product.productImage,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.background,
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.textTertiary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                // Ürün Detayları
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: AppTypography.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.productVariants.isNotEmpty) ...[
                        SizedBox(height: 2),
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
                            '\${product.productQuantity} Adet',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Spacer(),
                          Text(
                            product.productPrice,
                            style: AppTypography.priceMain,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ürün Durumu
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              border: Border(
                top: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getProductStatusIcon(product.productStatus),
                  size: 16,
                  color: statusColor,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    product.productStatusName.isNotEmpty
                        ? product.productStatusName
                        : product.productStatusText,
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Kargo Takip
          if (product.trackingNumber.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.cargoCompany.isNotEmpty
                              ? product.cargoCompany
                              : 'Kargo Firması',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(height: 2),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _copyToClipboard(
                              product.trackingNumber,
                              'Takip numarası',
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                product.trackingNumber,
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (product.trackingURL.isNotEmpty)
                    _buildSmallButton(
                      'Takip Et',
                      true,
                      () => _openUrl(product.trackingURL),
                    ),
                ],
              ),
            ),
          ],

          // İptal Bilgisi
          if (product.isCanceled) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                border: Border(
                  top: BorderSide(color: AppColors.error.withOpacity(0.2)),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.md),
                  bottomRight: Radius.circular(AppRadius.md),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        size: 16,
                        color: AppColors.error,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'İptal Edildi',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      if (product.cancelDate.isNotEmpty)
                        Text(
                          product.cancelDate,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                  if (product.cancelDesc.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      product.cancelDesc,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Değerlendirme veya İptal Butonu
          if (!product.isCanceled &&
              (product.isRating || product.isCancelable)) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.md),
                  bottomRight: Radius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                children: [
                  if (product.isRating) ...[
                    Icon(
                      Icons.star_outline_rounded,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Bu ürünü değerlendirin',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Spacer(),
                    _buildSmallButton('Değerlendir', false, () {
                      HapticFeedback.lightImpact();
                      // TODO: Değerlendirme sayfasına git
                    }),
                  ] else if (product.isCancelable) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          // TODO: Ürün iptal işlemi
                        },
                        icon: Icon(Icons.cancel_outlined, size: 16),
                        label: Text('Ürünü İptal Et'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                            color: AppColors.error.withOpacity(0.5),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusSM,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
        return Icons.hourglass_empty_rounded;
      case 2:
        return Icons.check_circle_outline_rounded;
      case 3:
        return Icons.inventory_2_outlined;
      case 4:
        return Icons.local_shipping_outlined;
      case 5:
        return Icons.check_circle_rounded;
      case 6:
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget _buildAddressCard(OrderAddress address, {required bool isShipping}) {
    final fullAddress = [
      address.address,
      address.addressNeighbourhood,
      address.addressDistrict,
      address.addressCity,
    ].where((s) => s.isNotEmpty).join(', ');

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isShipping ? AppColors.info : AppColors.primary)
                      .withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Icon(
                  isShipping
                      ? Icons.local_shipping_outlined
                      : Icons.receipt_long_outlined,
                  size: 20,
                  color: isShipping ? AppColors.info : AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.addressTitle.isNotEmpty
                          ? address.addressTitle
                          : (isShipping ? 'Teslimat Adresi' : 'Fatura Adresi'),
                      style: AppTypography.labelLarge,
                    ),
                    if (address.addressType.isNotEmpty)
                      Text(
                        address.addressType,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.border.withOpacity(0.5), height: 1),
          SizedBox(height: AppSpacing.md),

          // Detaylar
          _buildAddressDetailRow(
            Icons.person_outline_rounded,
            'Alıcı',
            address.addressName,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildAddressDetailRow(
            Icons.phone_outlined,
            'Telefon',
            address.addressPhone,
          ),
          if (address.addressEmail.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            _buildAddressDetailRow(
              Icons.email_outlined,
              'E-posta',
              address.addressEmail,
            ),
          ],
          SizedBox(height: AppSpacing.sm),
          _buildAddressDetailRow(
            Icons.location_on_outlined,
            'Adres',
            fullAddress,
          ),

          // Fatura ek bilgileri
          if (!isShipping) ...[
            if (address.identityNumber.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              _buildAddressDetailRow(
                Icons.badge_outlined,
                'TC Kimlik No',
                address.identityNumber,
              ),
            ],
            if (address.realCompanyName.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              _buildAddressDetailRow(
                Icons.business_outlined,
                'Firma',
                address.realCompanyName,
              ),
            ],
            if (address.taxNumber.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              _buildAddressDetailRow(
                Icons.receipt_outlined,
                'Vergi No',
                address.taxNumber,
              ),
            ],
            if (address.taxAdministration.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              _buildAddressDetailRow(
                Icons.account_balance_outlined,
                'Vergi Dairesi',
                address.taxAdministration,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAddressDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall),
              SizedBox(height: 2),
              Text(value, style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(OrderCardInfo cardInfo, String paymentType) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // Kart Bilgisi
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Icon(
                  Icons.credit_card_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardInfo.cardNumber,
                      style: AppTypography.labelLarge.copyWith(
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      cardInfo.cardHolder.toUpperCase(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (cardInfo.cardAssociation.isNotEmpty)
                Text(
                  cardInfo.cardAssociation.toUpperCase(),
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (cardInfo.cardBankName.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Divider(color: AppColors.border.withOpacity(0.5), height: 1),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  cardInfo.cardBankName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Spacer(),
                Text(paymentType, style: AppTypography.labelMedium),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(OrderDetail order) {
    final hasDiscount =
        order.orderDiscount.isNotEmpty &&
        order.orderDiscount != '0' &&
        order.orderDiscount != '0,00 TL' &&
        order.orderDiscount != '0.00 TL';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Ürün Sayısı',
            '\${order.products.length} Adet',
            Icons.shopping_bag_outlined,
          ),
          if (hasDiscount) ...[
            SizedBox(height: AppSpacing.sm),
            _buildSummaryRow(
              'İndirim',
              '-\${order.orderDiscount}',
              Icons.discount_outlined,
              valueColor: AppColors.success,
            ),
          ],
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: AppRadius.borderRadiusSM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Toplam Tutar', style: AppTypography.labelLarge),
                Text(
                  order.orderAmount,
                  style: AppTypography.priceLarge.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(String note) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.note_outlined, size: 18, color: AppColors.warning),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(note, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderDetail order) {
    return Column(
      children: [
        // Ana butonlar
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // TODO: Yardım sayfasına git
                },
                icon: Icon(Icons.help_outline_rounded, size: 18),
                label: Text('Yardım'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.border),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // TODO: Tekrar sipariş ver
                },
                icon: Icon(Icons.replay_rounded, size: 18),
                label: Text('Tekrar Sipariş'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),

        // Sipariş iptal butonu
        if (order.isCancelVisible) ...[
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showCancelDialog();
              },
              icon: Icon(Icons.cancel_outlined, size: 18),
              label: Text('Siparişi İptal Et'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusSM,
                ),
              ),
            ),
          ),
        ],

        // Satış sözleşmesi
        if (order.salesAgreement.isNotEmpty) ...[
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => _openUrl(order.salesAgreement),
            child: Text(
              'Mesafeli Satış Sözleşmesi',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
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
          borderRadius: AppRadius.borderRadiusSM,
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMD),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: AppSpacing.sm),
            Text('Sipariş İptali', style: AppTypography.h4),
          ],
        ),
        content: Text(
          'Bu siparişi iptal etmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Vazgeç',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: İptal işlemi
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('İptal Et'),
          ),
        ],
      ),
    );
  }
}

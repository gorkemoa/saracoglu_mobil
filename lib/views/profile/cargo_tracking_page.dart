import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class ShipmentStatus {
  static const String preparing = 'preparing';
  static const String shipped = 'shipped';
  static const String inTransit = 'inTransit';
  static const String outForDelivery = 'outForDelivery';
  static const String delivered = 'delivered';
}

class ShipmentItem {
  final String id;
  final String orderNumber;
  final String trackingNumber;
  final String carrier;
  final String status;
  final DateTime estimatedDelivery;
  final List<TrackingStep> trackingSteps;
  final String? imageUrl;

  ShipmentItem({
    required this.id,
    required this.orderNumber,
    required this.trackingNumber,
    required this.carrier,
    required this.status,
    required this.estimatedDelivery,
    required this.trackingSteps,
    this.imageUrl,
  });
}

class TrackingStep {
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;
  final bool isCurrent;

  TrackingStep({
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class CargoTrackingPage extends StatefulWidget {
  const CargoTrackingPage({super.key});

  @override
  State<CargoTrackingPage> createState() => _CargoTrackingPageState();
}

class _CargoTrackingPageState extends State<CargoTrackingPage> {
  final List<ShipmentItem> _shipments = [
    ShipmentItem(
      id: '1',
      orderNumber: 'SRC2024001234',
      trackingNumber: 'YK123456789TR',
      carrier: 'Yurtiçi Kargo',
      status: ShipmentStatus.inTransit,
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      imageUrl: 'assets/kategorileri/aromaterapi.png',
      trackingSteps: [
        TrackingStep(
          title: 'Sipariş Alındı',
          description: 'Siparişiniz onaylandı',
          date: DateTime.now().subtract(const Duration(days: 3)),
          isCompleted: true,
        ),
        TrackingStep(
          title: 'Hazırlanıyor',
          description: 'Siparişiniz hazırlanıyor',
          date: DateTime.now().subtract(const Duration(days: 2)),
          isCompleted: true,
        ),
        TrackingStep(
          title: 'Kargoya Verildi',
          description: 'İstanbul Aktarma Merkezi',
          date: DateTime.now().subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        TrackingStep(
          title: 'Yolda',
          description: 'Ankara Dağıtım Merkezi',
          date: DateTime.now(),
          isCompleted: false,
          isCurrent: true,
        ),
        TrackingStep(
          title: 'Teslim Edildi',
          description: 'Adresinize teslim edildi',
          date: DateTime.now().add(const Duration(days: 2)),
          isCompleted: false,
        ),
      ],
    ),
  ];

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
              'Kargo Takibi',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
          ),

          // Bilgi Banner
          SliverToBoxAdapter(
            child: _buildInfoBanner(),
          ),

          // Aktif Kargolar
          if (_shipments.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                child: Text(
                  'Aktif Kargolar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildShipmentCard(_shipments[index]),
                  ),
                  childCount: _shipments.length,
                ),
              ),
            ),
          ] else
            SliverFillRemaining(
              child: _buildEmptyState(),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: AppColors.info, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Kargo takip bilgilerinizi buradan takip edebilirsiniz',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.info,
              ),
            ),
          ),
        ],
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
                  Icons.local_shipping_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Aktif Kargo Yok',
              style: AppTypography.h4,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Şu anda takip edilebilecek aktif kargonuz bulunmuyor.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentCard(ShipmentItem shipment) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showTrackingDetail(shipment);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusSM,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Görsel
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.borderRadiusXS,
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.borderRadiusXS,
                      child: shipment.imageUrl != null
                          ? Image.asset(
                              shipment.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.textTertiary,
                              ),
                            )
                          : Icon(Icons.inventory_2_outlined, color: AppColors.textTertiary),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // Bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.orderNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.textTertiary),
                            SizedBox(width: 4),
                            Text(
                              shipment.carrier,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          shipment.trackingNumber,
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  // Kopyala butonu
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shipment.trackingNumber));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 18),
                              SizedBox(width: AppSpacing.sm),
                              Text('Takip numarası kopyalandı'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(AppSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy, size: 18, color: AppColors.textTertiary),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            // Tahmini teslimat
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.sm)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.primary, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tahmini Teslimat: ${_formatDate(shipment.estimatedDelivery)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Detay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackingDetail(ShipmentItem shipment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
              ),
              // Başlık
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Text('Kargo Takip Detayı', style: AppTypography.h4),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.divider),
              // Timeline
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  itemCount: shipment.trackingSteps.length,
                  itemBuilder: (context, index) {
                    final step = shipment.trackingSteps[index];
                    final isLast = index == shipment.trackingSteps.length - 1;
                    return _buildTrackingStep(step, isLast);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingStep(TrackingStep step, bool isLast) {
    final color = step.isCompleted 
        ? AppColors.success 
        : step.isCurrent 
            ? AppColors.primary 
            : AppColors.textTertiary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: step.isCompleted || step.isCurrent 
                    ? color.withOpacity(0.1) 
                    : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: step.isCurrent ? 2 : 1,
                ),
              ),
              child: step.isCompleted
                  ? Icon(Icons.check, size: 14, color: color)
                  : step.isCurrent
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: step.isCompleted ? color : AppColors.border,
              ),
          ],
        ),
        SizedBox(width: AppSpacing.md),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: step.isCurrent ? FontWeight.w600 : FontWeight.w500,
                    color: step.isCompleted || step.isCurrent 
                        ? AppColors.textPrimary 
                        : AppColors.textTertiary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _formatDateTime(step.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

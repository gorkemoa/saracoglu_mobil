import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class ReturnStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String completed = 'completed';
}

class ReturnRequest {
  final String id;
  final String orderNumber;
  final String productName;
  final String reason;
  final String status;
  final DateTime requestDate;
  final double refundAmount;
  final String? imageUrl;

  ReturnRequest({
    required this.id,
    required this.orderNumber,
    required this.productName,
    required this.reason,
    required this.status,
    required this.requestDate,
    required this.refundAmount,
    this.imageUrl,
  });

  String get statusText {
    switch (status) {
      case ReturnStatus.pending:
        return 'İnceleniyor';
      case ReturnStatus.approved:
        return 'Onaylandı';
      case ReturnStatus.rejected:
        return 'Reddedildi';
      case ReturnStatus.completed:
        return 'Tamamlandı';
      default:
        return 'Bilinmiyor';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReturnStatus.pending:
        return AppColors.warning;
      case ReturnStatus.approved:
        return AppColors.info;
      case ReturnStatus.rejected:
        return AppColors.error;
      case ReturnStatus.completed:
        return AppColors.success;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ReturnStatus.pending:
        return Icons.hourglass_empty;
      case ReturnStatus.approved:
        return Icons.check_circle_outline;
      case ReturnStatus.rejected:
        return Icons.cancel_outlined;
      case ReturnStatus.completed:
        return Icons.verified_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

class ReturnsPage extends StatefulWidget {
  const ReturnsPage({super.key});

  @override
  State<ReturnsPage> createState() => _ReturnsPageState();
}

class _ReturnsPageState extends State<ReturnsPage> {
  final List<ReturnRequest> _returns = [
    ReturnRequest(
      id: '1',
      orderNumber: 'SRC2024001230',
      productName: 'Aromaterapi Yağı',
      reason: 'Ürün hasarlı geldi',
      status: ReturnStatus.pending,
      requestDate: DateTime.now().subtract(const Duration(days: 2)),
      refundAmount: 189.90,
      imageUrl: 'assets/kategorileri/aromaterapi.png',
    ),
    ReturnRequest(
      id: '2',
      orderNumber: 'SRC2024001225',
      productName: 'Doğal Bitkisel Çay',
      reason: 'Yanlış ürün gönderildi',
      status: ReturnStatus.approved,
      requestDate: DateTime.now().subtract(const Duration(days: 5)),
      refundAmount: 129.90,
      imageUrl: 'assets/kategorileri/dogalbitkiler.png',
    ),
    ReturnRequest(
      id: '3',
      orderNumber: 'SRC2024001220',
      productName: 'Organik Kozmetik',
      reason: 'Fikir değişikliği',
      status: ReturnStatus.completed,
      requestDate: DateTime.now().subtract(const Duration(days: 15)),
      refundAmount: 159.90,
      imageUrl: 'assets/kategorileri/organikkozmatik.png',
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
              'İade Taleplerim',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
            actions: [
              TextButton.icon(
                onPressed: () => _showNewReturnSheet(),
                icon: Icon(Icons.add, size: 18, color: AppColors.primary),
                label: Text(
                  'Yeni',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),

          // Bilgi Banner
          SliverToBoxAdapter(
            child: _buildInfoBanner(),
          ),

          // İade Listesi
          if (_returns.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildReturnCard(_returns[index]),
                  ),
                  childCount: _returns.length,
                ),
              ),
            )
          else
            SliverFillRemaining(
              child: _buildEmptyState(),
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
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'İade talebi oluşturabilmeniz için ürünün size ulaşmış olması gerekir.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.warning.withOpacity(0.9),
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
                  Icons.replay,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'İade Talebi Yok',
              style: AppTypography.h4,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Henüz iade talebiniz bulunmuyor.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnCard(ReturnRequest request) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showReturnDetail(request);
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
                      child: request.imageUrl != null
                          ? Image.asset(
                              request.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.image_outlined,
                                color: AppColors.textTertiary,
                              ),
                            )
                          : Icon(Icons.image_outlined, color: AppColors.textTertiary),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // Bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.productName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          request.orderNumber,
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          request.reason,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // İade tutarı
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₺${request.refundAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(request.requestDate),
                        style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Durum
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: request.statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.sm)),
              ),
              child: Row(
                children: [
                  Icon(request.statusIcon, color: request.statusColor, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    request.statusText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: request.statusColor,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: request.statusColor, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnDetail(ReturnRequest request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.borderRadiusRound,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text('İade Detayı', style: AppTypography.h4),
              SizedBox(height: AppSpacing.lg),
              _buildDetailRow('Sipariş No', request.orderNumber),
              _buildDetailRow('Ürün', request.productName),
              _buildDetailRow('İade Sebebi', request.reason),
              _buildDetailRow('Talep Tarihi', _formatDate(request.requestDate)),
              _buildDetailRow('İade Tutarı', '₺${request.refundAmount.toStringAsFixed(2)}'),
              SizedBox(height: AppSpacing.lg),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: request.statusColor.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Row(
                  children: [
                    Icon(request.statusIcon, color: request.statusColor, size: 24),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Durum: ${request.statusText}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: request.statusColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _getStatusDescription(request.status),
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusSM,
                    ),
                  ),
                  child: Text('Kapat', style: AppTypography.buttonMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _showNewReturnSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.replay, color: AppColors.primary, size: 32),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Yeni İade Talebi', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'İade talebi oluşturmak için siparişlerinizden birini seçmeniz gerekiyor.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Siparişlerim sayfasına yönlendir
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusSM,
                    ),
                  ),
                  child: Text('Siparişlerimi Gör', style: AppTypography.buttonMedium),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Vazgeç',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
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

  String _getStatusDescription(String status) {
    switch (status) {
      case ReturnStatus.pending:
        return 'Talebiniz incelenmektedir. En kısa sürede sonuçlandırılacaktır.';
      case ReturnStatus.approved:
        return 'Talebiniz onaylandı. Ürünü kargoya verebilirsiniz.';
      case ReturnStatus.rejected:
        return 'Talebiniz reddedildi. Detaylı bilgi için müşteri hizmetlerini arayın.';
      case ReturnStatus.completed:
        return 'İade işleminiz tamamlandı. Ödemeniz iade edildi.';
      default:
        return '';
    }
  }
}

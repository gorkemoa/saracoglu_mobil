import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/coupon/user_coupon_model.dart';
import '../../services/coupon_service.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  final CouponService _couponService = CouponService();
  List<UserCoupon> _coupons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _couponService.getCoupons();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.isSuccess) {
          _coupons = response.coupons;
        } else {
          _errorMessage =
              response.message ?? 'Kuponlar yüklenirken bir hata oluştu';
        }
      });
    }
  }

  void _copyCouponCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: AppSpacing.sm),
            Text('Kupon kodu kopyalandı'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        duration: const Duration(seconds: 2),
      ),
    );
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
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            title: Text(
              'Kuponlarım',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
          ),

          // Bilgi Banner
          SliverToBoxAdapter(child: _buildInfoBanner()),

          // Loading State
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          // Error State
          else if (_errorMessage != null)
            SliverFillRemaining(child: _buildErrorState())
          // Kupon Listesi
          else if (_coupons.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCouponCard(_coupons[index]),
                  childCount: _coupons.length,
                ),
              ),
            )
          else
            SliverFillRemaining(child: _buildEmptyState()),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Kuponlarınızı sepet sayfasında kullanabilirsiniz',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
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
              _errorMessage ?? 'Kuponlar yüklenirken bir hata oluştu',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _loadCoupons,
              icon: Icon(Icons.refresh),
              label: Text('Tekrar Dene', style: AppTypography.buttonMedium),
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
                  Icons.local_offer_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text('Kupon Bulunamadı', style: AppTypography.h4),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Henüz kullanabileceğiniz bir kuponunuz bulunmuyor.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(UserCoupon coupon) {
    final isActive = coupon.isActive;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Sol taraf - İndirim tutarı (kupon kesik kenarı efekti)
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.md - 1),
                    bottomLeft: Radius.circular(AppRadius.md - 1),
                  ),
                ),
                child: Stack(
                  children: [
                    // Kesik kenar efekti (daireler)
                    Positioned(
                      right: -8,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          4,
                          (index) => Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // İndirim bilgisi
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.lg,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              coupon.discountDisplay,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'İNDİRİM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sağ taraf - Kupon detayları
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kupon kodu ve kopyala
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Durum badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.success.withOpacity(0.1)
                                        : AppColors.error.withOpacity(0.1),
                                    borderRadius: AppRadius.borderRadiusXS,
                                  ),
                                  child: Text(
                                    coupon.isUsed
                                        ? 'Kullanıldı'
                                        : coupon.couponStatusName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs),
                                // Kupon kodu
                                Text(
                                  coupon.couponCode,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Kopyala butonu
                          if (isActive)
                            GestureDetector(
                              onTap: () => _copyCouponCode(coupon.couponCode),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: AppRadius.borderRadiusSM,
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.copy_rounded,
                                      color: AppColors.primary,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Kopyala',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: AppSpacing.sm),

                      // Kupon açıklaması (varsa)
                      if (coupon.couponDesc.isNotEmpty) ...[
                        Text(
                          coupon.couponDesc,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.sm),
                      ],

                      // Divider
                      Container(height: 1, color: AppColors.divider),

                      SizedBox(height: AppSpacing.sm),

                      // Alt bilgiler
                      Row(
                        children: [
                          // Min sepet tutarı
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_basket_outlined,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Min. ${coupon.minBasketAmount}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Geçerlilik tarihi
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatDate(coupon.couponEndDate),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarih formatını kısalt (03.12.2025 16:56 -> 03.12.2025)
  String _formatDate(String date) {
    if (date.contains(' ')) {
      return date.split(' ').first;
    }
    return date;
  }
}

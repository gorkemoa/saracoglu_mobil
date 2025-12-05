import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/delivery_address.dart';
import '../widgets/add_address_sheet.dart';
import '../services/auth_service.dart';
import 'auth/login_page.dart';

class CartItem {
  final String id;
  final String title;
  final String weight;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final bool isAssetImage;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.weight,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    this.isAssetImage = false,
    this.quantity = 1,
  });

  int? get discount {
    if (oldPrice != null && oldPrice! > price) {
      return ((oldPrice! - price) / oldPrice! * 100).round();
    }
    return null;
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> with TickerProviderStateMixin {
  // Demo adresler - gerçek uygulamada API'den gelecek
  final List<DeliveryAddress> _addresses = [
    DeliveryAddress(
      id: '1',
      title: 'Ev',
      fullAddress: 'Mansuroğlu Mah. 286/5 Sok. No: 14 Daire: 7',
      city: 'İzmir',
      district: 'Bayraklı',
      phone: '05XX XXX XX XX',
      isDefault: true,
    ),
    DeliveryAddress(
      id: '2',
      title: 'Ofis',
      fullAddress: 'Cumhuriyet Bulvarı No: 110 Kat: 4 Office701',
      city: 'İzmir',
      district: 'Konak',
      phone: '05XX XXX XX XX',
    ),
    DeliveryAddress(
      id: '3',
      title: 'Aile Evi',
      fullAddress: 'Bağbaşı Mah. 1203 Sok. No: 22',
      city: 'Denizli',
      district: 'Merkezefendi',
      phone: '05XX XXX XX XX',
    ),
    DeliveryAddress(
      id: '4',
      title: 'Yazlık',
      fullAddress: 'Bitez Mah. 2040 Sok. No: 8 Villa',
      city: 'Muğla',
      district: 'Bodrum',
      phone: '05XX XXX XX XX',
    ),
  ];

  DeliveryAddress? _selectedAddress;

  // Demo sepet ürünleri - gerçek uygulamada state management ile yönetilecek
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      title: 'Aromaterapi Yağı',
      weight: '50 ml',
      price: 189.90,
      oldPrice: 229.90,
      imageUrl: 'assets/kategorileri/aromaterapi.png',
      isAssetImage: true,
      quantity: 1,
    ),
    CartItem(
      id: '2',
      title: 'Doğal Bitkisel Çay',
      weight: '100 gr',
      price: 129.90,
      imageUrl: 'assets/kategorileri/dogalbitkiler.png',
      isAssetImage: true,
      quantity: 2,
    ),
    CartItem(
      id: '3',
      title: 'Soğuk Sıkım Zeytinyağı',
      weight: '500 ml',
      price: 349.90,
      oldPrice: 399.90,
      imageUrl: 'assets/kategorileri/soguksikimyaglar.png',
      isAssetImage: true,
      quantity: 1,
    ),
  ];

  String? _appliedCoupon;
  double _couponDiscount = 0;
  final TextEditingController _couponController = TextEditingController();
  bool _isApplyingCoupon = false;
  bool _showManualCouponInput = false;

  // Kullanıcının mevcut kuponları (gerçek uygulamada API'den gelecek)
  final List<Map<String, dynamic>> _userCoupons = [
    {
      'code': 'HOSGELDIN',
      'description': 'Hoş geldin indirimi',
      'discount': 50.0,
      'isPercentage': false,
      'minAmount': 100.0,
    },
    {
      'code': 'INDIRIM10',
      'description': '%10 indirim',
      'discount': 10.0,
      'isPercentage': true,
      'minAmount': 200.0,
    },
    {
      'code': 'SARACOGLU',
      'description': '100₺ indirim',
      'discount': 100.0,
      'isPercentage': false,
      'minAmount': 500.0,
    },
  ];

  // Animasyon kontrolcüleri
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController.forward();
    // Varsayılan adresi seç
    _selectedAddress = _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  /// Sayfayı yenile - MainScreen'den çağrılır
  void refresh() {
    // TODO: Sepet API entegrasyonu yapıldığında burası güncellenecek
    setState(() {});
  }

  @override
  void dispose() {
    _slideController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double get _totalSavings {
    return _cartItems.fold(0.0, (sum, item) {
          if (item.oldPrice != null) {
            return sum + ((item.oldPrice! - item.price) * item.quantity);
          }
          return sum;
        }) +
        _couponDiscount;
  }

  double get _shippingCost {
    return _subtotal >= 500 ? 0 : 29.90;
  }

  double get _totalPrice {
    return _subtotal + _shippingCost - _couponDiscount;
  }

  int get _totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void _updateQuantity(CartItem item, int newQuantity) {
    HapticFeedback.lightImpact();
    setState(() {
      if (newQuantity <= 0) {
        _showDeleteConfirmation(item);
      } else if (newQuantity <= 10) {
        item.quantity = newQuantity;
      }
    });
  }

  void _removeItem(CartItem item) {
    HapticFeedback.mediumImpact();
    setState(() {
      _cartItems.removeWhere((i) => i.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} sepetten kaldırıldı'),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _cartItems.add(item);
            });
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(CartItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Ürünü Kaldır', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                '${item.title} ürününü sepetinizden kaldırmak istediğinize emin misiniz?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text(
                        'Vazgeç',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeItem(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text('Kaldır', style: AppTypography.buttonMedium),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove_shopping_cart_outlined,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Sepeti Temizle', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Sepetinizdeki tüm ürünler kaldırılacak. Devam etmek istiyor musunuz?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text(
                        'Vazgeç',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _cartItems.clear();
                          _appliedCoupon = null;
                          _couponDiscount = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text('Temizle', style: AppTypography.buttonMedium),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyCoupon() async {
    if (_couponController.text.isEmpty) return;

    setState(() => _isApplyingCoupon = true);

    // Simüle edilmiş API çağrısı
    await Future.delayed(const Duration(milliseconds: 800));

    // Demo kupon kodları
    final coupons = {
      'HOSGELDIN': 50.0,
      'INDIRIM10': _subtotal * 0.10,
      'SARACOGLU': 100.0,
    };

    final code = _couponController.text.toUpperCase();

    setState(() {
      _isApplyingCoupon = false;
      if (coupons.containsKey(code)) {
        _appliedCoupon = code;
        _couponDiscount = coupons[code]!;
        _couponController.clear();
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text('Kupon kodu başarıyla uygulandı!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      } else {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text('Geçersiz kupon kodu'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    });
  }

  void _removeCoupon() {
    HapticFeedback.lightImpact();
    setState(() {
      _appliedCoupon = null;
      _couponDiscount = 0;
      _showManualCouponInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: !authService.isLoggedIn
          ? _buildLoginRequiredState()
          : (_cartItems.isEmpty ? _buildEmptyState() : _buildCartContent()),
      bottomNavigationBar: (authService.isLoggedIn && _cartItems.isNotEmpty)
          ? _buildCheckoutBar()
          : null,
    );
  }

  Widget _buildLoginRequiredState() {
    return SafeArea(
      child: Center(
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
                        AppColors.success.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 56,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                'Sepetinizi Görüntüleyin',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Alışverişe başlamak ve sepetinizi görüntülemek için giriş yapın.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    ).then((_) {
                      setState(() {}); // Sayfayı yenile
                    });
                  },
                  icon: Icon(Icons.login_rounded),
                  label: Text('Giriş Yap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMD,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ).then((_) {
                    setState(() {});
                  });
                },
                child: Text(
                  'Hesabınız yok mu? Kayıt olun',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasyonlu ikon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 140,
                  height: 140,
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      Positioned(
                        top: 30,
                        right: 30,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              Text('Sepetiniz Boş', style: AppTypography.h3),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Doğal ve sağlıklı ürünlerimizi keşfedin,\nsepetinize ekleyin.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Ana sayfaya yönlendir
                  },
                  icon: Icon(Icons.storefront_outlined),
                  label: Text(
                    'Alışverişe Başla',
                    style: AppTypography.buttonLarge,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMD,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Önerilen kategoriler
              Text(
                'Popüler Kategoriler',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryChip('Bal', Icons.water_drop_outlined),
                  SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Propolis', Icons.local_florist_outlined),
                  SizedBox(width: AppSpacing.sm),
                  _buildCategoryChip('Bitkisel', Icons.eco_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: AppRadius.borderRadiusRound,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusRound,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTypography.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return CustomScrollView(
      slivers: [
        // Custom AppBar
        SliverAppBar(
          backgroundColor: AppColors.surface,
          pinned: true,
          elevation: 0,
          scrolledUnderElevation: 2,
          expandedHeight: 60,
          title: Column(
            children: [
              Text(
                'Sepetim',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                '$_totalItems ürün',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _clearCart,
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.error,
                size: 22,
              ),
              tooltip: 'Sepeti Temizle',
            ),
          ],
        ),

        // Teslimat Adresi
        SliverToBoxAdapter(child: _buildAddressSection()),

        // Kargo Progress Bar
        SliverToBoxAdapter(child: _buildShippingProgress()),

        // Ürün Listesi
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Column(
                children: [
                  _buildCartItemCard(_cartItems[index], index),
                  if (index < _cartItems.length - 1)
                    SizedBox(height: AppSpacing.sm),
                ],
              );
            }, childCount: _cartItems.length),
          ),
        ),

        // Kupon Kodu Bölümü
        SliverToBoxAdapter(child: _buildCouponSection()),

        // Sipariş Özeti
        SliverToBoxAdapter(child: _buildOrderSummary()),

        // Alt boşluk
        SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildShippingProgress() {
    final progress = (_subtotal / 1000).clamp(0.0, 1.0);
    final remaining = 1000 - _subtotal;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: remaining <= 0
            ? AppColors.success.withOpacity(0.08)
            : AppColors.primary.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(
            remaining <= 0 ? Icons.check_circle : Icons.local_shipping_outlined,
            color: remaining <= 0 ? AppColors.success : AppColors.primary,
            size: 18,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              remaining <= 0
                  ? 'Kargo Bedava! 🎉'
                  : '₺${remaining.toStringAsFixed(0)} daha ekle, kargo bedava!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: remaining <= 0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          // Mini Progress Bar
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.borderRadiusRound,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: remaining <= 0 ? AppColors.success : AppColors.primary,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Teslimat Adresi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: _showAddressBottomSheet,
                borderRadius: AppRadius.borderRadiusXS,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusXS,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Değiştir',
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

          // Seçili Adres
          if (_selectedAddress != null)
            _buildSelectedAddressCard(_selectedAddress!)
          else
            _buildNoAddressState(),
        ],
      ),
    );
  }

  Widget _buildSelectedAddressCard(DeliveryAddress address) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.borderRadiusXS,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adres ikonu
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.borderRadiusXS,
            ),
            child: Icon(
              _getAddressIcon(address.title),
              color: AppColors.primary,
              size: 18,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          // Adres bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (address.isDefault) ...[
                      SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: AppRadius.borderRadiusXS,
                        ),
                        child: Text(
                          'Varsayılan',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  address.fullAddress,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  '${address.district}, ${address.city}',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          // Onay işareti
          Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildNoAddressState() {
    return InkWell(
      onTap: _showAddNewAddressDialog,
      borderRadius: AppRadius.borderRadiusXS,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.08),
          borderRadius: AppRadius.borderRadiusXS,
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusXS,
              ),
              child: Icon(
                Icons.add_location_alt_outlined,
                color: AppColors.warning,
                size: 18,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adres Eklenmemiş',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Sipariş verebilmek için adres eklemelisiniz',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline, color: AppColors.warning, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getAddressIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('ev') || lowerTitle.contains('home')) {
      return Icons.home_outlined;
    } else if (lowerTitle.contains('iş') ||
        lowerTitle.contains('work') ||
        lowerTitle.contains('ofis')) {
      return Icons.business_outlined;
    } else if (lowerTitle.contains('yazlık') || lowerTitle.contains('villa')) {
      return Icons.villa_outlined;
    } else if (lowerTitle.contains('aile') ||
        lowerTitle.contains('anne') ||
        lowerTitle.contains('baba')) {
      return Icons.family_restroom_outlined;
    }
    return Icons.location_on_outlined;
  }

  void _showAddressBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
                    Text('Adreslerim', style: AppTypography.h4),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showAddNewAddressDialog();
                      },
                      borderRadius: AppRadius.borderRadiusSM,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: AppColors.primary, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Yeni Ekle',
                              style: TextStyle(
                                fontSize: 12,
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
              ),
              Divider(height: 1, color: AppColors.divider),
              // Adres Listesi
              Flexible(
                child: _addresses.isEmpty
                    ? _buildEmptyAddressState()
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(AppSpacing.md),
                        itemCount: _addresses.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final address = _addresses[index];
                          final isSelected = _selectedAddress?.id == address.id;
                          return _buildAddressListItem(address, isSelected);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAddressState() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text('Henüz adres eklenmemiş', style: AppTypography.h5),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Siparişleriniz için adres ekleyin',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showAddNewAddressDialog();
            },
            icon: Icon(Icons.add_location_alt_outlined, size: 18),
            label: Text('Adres Ekle'),
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
    );
  }

  Widget _buildAddressListItem(DeliveryAddress address, bool isSelected) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedAddress = address;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text('${address.title} adresi seçildi'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
            duration: Duration(seconds: 2),
          ),
        );
      },
      borderRadius: AppRadius.borderRadiusSM,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.background,
          borderRadius: AppRadius.borderRadiusSM,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: AppSpacing.md),
            // İkon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surface,
                borderRadius: AppRadius.borderRadiusXS,
              ),
              child: Icon(
                _getAddressIcon(address.title),
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            // Adres bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: AppRadius.borderRadiusXS,
                          ),
                          child: Text(
                            'Varsayılan',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${address.district}, ${address.city}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        address.phone,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNewAddressDialog() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddNewAddressSheet(
        onAddressAdded: (newAddress) {
          setState(() {
            _addresses.add(newAddress);
            _selectedAddress = newAddress;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('${newAddress.title} adresi başarıyla eklendi'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusSM,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadius.borderRadiusSM,
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (direction) {
        _removeItem(item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusSM,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ürün Görseli
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.borderRadiusXS,
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.borderRadiusXS,
                  child: item.isAssetImage
                      ? Image.asset(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        )
                      : Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Ürün Bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.discount != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: AppRadius.borderRadiusXS,
                            ),
                            child: Text(
                              '%${item.discount}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2),
                    // Gramaj
                    Text(
                      item.weight,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    // Fiyat ve Miktar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Fiyat
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₺${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (item.oldPrice != null) ...[
                              SizedBox(width: 4),
                              Text(
                                '₺${(item.oldPrice! * item.quantity).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Miktar kontrolü
                        _buildQuantityControl(item),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
        size: 24,
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.borderRadiusXS,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: item.quantity == 1 ? Icons.delete_outline : Icons.remove,
            color: item.quantity == 1 ? AppColors.error : AppColors.textPrimary,
            onTap: () => _updateQuantity(item, item.quantity - 1),
          ),
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            color: item.quantity >= 10
                ? AppColors.textTertiary
                : AppColors.primary,
            onTap: item.quantity >= 10
                ? null
                : () => _updateQuantity(item, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderRadiusXS,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: AppColors.accent,
                size: 16,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Kupon Kodu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          if (_appliedCoupon != null)
            // Uygulanan kupon
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusXS,
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appliedCoupon!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          '₺${_couponDiscount.toStringAsFixed(0)} indirim uygulandı',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _removeCoupon,
                    borderRadius: AppRadius.borderRadiusXS,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                // Kuponlarım Dropdown
                if (_userCoupons.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.borderRadiusXS,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        childrenPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusXS,
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusXS,
                        ),
                        leading: Icon(
                          Icons.confirmation_number_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        title: Text(
                          'Kuponlarım (${_userCoupons.length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        children: _userCoupons.map((coupon) {
                          final isDisabled =
                              _subtotal < (coupon['minAmount'] as double);
                          return InkWell(
                            onTap: isDisabled
                                ? null
                                : () => _selectCoupon(coupon),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.border.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDisabled
                                          ? AppColors.textTertiary.withOpacity(
                                              0.1,
                                            )
                                          : AppColors.primary.withOpacity(0.1),
                                      borderRadius: AppRadius.borderRadiusXS,
                                    ),
                                    child: Text(
                                      coupon['code'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDisabled
                                            ? AppColors.textTertiary
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          coupon['description'] as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDisabled
                                                ? AppColors.textTertiary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Min. ₺${(coupon['minAmount'] as double).toStringAsFixed(0)} sepet tutarı',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isDisabled)
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.primary,
                                      size: 20,
                                    )
                                  else
                                    Icon(
                                      Icons.block,
                                      color: AppColors.textTertiary,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  // Veya ayracı
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Text(
                          'veya',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                ],

                // Manuel kupon girişi
                if (_showManualCouponInput || _userCoupons.isEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          style: TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Kupon kodu girin',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 10,
                            ),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.borderRadiusXS,
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.borderRadiusXS,
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.borderRadiusXS,
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: (_) => _applyCoupon(),
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      ElevatedButton(
                        onPressed: _isApplyingCoupon ? null : _applyCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: Size(70, 40),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusXS,
                          ),
                        ),
                        child: _isApplyingCoupon
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Uygula',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  )
                else
                  // Manuel giriş butonu
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showManualCouponInput = true;
                      });
                    },
                    borderRadius: AppRadius.borderRadiusXS,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: AppRadius.borderRadiusXS,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Kupon kodunu elle gir',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _selectCoupon(Map<String, dynamic> coupon) async {
    HapticFeedback.lightImpact();
    setState(() => _isApplyingCoupon = true);

    await Future.delayed(const Duration(milliseconds: 400));

    final discountAmount = coupon['isPercentage'] as bool
        ? _subtotal * (coupon['discount'] as double) / 100
        : coupon['discount'] as double;

    setState(() {
      _isApplyingCoupon = false;
      _appliedCoupon = coupon['code'] as String;
      _couponDiscount = discountAmount;
      _showManualCouponInput = false;
    });

    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text('${coupon['description']} uygulandı!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Ara Toplam', '₺${_subtotal.toStringAsFixed(2)}'),
          SizedBox(height: AppSpacing.xs),
          _buildSummaryRow(
            'Kargo',
            _shippingCost == 0
                ? 'Ücretsiz'
                : '₺${_shippingCost.toStringAsFixed(2)}',
            valueColor: _shippingCost == 0 ? AppColors.success : null,
          ),
          if (_couponDiscount > 0) ...[
            SizedBox(height: AppSpacing.xs),
            _buildSummaryRow(
              'Kupon',
              '-₺${_couponDiscount.toStringAsFixed(2)}',
              valueColor: AppColors.success,
            ),
          ],
          if (_totalSavings > 0) ...[
            SizedBox(height: AppSpacing.xs),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: AppRadius.borderRadiusXS,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    color: AppColors.success,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '₺${_totalSavings.toStringAsFixed(2)} tasarruf',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                '₺${_totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Sol - Toplam Bilgisi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Toplam',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '₺${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(width: AppSpacing.md),
            // Sağ - Ödeme Butonu
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // Ödeme sayfasına git
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ödeme sayfasına yönlendiriliyorsunuz...'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusSM,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Siparişi Tamamla',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

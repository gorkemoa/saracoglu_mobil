import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/basket/basket_model.dart';
import '../models/address/user_address_model.dart';
import '../models/coupon/user_coupon_model.dart';
import '../widgets/add_address_sheet.dart';
import '../services/auth_service.dart';
import '../services/basket_service.dart';
import '../services/address_service.dart';
import '../services/coupon_service.dart';
import 'auth/login_page.dart';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final BasketService _basketService = BasketService();
  final AddressService _addressService = AddressService();
  final CouponService _couponService = CouponService();

  // API'den gelen adresler
  List<UserAddress> _addresses = [];
  UserAddress? _selectedAddress;
  bool _isLoadingAddresses = false;

  // API'den gelen sepet verileri
  BasketData? _basketData;
  List<BasketItem> _cartItems = [];
  bool _isLoading = false;

  // API'den gelen kuponlar
  List<UserCoupon> _userCoupons = [];
  bool _isLoadingCoupons = false;

  String? _appliedCoupon;
  final TextEditingController _couponController = TextEditingController();
  bool _isApplyingCoupon = false;
  bool _showManualCouponInput = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  /// Sayfayı yenile - MainScreen'den çağrılır
  void refresh() {
    _loadAllData();
  }

  /// Tüm verileri yükle (sepet, adresler, kuponlar)
  Future<void> _loadAllData() async {
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      setState(() {
        _cartItems = [];
        _basketData = null;
        _addresses = [];
        _selectedAddress = null;
        _userCoupons = [];
        _isLoading = false;
      });
      return;
    }

    // Paralel olarak yükle
    await Future.wait([_loadBasket(), _loadAddresses(), _loadCoupons()]);
  }

  /// Sepeti API'den yükle
  Future<void> _loadBasket() async {
    final authService = AuthService();
    if (!authService.isLoggedIn) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _basketService.getUserBaskets();
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response != null && response.success && response.data != null) {
            _basketData = response.data;
            _cartItems = response.data!.baskets;
          } else {
            _basketData = null;
            _cartItems = [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Adresleri API'den yükle
  Future<void> _loadAddresses() async {
    setState(() => _isLoadingAddresses = true);

    try {
      final response = await _addressService.getAddresses();
      if (mounted) {
        setState(() {
          _isLoadingAddresses = false;
          if (response.isSuccess) {
            _addresses = response.addresses;
            // İlk adresi varsayılan olarak seç
            if (_addresses.isNotEmpty && _selectedAddress == null) {
              _selectedAddress = _addresses.first;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
      }
    }
  }

  /// Kuponları API'den yükle
  Future<void> _loadCoupons() async {
    setState(() => _isLoadingCoupons = true);

    try {
      final response = await _couponService.getCoupons();
      if (mounted) {
        setState(() {
          _isLoadingCoupons = false;
          if (response.isSuccess) {
            // Sadece aktif kuponları al
            _userCoupons = response.coupons.where((c) => c.isActive).toList();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCoupons = false);
      }
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  /// Toplam ürün adedi (sepetteki tüm ürünlerin miktarlarının toplamı)
  int get _totalItems {
    if (_cartItems.isEmpty) return 0;
    return _cartItems.fold(0, (sum, item) => sum + item.cartQuantity);
  }

  /// Fiyat string'ini double'a çevir
  double _parsePrice(String priceStr) {
    if (priceStr.isEmpty) return 0.0;
    String cleaned = priceStr
        .replaceAll('TL', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Sepetteki ürün miktarını güncelle
  void _updateQuantity(BasketItem item, int newQuantity) async {
    HapticFeedback.lightImpact();
    if (newQuantity <= 0) {
      _showDeleteConfirmation(item);
      return;
    }

    if (newQuantity > 10) return;

    final response = await _basketService.updateBasket(
      basketId: item.cartID,
      quantity: newQuantity,
    );

    if (response.success) {
      // Sepeti yeniden yükle
      await _loadBasket();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text('Miktar güncellendi'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Hata durumunda eski haline döndür
      await _loadBasket();
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text(response.message),
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
    }
  }

  /// Sepetten ürün sil
  void _removeItem(BasketItem item) async {
    HapticFeedback.mediumImpact();

    final response = await _basketService.deleteFromBasket(
      basketId: item.cartID,
    );

    if (response.success) {
      // Sepeti yeniden yükle
      await _loadBasket();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text('Ürün sepetten kaldırıldı'),
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
      }
    } else {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text(response.message),
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
    }
  }

  void _showDeleteConfirmation(BasketItem item) {
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
                '${item.productTitle} ürününü sepetinizden kaldırmak istediğinize emin misiniz?',
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
                      onPressed: () async {
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();

                        // API'den sepeti temizle
                        final response = await _basketService.clearBasket();

                        if (response.success) {
                          setState(() {
                            _cartItems.clear();
                            _basketData = null;
                            _appliedCoupon = null;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text('Sepet temizlendi'),
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
                          }
                        } else {
                          if (mounted) {
                            HapticFeedback.vibrate();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text(response.message),
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
                        }
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
    HapticFeedback.lightImpact();

    final code = _couponController.text.trim();
    final response = await _couponService.useCoupon(code);

    setState(() => _isApplyingCoupon = false);

    if (response.success) {
      // Başarılı - Sepeti yeniden yükle (indirim uygulanmış haliyle)
      await _loadBasket();

      setState(() {
        _appliedCoupon = code;
        _couponController.clear();
        _showManualCouponInput = false;
      });

      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    response.message.isNotEmpty
                        ? response.message
                        : 'Kupon kodu başarıyla uygulandı!',
                  ),
                ),
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
      }
    } else {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    response.message.isNotEmpty
                        ? response.message
                        : 'Geçersiz kupon kodu',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
    }
  }

  void _removeCoupon() async {
    HapticFeedback.lightImpact();

    // API'den kuponu iptal et
    final response = await _couponService.cancelCoupon();

    if (response.success) {
      setState(() {
        _appliedCoupon = null;
        _showManualCouponInput = false;
      });
      // Sepeti yeniden yükle (kupon kaldırıldığında)
      await _loadBasket();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text('Kupon kaldırıldı'),
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
      }
    } else {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    response.message.isNotEmpty
                        ? response.message
                        : 'Kupon kaldırılırken hata oluştu',
                  ),
                ),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: !authService.isLoggedIn
          ? _buildLoginRequiredState()
          : _isLoading
          ? _buildLoadingState()
          : (_cartItems.isEmpty ? _buildEmptyState() : _buildCartContent()),
      bottomNavigationBar:
          (authService.isLoggedIn && _cartItems.isNotEmpty && !_isLoading)
          ? _buildCheckoutBar()
          : null,
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Sepetiniz yükleniyor...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
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
    final isFreeShipping = _basketData?.isFreeShipping ?? false;
    final remaining = _parsePrice(_basketData?.remainingForFreeCargo ?? '0');
    final limit = _parsePrice(_basketData?.cargoLimitPrice ?? '0');
    final subtotal = _parsePrice(_basketData?.subtotal ?? '0');
    final progress = limit > 0 ? ((subtotal / limit).clamp(0.0, 1.0)) : 1.0;

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
        color: isFreeShipping
            ? AppColors.success.withOpacity(0.08)
            : AppColors.primary.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(
            isFreeShipping ? Icons.check_circle : Icons.local_shipping_outlined,
            color: isFreeShipping ? AppColors.success : AppColors.primary,
            size: 18,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isFreeShipping
                  ? 'Kargo Bedava! 🎉'
                  : '₺${remaining.toStringAsFixed(0)} daha ekle, kargo bedava!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isFreeShipping ? AppColors.success : AppColors.primary,
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
                  color: isFreeShipping ? AppColors.success : AppColors.primary,
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
          if (_isLoadingAddresses)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else if (_selectedAddress != null)
            _buildSelectedAddressCard(_selectedAddress!)
          else
            _buildNoAddressState(),
        ],
      ),
    );
  }

  Widget _buildSelectedAddressCard(UserAddress address) {
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
              _getAddressIcon(address.addressTitle),
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
                    Flexible(
                      child: Text(
                        address.addressTitle.isNotEmpty
                            ? address.addressTitle
                            : '${address.addressFirstName} ${address.addressLastName}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  address.address,
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
                  '${address.addressDistrict}, ${address.addressCity}',
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
                child: _isLoadingAddresses
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : _addresses.isEmpty
                    ? _buildEmptyAddressState()
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(AppSpacing.md),
                        itemCount: _addresses.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final address = _addresses[index];
                          final isSelected =
                              _selectedAddress?.addressID == address.addressID;
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

  Widget _buildAddressListItem(UserAddress address, bool isSelected) {
    final title = address.addressTitle.isNotEmpty
        ? address.addressTitle
        : '${address.addressFirstName} ${address.addressLastName}';
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
                Text('$title adresi seçildi'),
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
                _getAddressIcon(title),
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
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    address.address,
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
                      Flexible(
                        child: Text(
                          '${address.addressDistrict}, ${address.addressCity}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          address.addressPhone,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
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
          // Adresleri yeniden yükle
          _loadAddresses();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('Adres başarıyla eklendi'),
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

  Widget _buildCartItemCard(BasketItem item, int index) {
    return Dismissible(
      key: Key('${item.cartID}'),
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
        // API'den sil
        final response = await _basketService.deleteFromBasket(
          basketId: item.cartID,
        );
        if (response.success) {
          await _loadBasket();
          return false; // Liste zaten güncellendi, dismissible'ın kendi animasyonuna gerek yok
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return false;
        }
      },
      onDismissed: (direction) {
        // Artık kullanılmıyor, confirmDismiss içinde işlem yapılıyor
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
                  child: Image.network(
                    item.productImage,
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
                            item.productTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.hasDiscount)
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
                              '${item.productDiscountIcon}${item.productDiscount}',
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
                    // Birim Fiyat
                    Text(
                      item.productPrice,
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
                              item.totalPrice,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (item.hasDiscount) ...[
                              SizedBox(width: 4),
                              Text(
                                item.productPriceDiscount,
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

  Widget _buildQuantityControl(BasketItem item) {
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
            icon: item.cartQuantity == 1 ? Icons.delete_outline : Icons.remove,
            color: item.cartQuantity == 1
                ? AppColors.error
                : AppColors.textPrimary,
            onTap: () => _updateQuantity(item, item.cartQuantity - 1),
          ),
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '${item.cartQuantity}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            color: item.cartQuantity >= 10
                ? AppColors.textTertiary
                : AppColors.primary,
            onTap: item.cartQuantity >= 10
                ? null
                : () => _updateQuantity(item, item.cartQuantity + 1),
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
              if (_isLoadingCoupons) ...[
                SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
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
                          '₺${_basketData?.discountAmount ?? '0'} indirim uygulandı',
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
                if (_userCoupons.where((c) => c.isActive).isNotEmpty) ...[
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
                          'Kuponlarım (${_userCoupons.where((c) => c.isActive).length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        children: _userCoupons.where((c) => c.isActive).map((
                          coupon,
                        ) {
                          final minAmount =
                              double.tryParse(coupon.minBasketAmount) ?? 0;
                          final currentSubtotal = _parsePrice(
                            _basketData?.subtotal ?? '0',
                          );
                          final isDisabled = currentSubtotal < minAmount;
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
                                      coupon.couponCode,
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
                                          coupon.couponDesc.isNotEmpty
                                              ? coupon.couponDesc
                                              : coupon.discountDisplay,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDisabled
                                                ? AppColors.textTertiary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        if (minAmount > 0)
                                          Text(
                                            'Min. ₺${minAmount.toStringAsFixed(0)} sepet tutarı',
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
                if (_showManualCouponInput ||
                    _userCoupons.where((c) => c.isActive).isEmpty)
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

  void _selectCoupon(UserCoupon coupon) async {
    HapticFeedback.lightImpact();
    setState(() => _isApplyingCoupon = true);

    final response = await _couponService.useCoupon(coupon.couponCode);

    setState(() => _isApplyingCoupon = false);

    if (response.success) {
      // Başarılı - Sepeti yeniden yükle (indirim uygulanmış haliyle)
      await _loadBasket();

      setState(() {
        _appliedCoupon = coupon.couponCode;
        _showManualCouponInput = false;
      });

      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text('${coupon.discountDisplay} indirim uygulandı!'),
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
      }
    } else {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    response.message.isNotEmpty
                        ? response.message
                        : 'Kupon uygulanamadı',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
    }
  }

  Widget _buildOrderSummary() {
    final isFreeShipping = _basketData?.isFreeShipping ?? false;

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
          _buildSummaryRow('Sepet Toplamı', _basketData?.cartTotal ?? ''),
          SizedBox(height: AppSpacing.xs),
          _buildSummaryRow('Ara Toplam', _basketData?.subtotal ?? ''),
          SizedBox(height: AppSpacing.xs),
          if (_basketData != null) ...[
            _buildSummaryRow('KDV Topamı ', _basketData!.vatAmount),
            SizedBox(height: AppSpacing.xs),
          ],
          _buildSummaryRow(
            'Kargo',
            isFreeShipping ? 'Ücretsiz' : (_basketData?.cargoPrice ?? ''),
            valueColor: isFreeShipping ? AppColors.success : null,
          ),
          if (_basketData != null &&
              _parsePrice(_basketData!.discountAmount) > 0) ...[
            SizedBox(height: AppSpacing.xs),
            _buildSummaryRow(
              'İndirim',
              '-${_basketData!.discountAmount}',
              valueColor: AppColors.success,
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
                _basketData?.grandTotal ?? '',
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
                  'Toplam ($_totalItems ürün)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _basketData?.grandTotal ?? '',
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
                  // Adres kontrolü
                  if (_selectedAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('Lütfen bir teslimat adresi seçin'),
                          ],
                        ),
                        backgroundColor: AppColors.warning,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                    );
                    return;
                  }
                  // Toplam tutarı hesapla
                  final totalPrice = _parsePrice(
                    _basketData?.grandTotal ?? '0',
                  );
                  // Ödeme sayfasına git
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        shipAddress: _selectedAddress,
                        billAddress:
                            _selectedAddress, // Fatura adresi olarak teslimat adresini kullan
                        basketData: _basketData,
                        totalPrice: totalPrice,
                      ),
                    ),
                  ).then((_) {
                    // Ödeme sonrası sepeti yenile
                    _loadBasket();
                  });
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import '../theme/app_theme.dart';
import '../models/address/user_address_model.dart';
import '../models/basket/basket_model.dart';
import '../models/payment/payment_request_model.dart';
import '../models/payment/sales_agreement_model.dart';
import '../models/user/saved_card_model.dart';
import '../services/payment_service.dart';
import '../services/address_service.dart';
import '../widgets/add_address_sheet.dart';

/// Ödeme Sayfası
/// PayTR entegrasyonu ile kredi kartı ödemesi
///
/// NOT: API şu an geliştirme aşamasında - ileride güncellemeler yapılacak.
class PaymentPage extends StatefulWidget {
  final UserAddress? shipAddress;
  final UserAddress? billAddress;
  final BasketData? basketData;
  final double totalPrice;

  const PaymentPage({
    super.key,
    this.shipAddress,
    this.billAddress,
    this.basketData,
    required this.totalPrice,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentService _paymentService = PaymentService();
  final AddressService _addressService = AddressService();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expireMonthController = TextEditingController();
  final _expireYearController = TextEditingController();
  final _cvvController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _payWith3D = true;
  bool _saveCard = false;
  int _selectedInstallment = 1;
  String _cardType = 'bonus';

  // Fatura adresi state
  bool _billAddressSameAsShip = true;
  UserAddress? _selectedBillAddress;
  List<UserAddress> _userAddresses = [];

  // Sözleşme onay state
  bool _agreementAccepted = false;

  // Taksit Sorgulama State
  bool _isLoadingInstallments = false;
  InstallmentResponse? _installmentResponse;
  List<InstallmentOption> _installmentOptions = [];
  CardDetail? _cardDetail;

  String? _lastQueriedBin;

  // Kayıtlı Kartlar State
  bool _useSavedCard = false;
  List<SavedCardModel> _savedCards = [];
  SavedCardModel? _selectedSavedCard;
  bool _isLoadingSavedCards = false;

  @override
  void initState() {
    super.initState();
    _loadUserAddresses();
    _fetchSavedCards();
  }

  Future<void> _fetchSavedCards() async {
    setState(() => _isLoadingSavedCards = true);
    final response = await _paymentService.getSavedCards();
    if (mounted) {
      setState(() {
        _isLoadingSavedCards = false;
        if (response.success &&
            response.data != null &&
            response.data!.isNotEmpty) {
          _savedCards = response.data!;
          // Varsayılan olarak kayıtlı kart varsa ilkini seçmeyebiliriz veya kullanıcıya bırakırız.
          // _useSavedCard = true; // İstersek otomatik açabiliriz
        }
      });
    }
  }

  /// Kullanıcı adreslerini yükle
  Future<void> _loadUserAddresses() async {
    final response = await _addressService.getAddresses();
    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _userAddresses = response.addresses;
        }
      });
    }
  }

  /// Fatura adresi için kullanılacak adres ID'si
  int get _effectiveBillAddressID {
    if (_billAddressSameAsShip) {
      return widget.shipAddress?.addressID ?? 0;
    }
    return _selectedBillAddress?.addressID ??
        widget.billAddress?.addressID ??
        0;
  }

  /// Fatura adresi için kullanılacak adres
  UserAddress? get _effectiveBillAddress {
    if (_billAddressSameAsShip) {
      return widget.shipAddress;
    }
    return _selectedBillAddress ?? widget.billAddress;
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expireMonthController.dispose();
    _expireYearController.dispose();
    _cvvController.dispose();
    _paymentService.clearInstallmentCache();
    super.dispose();
  }

  /// Ödeme işlemini başlat - önce sözleşme onayı kontrolü
  /// Ödeme işlemini başlat - önce sözleşme onayı kontrolü
  Future<void> _processPayment() async {
    // Kayıtlı kart kullanmıyorsak form validasyonu yap
    if (!_useSavedCard) {
      if (!_formKey.currentState!.validate()) return;
    } else {
      if (_selectedSavedCard == null) {
        _showErrorSnackBar('Lütfen bir kayıtlı kart seçin');
        return;
      }
      // Eğer kayıtlı kart seçiliyse ve CVV zorunluysa kontrol et
      if (_selectedSavedCard!.requireCvv == '1' &&
          _cvvController.text.isEmpty) {
        _showErrorSnackBar('Lütfen CVV kodunu giriniz');
        return;
      }
    }

    // Adres kontrolü
    if (widget.shipAddress == null) {
      _showErrorSnackBar('Teslimat adresi seçilmelidir');
      return;
    }

    // Fatura adresi kontrolü
    final billAddress = _effectiveBillAddress;
    if (billAddress == null) {
      _showErrorSnackBar('Fatura adresi seçilmelidir');
      return;
    }

    // Sözleşme onayı kontrolü
    if (!_agreementAccepted) {
      _showAgreementRequiredDialog();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    PaymentResponse response;

    if (_useSavedCard && _selectedSavedCard != null) {
      // Kayıtlı kart ile ödeme
      response = await _paymentService.requestPayment(
        shipAddressID: widget.shipAddress!.addressID,
        billAddressID: _effectiveBillAddressID,
        price: widget.totalPrice,
        ctoken: _selectedSavedCard!.ctoken,
        cvv: _selectedSavedCard!.requireCvv == '1'
            ? _cvvController.text.trim()
            : null,
        payWith3D: _payWith3D,
        savedCardPay: 1,
        requireCvv: int.tryParse(_selectedSavedCard!.requireCvv ?? '0') ?? 0,
      );
    } else {
      // Yeni kart ile ödeme
      response = await _paymentService.requestPayment(
        shipAddressID: widget.shipAddress!.addressID,
        billAddressID: _effectiveBillAddressID,
        cardHolderName: _cardHolderController.text.trim(),
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expireMonth: _expireMonthController.text.trim(),
        expireYear: _expireYearController.text.trim(),
        cvv: _cvvController.text.trim(),
        cardType: _cardType,
        price: widget.totalPrice,
        installment: _selectedInstallment,
        payWith3D: _payWith3D,
        saveCard: _saveCard,
        savedCardPay: 0,
        requireCvv: 0,
      );
    }

    setState(() => _isLoading = false);

    if (response.isSuccess) {
      HapticFeedback.heavyImpact();
      _showSuccessDialog();
    } else {
      HapticFeedback.vibrate();
      _showErrorSnackBar(response.message ?? 'Ödeme işlemi başarısız oldu');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMD),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Ödeme İşlemi Tamamlandı',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Siparişiniz başarıyla oluşturuldu.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Sepet sayfasına dön
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusSM,
                ),
              ),
              child: Text('Tamam'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  /// Sözleşme onayı gerekli popup
  void _showAgreementRequiredDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMD),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 36,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Sözleşme Onayı Gerekli',
              style: AppTypography.h5,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Ödeme yapabilmek için Mesafeli Satış Sözleşmesini okumanız ve onaylamanız gerekmektedir.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSalesAgreementBottomSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusSM,
                ),
              ),
              child: Text('Sözleşmeyi Görüntüle'),
            ),
          ),
        ],
      ),
    );
  }

  /// Mesafeli Satış Sözleşmesi bottom sheet
  Future<void> _showSalesAgreementBottomSheet() async {
    if (widget.shipAddress == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SalesAgreementSheet(
        shipAddressID: widget.shipAddress!.addressID,
        billAddressID: _effectiveBillAddressID,
        paymentService: _paymentService,
        onAccept: () {
          setState(() => _agreementAccepted = true);
          Navigator.pop(context);
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  /// Fatura adresi seçimi bottom sheet
  void _showBillAddressSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressSelectorSheet(
        addresses: _userAddresses,
        selectedAddress: _selectedBillAddress,
        onAddressSelected: (address) {
          setState(() => _selectedBillAddress = address);
          Navigator.pop(context);
        },
        onAddNewAddress: () {
          Navigator.pop(context);
          _showAddAddressSheet();
        },
      ),
    );
  }

  /// Yeni adres ekleme sheet
  void _showAddAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddNewAddressSheet(
        onAddressAdded: (address) {
          // Adresleri yeniden yükle
          _loadUserAddresses();
        },
      ),
    );
  }

  /// Kart numarası değiştiğinde taksit bilgilerini sorgula
  void _onCardNumberChanged(String value) {
    final cleanedValue = value.replaceAll(' ', '');

    // Kart tipi tahmini (yerel)
    final detectedType = _paymentService.detectCardType(value);
    if (detectedType != _cardType) {
      setState(() => _cardType = detectedType);
    }

    // 8 hane girildiğinde taksit sorgula
    if (cleanedValue.length >= 8) {
      final binNumber = cleanedValue.substring(0, 8);

      // Aynı BIN için tekrar sorgu yapma
      if (binNumber != _lastQueriedBin) {
        _lastQueriedBin = binNumber;
        _fetchInstallments(binNumber);
      }
    } else {
      // 8 haneden az ise taksit bilgilerini temizle
      if (_installmentResponse != null) {
        setState(() {
          _installmentResponse = null;
          _installmentOptions = [];
          _cardDetail = null;
          _selectedInstallment = 1;
        });
      }
    }
  }

  /// Taksit bilgilerini API'den sorgula
  Future<void> _fetchInstallments(String binNumber) async {
    setState(() => _isLoadingInstallments = true);

    final response = await _paymentService.getInstallments(binNumber);

    if (!mounted) return;

    setState(() {
      _isLoadingInstallments = false;
      _installmentResponse = response;

      if (response.isSuccess) {
        _cardDetail = response.cardDetail;

        // Kart markasını API'den gelen bilgiye göre güncelle
        if (_cardDetail != null && _cardDetail!.brand.isNotEmpty) {
          _cardType = _cardDetail!.brand.toLowerCase();
        }

        // Taksit seçeneklerini hesapla
        if (response.installments != null) {
          final brandRates = response.installments!.getRatesForBrand(_cardType);
          if (brandRates != null) {
            _installmentOptions = InstallmentOption.calculate(
              basePrice: widget.totalPrice,
              rates: brandRates,
              maxInstallment: response.installments!.maxInstallmentNonBusiness,
            );
          } else {
            // Marka için taksit yoksa tek çekim
            _installmentOptions = [
              InstallmentOption(
                count: 1,
                rate: 0,
                monthlyPayment: widget.totalPrice,
                totalPayment: widget.totalPrice,
              ),
            ];
          }
        }

        // 3D Secure zorunluluğunu kontrol et
        if (_cardDetail != null && !_cardDetail!.canPayWithout3D) {
          _payWith3D = true;
        }

        // Seçili taksit geçerli mi kontrol et
        final validInstallments = _installmentOptions
            .map((e) => e.count)
            .toList();
        if (!validInstallments.contains(_selectedInstallment)) {
          _selectedInstallment = 1;
        }
      } else {
        _installmentOptions = [];
        _cardDetail = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sipariş Özeti
                _buildOrderSummary(),
                SizedBox(height: AppSpacing.sm),

                // Teslimat Adresi
                _buildShipAddressSection(),
                SizedBox(height: AppSpacing.sm),

                // Fatura Adresi
                _buildBillAddressSection(),
                SizedBox(height: AppSpacing.sm),

                // Kart Bilgileri ve Kayıtlı Kartlar
                if (_savedCards.isNotEmpty) ...[
                  _buildPaymentMethodTabs(),
                  SizedBox(height: AppSpacing.md),
                ],

                if (_useSavedCard)
                  _buildSavedCardsList()
                else
                  _buildCardSection(),

                SizedBox(height: AppSpacing.sm),

                // Taksit Seçenekleri
                _buildInstallmentSection(),
                SizedBox(height: AppSpacing.sm),

                // 3D Secure ve Kart Kaydetme
                _buildSecurityOptions(),
                SizedBox(height: AppSpacing.sm),

                // Sözleşme Onayı
                _buildAgreementSection(),
                SizedBox(height: AppSpacing.lg),

                // Ödeme Butonu
                _buildPaymentButton(),
                SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
      title: Text(
        'Ödeme',
        style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: true,
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: AppSpacing.xs),
              Text('Sipariş Özeti', style: AppTypography.labelLarge),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: AppSpacing.sm),

          if (widget.basketData != null) ...[
            _buildSummaryRow('Ara Toplam', widget.basketData!.subtotal),
            SizedBox(height: AppSpacing.xs),
            _buildSummaryRow('KDV', widget.basketData!.vatAmount),
            SizedBox(height: AppSpacing.xs),
            _buildSummaryRow(
              'Kargo',
              widget.basketData!.isFreeShipping
                  ? 'Ücretsiz'
                  : widget.basketData!.cargoPrice,
              valueColor: widget.basketData!.isFreeShipping
                  ? AppColors.success
                  : null,
            ),
            if (_parsePrice(widget.basketData!.discountAmount) > 0) ...[
              SizedBox(height: AppSpacing.xs),
              _buildSummaryRow(
                'İndirim',
                '-${widget.basketData!.discountAmount}',
                valueColor: AppColors.success,
              ),
            ],
            SizedBox(height: AppSpacing.sm),
            Divider(color: AppColors.divider, height: 1),
            SizedBox(height: AppSpacing.sm),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Toplam', style: AppTypography.labelLarge),
              Text(
                '₺${widget.totalPrice.toStringAsFixed(2)}',
                style: AppTypography.priceLarge.copyWith(fontSize: 20),
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
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildShipAddressSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusXS,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text('Teslimat Adresi', style: AppTypography.labelLarge),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          if (widget.shipAddress != null)
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.borderRadiusSM,
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.shipAddress!.addressTitle,
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: AppRadius.borderRadiusXS,
                              ),
                              child: Text(
                                'Seçili',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.shipAddress!.fullAddress,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(width: AppSpacing.xxs),
                            Text(
                              widget.shipAddress!.addressPhone,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: AppColors.success, size: 24),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: AppRadius.borderRadiusSM,
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Teslimat adresi seçilmedi',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillAddressSection() {
    final billAddress = _effectiveBillAddress;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusXS,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.info,
                  size: 16,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text('Fatura Adresi', style: AppTypography.labelLarge),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Teslimat adresiyle aynı checkbox
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _billAddressSameAsShip = !_billAddressSameAsShip;
                if (_billAddressSameAsShip) {
                  _selectedBillAddress = null;
                }
              });
            },
            borderRadius: AppRadius.borderRadiusSM,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _billAddressSameAsShip
                    ? AppColors.primary.withOpacity(0.05)
                    : AppColors.background,
                borderRadius: AppRadius.borderRadiusSM,
                border: Border.all(
                  color: _billAddressSameAsShip
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _billAddressSameAsShip
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _billAddressSameAsShip
                            ? AppColors.primary
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: _billAddressSameAsShip
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Teslimat adresiyle aynı',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: _billAddressSameAsShip
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _billAddressSameAsShip
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Farklı adres seçimi
          if (!_billAddressSameAsShip) ...[
            SizedBox(height: AppSpacing.sm),
            if (billAddress != null)
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.borderRadiusSM,
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            billAddress.addressTitle,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            billAddress.fullAddress,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showBillAddressSelector,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: _showBillAddressSelector,
                borderRadius: AppRadius.borderRadiusSM,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.borderRadiusSM,
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Fatura Adresi Seç',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, color: AppColors.primary, size: 18),
              SizedBox(width: AppSpacing.xs),
              Text('Kart Bilgileri', style: AppTypography.labelLarge),
              Spacer(),
              _buildCardTypeIcon(),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Kart Üzerindeki İsim
          _buildTextField(
            controller: _cardHolderController,
            label: 'Kart Üzerindeki İsim',
            hint: 'AD SOYAD',
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kart sahibi adı gereklidir';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.sm),

          // Kart Numarası
          _buildTextField(
            controller: _cardNumberController,
            label: 'Kart Numarası',
            hint: '0000 0000 0000 0000',
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            onChanged: _onCardNumberChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kart numarası gereklidir';
              }
              final cardNumber = value.replaceAll(' ', '');
              if (cardNumber.length < 16) {
                return 'Geçerli bir kart numarası giriniz';
              }

              return null;
            },
          ),
          SizedBox(height: AppSpacing.sm),

          // Son Kullanma Tarihi ve CVV
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    // Ay
                    Expanded(
                      child: _buildTextField(
                        controller: _expireMonthController,
                        label: 'Ay',
                        hint: 'MM',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gerekli';
                          }
                          final month = int.tryParse(value);
                          if (month == null || month < 1 || month > 12) {
                            return 'Geçersiz';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    // Yıl
                    Expanded(
                      child: _buildTextField(
                        controller: _expireYearController,
                        label: 'Yıl',
                        hint: 'YY',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gerekli';
                          }
                          if (!_paymentService.validateExpiryDate(
                            _expireMonthController.text,
                            value,
                          )) {
                            return 'Geçersiz';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // CVV
              Expanded(
                child: _buildTextField(
                  controller: _cvvController,
                  label: 'CVV',
                  hint: '***',
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Gerekli';
                    }
                    if (!_paymentService.validateCVV(value)) {
                      return 'Geçersiz';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTypeIcon() {
    IconData icon = Icons.credit_card;
    Color color;
    String? label;

    // API'den gelen kart bilgisi varsa
    if (_cardDetail != null) {
      label = _cardDetail!.brand.toUpperCase();
      switch (_cardDetail!.brand.toLowerCase()) {
        case 'bonus':
          color = Colors.purple;
          break;
        case 'axess':
          color = Colors.orange;
          break;
        case 'world':
          color = Colors.red;
          break;
        case 'maximum':
          color = Colors.blue;
          break;
        case 'paraf':
          color = Colors.teal;
          break;
        case 'cardfinans':
          color = Colors.indigo;
          break;
        case 'advantage':
          color = Colors.green;
          break;
        default:
          color = AppColors.primary;
      }
    } else {
      // Yerel tahmin
      switch (_cardType) {
        case 'bonus':
          color = Colors.purple;
          break;
        case 'axess':
          color = Colors.orange;
          break;
        case 'world':
          color = Colors.red;
          break;
        default:
          color = AppColors.textSecondary;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderRadiusXS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          if (label != null) ...[
            SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          validator: validator,
          onChanged: onChanged,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textSecondary, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text('Taksit Seçenekleri', style: AppTypography.labelLarge),
              Spacer(),
              // Kart bilgisi
              if (_cardDetail != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusXS,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.xxs),
                      Text(
                        _cardDetail!.bank,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Yükleniyor
          if (_isLoadingInstallments) ...[
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Taksit seçenekleri yükleniyor...',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
          // Kart numarası girilmedi
          else if (_installmentOptions.isEmpty) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.borderRadiusSM,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Taksit seçeneklerini görmek için kart numaranızın ilk 8 hanesini girin',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
          // Taksit seçenekleri
          else ...[
            // Kart tipi ve şema bilgisi
            if (_cardDetail != null) ...[
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: AppRadius.borderRadiusSM,
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: AppColors.success, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_cardDetail!.schema} - ${_cardDetail!.brand.toUpperCase()}',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _cardDetail!.isCreditCard
                                ? 'Kredi Kartı'
                                : 'Banka Kartı',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_cardDetail!.canPayWithout3D)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: AppRadius.borderRadiusXS,
                        ),
                        child: Text(
                          '3D Zorunlu',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Taksit Butonları
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _installmentOptions.map((option) {
                final isSelected = _selectedInstallment == option.count;

                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedInstallment = option.count);
                  },
                  borderRadius: AppRadius.borderRadiusSM,
                  child: Container(
                    width:
                        (MediaQuery.of(context).size.width -
                            AppSpacing.lg * 2 -
                            AppSpacing.md * 2 -
                            AppSpacing.sm * 2) /
                        3,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: AppRadius.borderRadiusSM,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          option.count == 1
                              ? 'Tek Çekim'
                              : '${option.count} Taksit',
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          '₺${option.monthlyPayment.toStringAsFixed(2)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _useSavedCard = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: !_useSavedCard
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: !_useSavedCard
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'Yeni Kart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: !_useSavedCard
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: !_useSavedCard
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _useSavedCard = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _useSavedCard
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: _useSavedCard
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'Kayıtlı Kartlarım',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: _useSavedCard
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _useSavedCard
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCardsList() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kayıtlı Kart Seçin', style: AppTypography.labelLarge),
          SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _savedCards.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final card = _savedCards[index];
              final isSelected = _selectedSavedCard?.ctoken == card.ctoken;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedSavedCard = card;
                    // CVV gerekip gerekmediğini kontrol et, gerekirse field temizle
                    _cvvController.clear();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.05)
                        : null,
                    borderRadius: AppRadius.borderRadiusXS,
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: card.ctoken ?? '',
                        groupValue: _selectedSavedCard?.ctoken,
                        onChanged: (val) {
                          setState(() {
                            _selectedSavedCard = card;
                            _cvvController.clear();
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Icon(Icons.credit_card, color: AppColors.textSecondary),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${card.cBrand} - ${card.cBank}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '**** **** **** ${card.last4}',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (_selectedSavedCard != null &&
              _selectedSavedCard!.requireCvv == '1') ...[
            SizedBox(height: AppSpacing.md),
            Divider(),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Güvenlik Kodu (CVV)',
              style: AppTypography.labelMedium.copyWith(color: AppColors.error),
            ),
            SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                maxLength: 4, // 3 veya 4
                decoration: InputDecoration(
                  hintText: '***',
                  counterText: '',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                ),
                onChanged: (val) {
                  //
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityOptions() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Column(
        children: [
          // 3D Secure
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _payWith3D = !_payWith3D);
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                  child: Icon(Icons.security, color: AppColors.info, size: 20),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3D Secure ile Öde',
                        style: AppTypography.labelMedium,
                      ),
                      Text(
                        'Daha güvenli ödeme için SMS onayı',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.7, // 0.6 - 0.8 arası ideal
                  child: Switch(
                    value: _payWith3D,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _payWith3D = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: AppSpacing.sm),

          // Kartı Kaydet
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _saveCard = !_saveCard);
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                  child: Icon(
                    Icons.save_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kartımı Kaydet', style: AppTypography.labelMedium),
                      Text(
                        'Sonraki alışverişlerinizde hızlı ödeme',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.7, // 0.5 - 0.9 arası denerken idealini bul
                  child: Switch(
                    value: _saveCard,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _saveCard = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        boxShadow: AppShadows.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusXS,
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: AppColors.warning,
                  size: 16,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text('Sözleşme Onayı', style: AppTypography.labelLarge),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Sözleşme Checkbox
          InkWell(
            onTap: () {
              if (!_agreementAccepted) {
                _showSalesAgreementBottomSheet();
              } else {
                HapticFeedback.lightImpact();
                setState(() => _agreementAccepted = false);
              }
            },
            borderRadius: AppRadius.borderRadiusSM,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _agreementAccepted
                    ? AppColors.success.withOpacity(0.05)
                    : AppColors.background,
                borderRadius: AppRadius.borderRadiusSM,
                border: Border.all(
                  color: _agreementAccepted
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: _agreementAccepted
                          ? AppColors.success
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _agreementAccepted
                            ? AppColors.success
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: _agreementAccepted
                        ? Icon(Icons.check, color: Colors.white, size: 10)
                        : null,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Mesafeli Satış Sözleşmesi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: '\'ni okudum ve kabul ediyorum.'),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                      ],
                    ),
                  ),
                  if (!_agreementAccepted)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textTertiary,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    // Liste boşsa veya henüz yüklenmediyse fallback değer üret
    final options = _installmentOptions;

    // Eğer liste tamamen boşsa totalPayment = 0.00 göster
    final selectedOption = options.isNotEmpty
        ? options.firstWhere(
            (e) => e.count == _selectedInstallment,
            orElse: () => options.first,
          )
        : null;

    final totalPayment =
        selectedOption?.totalPayment.toStringAsFixed(2) ?? "0.00";

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMD),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text('Güvenli Ödeme Yap', style: AppTypography.buttonLarge),
                  SizedBox(width: AppSpacing.sm),
                  if (totalPayment != "0.00")
                    Text(
                      '₺$totalPayment',
                      style: AppTypography.buttonLarge.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  double _parsePrice(String priceStr) {
    if (priceStr.isEmpty) return 0.0;
    String cleaned = priceStr
        .replaceAll('TL', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll('₺', '')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}

/// Kart numarası formatlayıcı (4'erli gruplar)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Mesafeli Satış Sözleşmesi Bottom Sheet
class _SalesAgreementSheet extends StatefulWidget {
  final int shipAddressID;
  final int billAddressID;
  final PaymentService paymentService;
  final VoidCallback onAccept;

  const _SalesAgreementSheet({
    required this.shipAddressID,
    required this.billAddressID,
    required this.paymentService,
    required this.onAccept,
  });

  @override
  State<_SalesAgreementSheet> createState() => _SalesAgreementSheetState();
}

class _SalesAgreementSheetState extends State<_SalesAgreementSheet> {
  bool _isLoading = true;
  SalesAgreementData? _agreementData;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAgreement();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAgreement() async {
    final response = await widget.paymentService.getSalesAgreement(
      shipAddressID: widget.shipAddressID,
      billAddressID: widget.billAddressID,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.isSuccess && response.data != null) {
          _agreementData = response.data;
        } else {
          _errorMessage = response.message ?? 'Sözleşme yüklenemedi';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
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

          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: AppRadius.borderRadiusSM,
                  child: Icon(Icons.close, color: AppColors.textSecondary),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _agreementData?.title ?? 'Mesafeli Satış Sözleşmesi',
                    style: AppTypography.h4,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Sözleşme yükleniyor...',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            _errorMessage!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });
                              _loadAgreement();
                            },
                            child: Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Html(
                      data: _agreementData?.desc ?? '',
                      style: {
                        'body': Style(
                          fontSize: FontSize(14),
                          color: AppColors.textPrimary,
                          lineHeight: LineHeight(1.6),
                        ),
                        'p': Style(margin: Margins.only(bottom: 12)),
                      },
                    ),
                  ),
          ),

          // Footer with accept button
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (_agreementData != null) ...[
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: AppRadius.borderRadiusSM,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 18,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Sözleşmeyi sonuna kadar okuyunuz',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_agreementData != null)
                          ? widget.onAccept
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        disabledBackgroundColor: AppColors.border,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: (_agreementData != null)
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Okudum ve Kabul Ediyorum',
                            style: AppTypography.buttonLarge.copyWith(
                              color: (_agreementData != null)
                                  ? Colors.white
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Adres Seçici Bottom Sheet
class _AddressSelectorSheet extends StatelessWidget {
  final List<UserAddress> addresses;
  final UserAddress? selectedAddress;
  final Function(UserAddress) onAddressSelected;
  final VoidCallback onAddNewAddress;

  const _AddressSelectorSheet({
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddNewAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
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

          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: AppRadius.borderRadiusSM,
                  child: Icon(Icons.close, color: AppColors.textSecondary),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Fatura Adresi Seçin', style: AppTypography.h4),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),

          // Address List
          Expanded(
            child: addresses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Kayıtlı adresiniz bulunmuyor',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      final isSelected =
                          selectedAddress?.addressID == address.addressID;

                      return InkWell(
                        onTap: () => onAddressSelected(address),
                        borderRadius: AppRadius.borderRadiusSM,
                        child: Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.05)
                                : AppColors.background,
                            borderRadius: AppRadius.borderRadiusSM,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          address.addressTitle,
                                          style: AppTypography.labelLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (address.addressType.isNotEmpty) ...[
                                          SizedBox(width: AppSpacing.xs),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSpacing.xs,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.textTertiary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  AppRadius.borderRadiusXS,
                                            ),
                                            child: Text(
                                              address.addressType,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textTertiary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      address.fullAddress,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${address.addressFirstName} ${address.addressLastName} • ${address.addressPhone}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 24,
                                )
                              else
                                Icon(
                                  Icons.radio_button_unchecked,
                                  color: AppColors.border,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Add new address button
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAddNewAddress,
                  icon: Icon(Icons.add),
                  label: Text('Yeni Adres Ekle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusSM,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

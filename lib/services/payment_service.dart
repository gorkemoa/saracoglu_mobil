import '../core/constants/api_constants.dart';
import '../models/payment/payment_request_model.dart';
import '../models/payment/sales_agreement_model.dart';
import '../models/user/saved_card_model.dart';
import 'network_service.dart';
import 'auth_service.dart';
import 'package:logger/logger.dart';

/// Ödeme yönetimi servisi - Singleton pattern
/// PayTR entegrasyonu için kullanılır
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  // Son sorgulanan taksit bilgisi (cache)
  InstallmentResponse? _cachedInstallments;
  String? _cachedBinNumber;

  /// Taksit bilgilerini sorgula (BIN numarası ile)
  /// Kartın ilk 8 hanesi girildiğinde otomatik çağrılır
  Future<InstallmentResponse> getInstallments(String binNumber) async {
    try {
      // Temizle
      binNumber = binNumber.replaceAll(' ', '');

      // En az 8 hane olmalı
      if (binNumber.length < 8) {
        return InstallmentResponse.errorResponse(
          'BIN numarası en az 8 hane olmalıdır',
        );
      }

      // Sadece ilk 8 haneyi al
      binNumber = binNumber.substring(0, 8);

      // Cache kontrolü - aynı BIN için tekrar sorgu yapma
      if (_cachedBinNumber == binNumber && _cachedInstallments != null) {
        _logger.d('📦 Returning cached installments for BIN: $binNumber');
        return _cachedInstallments!;
      }

      final token = _authService.currentUser?.token;
      if (token == null) {
        return InstallmentResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      _logger.d('📤 Get Installments Request');
      _logger.d('📦 BIN Number: $binNumber');

      final result = await _networkService.post(
        ApiConstants.getInstallments,
        body: {'userToken': token, 'binNumber': binNumber},
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = InstallmentResponse.fromJson(result.data!);
        // Cache'e kaydet
        if (response.isSuccess) {
          _cachedBinNumber = binNumber;
          _cachedInstallments = response;
        }
        return response;
      } else {
        return InstallmentResponse.errorResponse(
          result.errorMessage ?? 'Taksit bilgisi alınamadı',
        );
      }
    } catch (e) {
      _logger.e('❌ Taksit sorgulama hatası', error: e);
      return InstallmentResponse.errorResponse(
        'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Cache'i temizle
  void clearInstallmentCache() {
    _cachedBinNumber = null;
    _cachedInstallments = null;
  }

  /// PayTR ile ödeme isteği gönder
  ///
  /// NOT: Bu API şu an geliştirme aşamasında. İleride güncelleme yapılacak.
  /// Mevcut yanıt: {"error": false, "success": false, "data": {}, "200": "OK"}
  Future<PaymentResponse> requestPayment({
    required int shipAddressID,
    required int billAddressID,
    String? cardHolderName,
    String? cardNumber,
    String? expireMonth,
    String? expireYear,
    String? cvv,
    String? cardType,
    required double price,
    int installment = 1,
    int forceThreeDS = 0,
    bool payWith3D = false,
    bool saveCard = false,
    String? ctoken,
    int savedCardPay = 0,
    int requireCvv = 0,
  }) async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return PaymentResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      _logger.d('📤 PayTR Payment Request');
      _logger.d(
        '📦 Ship Address: $shipAddressID, Bill Address: $billAddressID',
      );
      _logger.d('📦 Price: $price TL');
      _logger.d('📦 3D Secure: $payWith3D, Save Card: $saveCard');

      if (ctoken != null) {
        _logger.d('📦 Using Saved Card Token: $ctoken');
        _logger.d('📦 Saved Card Pay: $savedCardPay, Require CVV: $requireCvv');
      } else {
        _logger.d('📦 Card Type: $cardType, Installment: $installment');
      }

      final request = PaymentRequest(
        userToken: token,
        shipAddressID: shipAddressID,
        billAddressID: billAddressID,
        cardHolderName: cardHolderName,
        cardNumber: cardNumber,
        expireMonth: expireMonth,
        expireYear: expireYear,
        cvv: cvv,
        cardType: cardType,
        price: price,
        installment: installment,
        forceThreeDS: forceThreeDS,
        payWith3D: payWith3D ? 1 : 0,
        saveCard: saveCard ? 1 : 0,
        ctoken: ctoken,
        savedCardPay: savedCardPay,
        requireCvv: requireCvv,
      );

      final result = await _networkService.post(
        ApiConstants.paytrPayment,
        body: request.toJson(),
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        return PaymentResponse.fromJson(result.data!);
      } else {
        return PaymentResponse.errorResponse(
          result.errorMessage ?? 'Ödeme işlemi sırasında bir hata oluştu',
        );
      }
    } catch (e) {
      _logger.e('❌ Ödeme hatası', error: e);
      return PaymentResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
    }
  }

  /// Kart numarasını formatla (4'erli gruplar halinde)
  String formatCardNumber(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cardNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cardNumber[i]);
    }
    return buffer.toString();
  }

  /// Kart numarasını maskele (son 4 hane görünsün)
  String maskCardNumber(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    if (cardNumber.length < 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $lastFour';
  }

  /// Kart tipini tahmin et (BIN numarasına göre)
  String detectCardType(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    if (cardNumber.isEmpty) return 'other';

    // Visa: 4 ile başlar
    if (cardNumber.startsWith('4')) {
      return 'bonus'; // Varsayılan olarak bonus
    }
    // Mastercard: 51-55 veya 2221-2720 ile başlar
    if (cardNumber.length >= 2) {
      final prefix = int.tryParse(cardNumber.substring(0, 2)) ?? 0;
      if (prefix >= 51 && prefix <= 55) {
        return 'world'; // Varsayılan olarak world
      }
    }
    // American Express: 34 veya 37 ile başlar
    if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
      return 'other';
    }

    return 'other';
  }

  /// Kart numarası validasyonu (Luhn algoritması)
  bool validateCardNumber(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    if (cardNumber.length < 13 || cardNumber.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.tryParse(cardNumber[i]) ?? -1;
      if (n == -1) return false;

      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// CVV validasyonu
  bool validateCVV(String cvv) {
    return cvv.length >= 3 && cvv.length <= 4 && int.tryParse(cvv) != null;
  }

  /// Son kullanma tarihi validasyonu
  bool validateExpiryDate(String month, String year) {
    final now = DateTime.now();
    final expMonth = int.tryParse(month);
    final expYear = int.tryParse(year);

    if (expMonth == null || expYear == null) return false;
    if (expMonth < 1 || expMonth > 12) return false;

    // 2 haneli yıl için 2000 ekle
    final fullYear = expYear < 100 ? 2000 + expYear : expYear;

    // Geçmiş tarih kontrolü
    if (fullYear < now.year) return false;
    if (fullYear == now.year && expMonth < now.month) return false;

    return true;
  }

  /// Mesafeli Satış Sözleşmesi getir
  Future<SalesAgreementResponse> getSalesAgreement({
    required int shipAddressID,
    required int billAddressID,
  }) async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return SalesAgreementResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      _logger.d('📤 Get Sales Agreement Request');
      _logger.d(
        '📦 Ship Address: $shipAddressID, Bill Address: $billAddressID',
      );

      final result = await _networkService.get(
        '${ApiConstants.getSalesAgreement}?userToken=$token&shipAddressID=$shipAddressID&billAddressID=$billAddressID',
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        return SalesAgreementResponse.fromJson(result.data!);
      } else {
        return SalesAgreementResponse.errorResponse(
          result.errorMessage ?? 'Sözleşme yüklenemedi',
        );
      }
    } catch (e) {
      _logger.e('❌ Sözleşme yükleme hatası', error: e);
      return SalesAgreementResponse.errorResponse(
        'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Kayıtlı kartları getir
  Future<SavedCardResponseModel> getSavedCards() async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return SavedCardResponseModel(
          error: true,
          success: false,
          message: 'Oturum açmanız gerekiyor',
        );
      }

      _logger.d('📤 Get Info User Cards');

      final result = await _networkService.get(
        '${ApiConstants.getUserSavedCards}?userToken=$token',
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        return SavedCardResponseModel.fromJson(result.data!);
      } else {
        return SavedCardResponseModel(
          error: true,
          success: false,
          message: result.errorMessage ?? 'Kartlar yüklenemedi',
        );
      }
    } catch (e) {
      _logger.e('❌ Kart listesi hatası', error: e);
      return SavedCardResponseModel(
        error: true,
        success: false,
        message: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Kart sil
  Future<SavedCardResponseModel> deleteSavedCard(String ctoken) async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return SavedCardResponseModel(
          error: true,
          success: false,
          message: 'Oturum açmanız gerekiyor',
        );
      }

      _logger.d('📤 Delete User Card Request');
      _logger.d('📦 Card Token: $ctoken');

      final result = await _networkService.post(
        ApiConstants.deleteSavedCard,
        body: {'userToken': token, 'ctoken': ctoken},
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        // Response format might be generic error/success wrapper, reused SavedCardResponseModel if structure matches or created a generic one.
        // Based on other methods, assuming it returns standard structure that can be parsed or at least status.
        // If the delete endpoint returns just success/error, we might want a simpler model, but reuse is fine for basic success check.
        return SavedCardResponseModel.fromJson(result.data!);
      } else {
        return SavedCardResponseModel(
          error: true,
          success: false,
          message: result.errorMessage ?? 'Kart silinemedi',
        );
      }
    } catch (e) {
      _logger.e('❌ Kart silme hatası', error: e);
      return SavedCardResponseModel(
        error: true,
        success: false,
        message: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }
}

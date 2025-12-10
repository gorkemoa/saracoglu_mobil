/// PayTR Ödeme İsteği Modeli
/// POST: service/payment/payment/request/paytr
class PaymentRequest {
  final String userToken;
  final int shipAddressID;
  final int billAddressID;
  final String cardHolderName;
  final String cardNumber;
  final String expireMonth;
  final String expireYear;
  final String cvv;
  final String cardType; // axess, paraf, bonus vs.
  final double price;
  final int installment; // 1 = Tek Çekim
  final int forceThreeDS; // Taksit bilgisi sorgulanırken gelen değer
  final int payWith3D; // 3D ödeme isteyip istemediği - 1 veya 0
  final int saveCard; // Kartı kaydetmek isteyip istemediği - 1 veya 0

  PaymentRequest({
    required this.userToken,
    required this.shipAddressID,
    required this.billAddressID,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expireMonth,
    required this.expireYear,
    required this.cvv,
    required this.cardType,
    required this.price,
    this.installment = 1,
    this.forceThreeDS = 0,
    this.payWith3D = 0,
    this.saveCard = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'shipAddressID': shipAddressID,
      'billAddressID': billAddressID,
      'cardHolderName': cardHolderName,
      'cardNumber': cardNumber,
      'expireMonth': expireMonth,
      'expireYear': expireYear,
      'cvv': cvv,
      'cardType': cardType,
      'price': price,
      'installment': installment,
      'forcethreeds': forceThreeDS,
      'payWith3D': payWith3D,
      'saveCard': saveCard,
    };
  }
}

/// Taksit Sorgulama İsteği Modeli
/// POST: service/payment/payment/installments
class InstallmentRequest {
  final String userToken;
  final String binNumber; // Kartın ilk 8 hanesi

  InstallmentRequest({required this.userToken, required this.binNumber});

  Map<String, dynamic> toJson() {
    return {'userToken': userToken, 'binNumber': binNumber};
  }
}

/// Taksit Sorgulama Yanıt Modeli
class InstallmentResponse {
  final bool error;
  final bool success;
  final CardDetail? cardDetail;
  final InstallmentData? installments;
  final String? message;

  InstallmentResponse({
    required this.error,
    required this.success,
    this.cardDetail,
    this.installments,
    this.message,
  });

  factory InstallmentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    CardDetail? cardDetail;
    InstallmentData? installmentData;

    if (data != null && data is Map<String, dynamic>) {
      if (data['cardDetail'] != null) {
        cardDetail = CardDetail.fromJson(data['cardDetail']);
      }
      if (data['installments'] != null) {
        installmentData = InstallmentData.fromJson(data['installments']);
      }
    }

    return InstallmentResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      cardDetail: cardDetail,
      installments: installmentData,
      message: json['message']?.toString(),
    );
  }

  factory InstallmentResponse.errorResponse(String errorMessage) {
    return InstallmentResponse(
      error: true,
      success: false,
      message: errorMessage,
    );
  }

  bool get isSuccess => success && !error;
}

/// Kart Detay Modeli
class CardDetail {
  final String status;
  final String cardType; // credit, debit
  final String businessCard; // y, n
  final String bank;
  final String brand; // world, bonus, axess vs.
  final String schema; // VISA, MASTERCARD
  final String bankCode;
  final String allowNon3D; // Y, N

  CardDetail({
    required this.status,
    required this.cardType,
    required this.businessCard,
    required this.bank,
    required this.brand,
    required this.schema,
    required this.bankCode,
    required this.allowNon3D,
  });

  factory CardDetail.fromJson(Map<String, dynamic> json) {
    return CardDetail(
      status: json['status'] ?? '',
      cardType: json['cardType'] ?? '',
      businessCard: json['businessCard'] ?? 'n',
      bank: json['bank'] ?? '',
      brand: json['brand'] ?? '',
      schema: json['schema'] ?? '',
      bankCode: json['bankCode'] ?? '',
      allowNon3D: json['allow_non3d'] ?? 'N',
    );
  }

  bool get isSuccess => status == 'success';
  bool get isCreditCard => cardType == 'credit';
  bool get isBusinessCard => businessCard.toLowerCase() == 'y';
  bool get canPayWithout3D => allowNon3D.toUpperCase() == 'Y';
}

/// Taksit Verileri Modeli
class InstallmentData {
  final String status;
  final int requestId;
  final int maxInstallmentNonBusiness;
  final Map<String, Map<int, double>> rates; // brand -> {taksit sayısı -> oran}

  InstallmentData({
    required this.status,
    required this.requestId,
    required this.maxInstallmentNonBusiness,
    required this.rates,
  });

  factory InstallmentData.fromJson(Map<String, dynamic> json) {
    final Map<String, Map<int, double>> rates = {};

    final oranlar = json['oranlar'];
    if (oranlar != null && oranlar is Map<String, dynamic>) {
      oranlar.forEach((brand, installments) {
        if (installments is Map<String, dynamic>) {
          final Map<int, double> brandRates = {};
          installments.forEach((key, value) {
            final installmentCount = int.tryParse(key);
            if (installmentCount != null) {
              brandRates[installmentCount] = (value is num)
                  ? value.toDouble()
                  : 0.0;
            }
          });
          rates[brand] = brandRates;
        }
      });
    }

    return InstallmentData(
      status: json['status'] ?? '',
      requestId: json['request_id'] ?? 0,
      maxInstallmentNonBusiness: json['max_inst_non_bus'] ?? 12,
      rates: rates,
    );
  }

  bool get isSuccess => status == 'success';

  /// Belirli bir marka için taksit oranlarını getir
  Map<int, double>? getRatesForBrand(String brand) {
    return rates[brand.toLowerCase()];
  }

  /// Tüm mevcut taksit sayılarını getir
  List<int> getAvailableInstallments(String brand) {
    final brandRates = rates[brand.toLowerCase()];
    if (brandRates == null) return [1];

    final installments = brandRates.keys.toList()..sort();
    return [1, ...installments]; // Tek çekim + taksitler
  }

  /// Belirli marka ve taksit için komisyon oranını getir
  double getRate(String brand, int installment) {
    if (installment == 1) return 0.0; // Tek çekim komisyonsuz
    final brandRates = rates[brand.toLowerCase()];
    if (brandRates == null) return 0.0;
    return brandRates[installment] ?? 0.0;
  }
}

/// Taksit Seçeneği UI Modeli
class InstallmentOption {
  final int count;
  final double rate;
  final double monthlyPayment;
  final double totalPayment;

  InstallmentOption({
    required this.count,
    required this.rate,
    required this.monthlyPayment,
    required this.totalPayment,
  });

  /// Taksit seçeneklerini hesapla
  static List<InstallmentOption> calculate({
    required double basePrice,
    required Map<int, double> rates,
    required int maxInstallment,
  }) {
    final options = <InstallmentOption>[];

    // Tek çekim
    options.add(
      InstallmentOption(
        count: 1,
        rate: 0,
        monthlyPayment: basePrice,
        totalPayment: basePrice,
      ),
    );

    // Taksitli ödemeler
    final sortedInstallments = rates.keys.toList()..sort();
    for (final installment in sortedInstallments) {
      if (installment > maxInstallment) continue;

      final rate = rates[installment] ?? 0.0;
      final totalPayment = basePrice * (1 + rate / 100);
      final monthlyPayment = totalPayment / installment;

      options.add(
        InstallmentOption(
          count: installment,
          rate: rate,
          monthlyPayment: monthlyPayment,
          totalPayment: totalPayment,
        ),
      );
    }

    return options;
  }
}

/// PayTR Ödeme Yanıt Modeli
class PaymentResponse {
  final bool error;
  final bool success;
  final Map<String, dynamic>? data;
  final String? statusCode;
  final String? message;

  PaymentResponse({
    required this.error,
    required this.success,
    this.data,
    this.statusCode,
    this.message,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] is Map<String, dynamic> ? json['data'] : {},
      statusCode: json['200']?.toString(),
      message: json['message']?.toString(),
    );
  }

  factory PaymentResponse.errorResponse(String errorMessage) {
    return PaymentResponse(error: true, success: false, message: errorMessage);
  }

  bool get isSuccess => success && !error;
}

/// Kart Tipi Enum
enum CardType {
  bonus,
  axess,
  paraf,
  world,
  cardFinans,
  maximum,
  advantage,
  other,
}

extension CardTypeExtension on CardType {
  String get value {
    switch (this) {
      case CardType.bonus:
        return 'bonus';
      case CardType.axess:
        return 'axess';
      case CardType.paraf:
        return 'paraf';
      case CardType.world:
        return 'world';
      case CardType.cardFinans:
        return 'cardfinans';
      case CardType.maximum:
        return 'maximum';
      case CardType.advantage:
        return 'advantage';
      case CardType.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case CardType.bonus:
        return 'Bonus Card';
      case CardType.axess:
        return 'Axess';
      case CardType.paraf:
        return 'Paraf';
      case CardType.world:
        return 'World';
      case CardType.cardFinans:
        return 'CardFinans';
      case CardType.maximum:
        return 'Maximum';
      case CardType.advantage:
        return 'Advantage';
      case CardType.other:
        return 'Diğer';
    }
  }
}

/// Mesafeli Satış Sözleşmesi Modeli
/// GET: service/general/general/contracts/salesAgreement
class SalesAgreementResponse {
  final bool error;
  final bool success;
  final SalesAgreementData? data;
  final String? message;

  SalesAgreementResponse({
    required this.error,
    required this.success,
    this.data,
    this.message,
  });

  factory SalesAgreementResponse.fromJson(Map<String, dynamic> json) {
    return SalesAgreementResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? SalesAgreementData.fromJson(json['data'])
          : null,
      message: json['message']?.toString(),
    );
  }

  factory SalesAgreementResponse.errorResponse(String errorMessage) {
    return SalesAgreementResponse(
      error: true,
      success: false,
      message: errorMessage,
    );
  }

  bool get isSuccess => success && !error;
}

/// Satış Sözleşmesi Verileri
class SalesAgreementData {
  final String title;
  final String desc;

  SalesAgreementData({
    required this.title,
    required this.desc,
  });

  factory SalesAgreementData.fromJson(Map<String, dynamic> json) {
    return SalesAgreementData(
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
    );
  }
}

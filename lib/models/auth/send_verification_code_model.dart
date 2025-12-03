/// Doğrulama kodu gönderme türleri
class SendCodeType {
  static const int sms = 1;
  static const int email = 2;
}

/// Doğrulama kodu gönderme isteği için model
class SendVerificationCodeRequest {
  final String userToken;
  final int sendType; // 1: SMS, 2: E-posta

  SendVerificationCodeRequest({
    required this.userToken,
    required this.sendType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'sendType': sendType,
    };
  }
}

/// Doğrulama kodu gönderme yanıtı için model
class SendVerificationCodeResponse {
  final bool error;
  final bool success;
  final String? message;
  final SendVerificationCodeData? data;
  final String? statusCode;

  SendVerificationCodeResponse({
    required this.error,
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory SendVerificationCodeResponse.fromJson(Map<String, dynamic> json) {
    return SendVerificationCodeResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? SendVerificationCodeData.fromJson(json['data']) : null,
      statusCode: json['200'],
    );
  }

  bool get isSuccess => success && !error && data != null;
}

/// Doğrulama kodu gönderme yanıtındaki data objesi
class SendVerificationCodeData {
  final String codeToken;

  SendVerificationCodeData({
    required this.codeToken,
  });

  factory SendVerificationCodeData.fromJson(Map<String, dynamic> json) {
    return SendVerificationCodeData(
      codeToken: json['codeToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeToken': codeToken,
    };
  }
}

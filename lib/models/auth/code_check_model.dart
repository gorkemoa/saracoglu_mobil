/// Kod doğrulama isteği için model
class CodeCheckRequest {
  final String code;
  final String codeToken;

  CodeCheckRequest({
    required this.code,
    required this.codeToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'codeToken': codeToken,
    };
  }
}

/// Kod doğrulama yanıtı için model
class CodeCheckResponse {
  final bool error;
  final bool success;
  final String? successMessage;
  final CodeCheckData? data;
  final String? statusCode;

  CodeCheckResponse({
    required this.error,
    required this.success,
    this.successMessage,
    this.data,
    this.statusCode,
  });

  factory CodeCheckResponse.fromJson(Map<String, dynamic> json) {
    return CodeCheckResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      data: json['data'] != null ? CodeCheckData.fromJson(json['data']) : null,
      statusCode: json['200'],
    );
  }

  bool get isSuccess => success && !error && data != null;
}

/// Kod doğrulama yanıtındaki data objesi
class CodeCheckData {
  final String passToken;

  CodeCheckData({
    required this.passToken,
  });

  factory CodeCheckData.fromJson(Map<String, dynamic> json) {
    return CodeCheckData(
      passToken: json['passToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passToken': passToken,
    };
  }
}

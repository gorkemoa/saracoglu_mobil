/// Şifre sıfırlama isteği için model
class ForgotPasswordRequest {
  final String userEmail;

  ForgotPasswordRequest({required this.userEmail});

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
    };
  }
}

/// Şifre sıfırlama yanıtı için model
class ForgotPasswordResponse {
  final bool error;
  final bool success;
  final String? message;
  final ForgotPasswordData? data;

  ForgotPasswordResponse({
    required this.error,
    required this.success,
    this.message,
    this.data,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null 
          ? ForgotPasswordData.fromJson(json['data']) 
          : null,
    );
  }

  bool get isSuccess => success && !error;

  factory ForgotPasswordResponse.errorResponse(String message) {
    return ForgotPasswordResponse(
      error: true,
      success: false,
      message: message,
    );
  }
}

/// Şifre sıfırlama yanıt verisi
class ForgotPasswordData {
  final int userId;
  final String userEmail;
  final String codeToken;

  ForgotPasswordData({
    required this.userId,
    required this.userEmail,
    required this.codeToken,
  });

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordData(
      userId: json['userID'] ?? 0,
      userEmail: json['userEmail'] ?? '',
      codeToken: json['codeToken'] ?? '',
    );
  }
}

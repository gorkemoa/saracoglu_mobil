/// Şifre güncelleme request modeli
class UpdatePasswordRequest {
  final String userToken;
  final String currentPassword;
  final String password;
  final String passwordAgain;

  UpdatePasswordRequest({
    required this.userToken,
    required this.currentPassword,
    required this.password,
    required this.passwordAgain,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'currentPassword': currentPassword,
      'password': password,
      'passwordAgain': passwordAgain,
    };
  }
}

/// Şifre güncelleme response modeli
class UpdatePasswordResponse {
  final bool isSuccess;
  final String? message;

  UpdatePasswordResponse({
    required this.isSuccess,
    this.message,
  });

  factory UpdatePasswordResponse.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['success'] == true || json['success'] == 1;
    
    // Hata mesajı için önce error_message, sonra message kontrol et
    String? message;
    if (!isSuccess) {
      message = json['error_message'] ?? json['message'];
    } else {
      message = json['message'];
    }

    return UpdatePasswordResponse(
      isSuccess: isSuccess,
      message: message,
    );
  }

  factory UpdatePasswordResponse.error(String message) {
    return UpdatePasswordResponse(
      isSuccess: false,
      message: message,
    );
  }
}

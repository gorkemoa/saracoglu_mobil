/// Hesap silme request modeli
class DeleteUserRequest {
  final String userToken;

  DeleteUserRequest({
    required this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
    };
  }
}

/// Hesap silme response modeli
class DeleteUserResponse {
  final bool isSuccess;
  final String? message;

  DeleteUserResponse({
    required this.isSuccess,
    this.message,
  });

  factory DeleteUserResponse.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['success'] == true || json['success'] == 1;
    
    // Hata mesajı için önce error_message, sonra message kontrol et
    String? message;
    if (!isSuccess) {
      message = json['error_message'] ?? json['message'];
    } else {
      message = json['message'];
    }

    return DeleteUserResponse(
      isSuccess: isSuccess,
      message: message,
    );
  }

  factory DeleteUserResponse.error(String message) {
    return DeleteUserResponse(
      isSuccess: false,
      message: message,
    );
  }
}

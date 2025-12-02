/// Login isteği için model
class LoginRequest {
  final String userName;
  final String password;

  LoginRequest({
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'password': password,
    };
  }
}

/// Login yanıtı için model
class LoginResponse {
  final bool error;
  final bool success;
  final LoginData? data;
  final String? statusCode;

  LoginResponse({
    required this.error,
    required this.success,
    this.data,
    this.statusCode,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      statusCode: json['200'],
    );
  }

  bool get isSuccess => success && !error && data != null;
}

/// Login yanıtındaki data objesi
class LoginData {
  final String status;
  final String message;
  final int userID;
  final String token;

  LoginData({
    required this.status,
    required this.message,
    required this.userID,
    required this.token,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      userID: json['userID'] ?? 0,
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'userID': userID,
      'token': token,
    };
  }
}

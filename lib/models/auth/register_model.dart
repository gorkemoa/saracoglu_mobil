/// Register isteği için model
class RegisterRequest {
  final String userFirstname;
  final String userLastname;
  final String userName;
  final String userEmail;
  final String userPassword;
  final String version;
  final String platform;

  RegisterRequest({
    required this.userFirstname,
    required this.userLastname,
    required this.userName,
    required this.userEmail,
    required this.userPassword,
    required this.version,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'userFirstname': userFirstname,
      'userLastname': userLastname,
      'userName': userName,
      'userEmail': userEmail,
      'userPassword': userPassword,
      'version': version,
      'platform': platform,
    };
  }
}

/// Register yanıtı için model
class RegisterResponse {
  final bool error;
  final bool success;
  final String? successMessage;
  final RegisterData? data;
  final String? statusCode;

  RegisterResponse({
    required this.error,
    required this.success,
    this.successMessage,
    this.data,
    this.statusCode,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
      statusCode: json['200'],
    );
  }

  bool get isSuccess => success && !error && data != null;
}

/// Register yanıtındaki data objesi
class RegisterData {
  final int userID;
  final String userToken;
  final String codeToken;

  RegisterData({
    required this.userID,
    required this.userToken,
    required this.codeToken,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      userID: json['userID'] ?? 0,
      userToken: json['userToken'] ?? '',
      codeToken: json['codeToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userToken': userToken,
      'codeToken': codeToken,
    };
  }
}

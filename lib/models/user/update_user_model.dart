/// UpdateUser isteği için model
class UpdateUserRequest {
  final String userToken;
  final String? userName;
  final String? userFirstname;
  final String? userLastname;
  final String? userEmail;
  final String? userPhone;
  final String? userBirthday;
  final String? userAddress;
  final int? userGender; // 1 - Erkek, 2 - Kadın, 3 - Belirtilmemiş
  final String? profilePhoto; // Base64 formatında

  UpdateUserRequest({
    required this.userToken,
    this.userName,
    this.userFirstname,
    this.userLastname,
    this.userEmail,
    this.userPhone,
    this.userBirthday,
    this.userAddress,
    this.userGender,
    this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      if (userName != null) 'userName': userName,
      if (userFirstname != null) 'userFirstname': userFirstname,
      if (userLastname != null) 'userLastname': userLastname,
      if (userEmail != null) 'userEmail': userEmail,
      if (userPhone != null) 'userPhone': userPhone,
      if (userBirthday != null) 'userBirthday': userBirthday,
      if (userAddress != null) 'userAddress': userAddress,
      if (userGender != null) 'userGender': userGender,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
    };
  }
}

/// UpdateUser yanıtı için model
class UpdateUserResponse {
  final bool error;
  final bool success;
  final String? message;

  UpdateUserResponse({
    required this.error,
    required this.success,
    this.message,
  });

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'] ?? json['data']?['message'],
    );
  }

  bool get isSuccess => success && !error;
}

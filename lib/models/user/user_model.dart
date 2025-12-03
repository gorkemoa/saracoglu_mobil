/// Kullanıcı modeli
/// API'den gelen tüm kullanıcı bilgilerini tutar
class UserModel {
  final int id;
  final String? userName;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? phone;
  final bool? isApproved;
  final String? gender;
  final String? birthday;
  final String token;
  final String? platform;
  final String? userVersion;
  final String? iOSVersion;
  final String? androidVersion;
  final String? profilePhoto;

  UserModel({
    required this.id,
    this.userName,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.phone,
    this.isApproved,
    this.gender,
    this.birthday,
    required this.token,
    this.platform,
    this.userVersion,
    this.iOSVersion,
    this.androidVersion,
    this.profilePhoto,
  });

  /// Login response'dan UserModel oluştur
  factory UserModel.fromLoginData(Map<String, dynamic> json) {
    return UserModel(
      id: json['userID'] ?? 0,
      token: json['token'] ?? '',
      userName: json['user_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  /// GetUser response'dan UserModel oluştur
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userID'] ?? 0,
      userName: json['userName'],
      firstName: json['userFirstname'],
      lastName: json['userLastname'],
      fullName: json['userFullname'],
      email: json['userEmail'],
      phone: json['userPhone'],
      isApproved: json['isApproved'],
      gender: json['userGender'],
      birthday: json['userBirthday'],
      token: json['userToken'] ?? '',
      platform: json['platform'],
      userVersion: json['userVersion'],
      iOSVersion: json['iOSVersion'],
      androidVersion: json['androidVersion'],
      profilePhoto: json['profilePhoto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': id,
      'userName': userName,
      'userFirstname': firstName,
      'userLastname': lastName,
      'userFullname': fullName,
      'userEmail': email,
      'userPhone': phone,
      'isApproved': isApproved,
      'userGender': gender,
      'userBirthday': birthday,
      'userToken': token,
      'platform': platform,
      'userVersion': userVersion,
      'iOSVersion': iOSVersion,
      'androidVersion': androidVersion,
      'profilePhoto': profilePhoto,
    };
  }

  UserModel copyWith({
    int? id,
    String? userName,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phone,
    bool? isApproved,
    String? gender,
    String? birthday,
    String? token,
    String? platform,
    String? userVersion,
    String? iOSVersion,
    String? androidVersion,
    String? profilePhoto,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isApproved: isApproved ?? this.isApproved,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      userVersion: userVersion ?? this.userVersion,
      iOSVersion: iOSVersion ?? this.iOSVersion,
      androidVersion: androidVersion ?? this.androidVersion,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  /// Kullanıcının görüntülenecek adı
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return userName ?? 'Kullanıcı';
  }
}

/// GetUser isteği için model
class GetUserRequest {
  final String userToken;
  final String version;
  final String platform;

  GetUserRequest({
    required this.userToken,
    required this.version,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'version': version,
      'platform': platform,
    };
  }
}

/// GetUser yanıtı için model
class GetUserResponse {
  final bool error;
  final bool success;
  final UserModel? user;

  GetUserResponse({
    required this.error,
    required this.success,
    this.user,
  });

  factory GetUserResponse.fromJson(Map<String, dynamic> json) {
    return GetUserResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      user: json['data']?['user'] != null
          ? UserModel.fromJson(json['data']['user'])
          : null,
    );
  }

  bool get isSuccess => success && !error && user != null;
}

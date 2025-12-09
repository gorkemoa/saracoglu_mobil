/// İletişim Konusu Modeli
/// API'den gelen iletişim konularını temsil eder
class ContactSubject {
  final int subjectID;
  final String subjectName;

  ContactSubject({
    required this.subjectID,
    required this.subjectName,
  });

  factory ContactSubject.fromJson(Map<String, dynamic> json) {
    return ContactSubject(
      subjectID: json['subjectID'] as int,
      subjectName: json['subjectName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectID': subjectID,
      'subjectName': subjectName,
    };
  }
}

/// İletişim Konuları API Yanıtı
class ContactSubjectsResponse {
  final bool error;
  final bool success;
  final List<ContactSubject> subjects;

  ContactSubjectsResponse({
    required this.error,
    required this.success,
    required this.subjects,
  });

  factory ContactSubjectsResponse.fromJson(Map<String, dynamic> json) {
    return ContactSubjectsResponse(
      error: json['error'] as bool? ?? false,
      success: json['success'] as bool? ?? false,
      subjects: (json['data'] as List<dynamic>?)
              ?.map((e) => ContactSubject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isSuccess => success && !error;
}

/// İletişim Mesajı Gönderme Yanıtı
class SendContactMessageResponse {
  final bool error;
  final bool success;
  final String? successMessage;

  SendContactMessageResponse({
    required this.error,
    required this.success,
    this.successMessage,
  });

  factory SendContactMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendContactMessageResponse(
      error: json['error'] as bool? ?? false,
      success: json['success'] as bool? ?? false,
      successMessage: json['data']?['success_message'] as String?,
    );
  }

  bool get isSuccess => success && !error;
}

/// Kullanıcı İletişim Formu Modeli
class UserContactForm {
  final int msgID;
  final int userID;
  final int subjectID;
  final int statusID;
  final String subjectTitle;
  final String statusTitle;
  final String message;
  final String email;
  final String phone;
  final String createdAt;

  UserContactForm({
    required this.msgID,
    required this.userID,
    required this.subjectID,
    required this.statusID,
    required this.subjectTitle,
    required this.statusTitle,
    required this.message,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  factory UserContactForm.fromJson(Map<String, dynamic> json) {
    return UserContactForm(
      msgID: json['msgID'] as int,
      userID: json['userID'] as int,
      subjectID: json['subjectID'] as int,
      statusID: json['statusID'] as int,
      subjectTitle: json['subjectTitle'] as String? ?? '',
      statusTitle: json['statusTitle'] as String? ?? '',
      message: json['message'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msgID': msgID,
      'userID': userID,
      'subjectID': subjectID,
      'statusID': statusID,
      'subjectTitle': subjectTitle,
      'statusTitle': statusTitle,
      'message': message,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
    };
  }
}

/// Kullanıcı İletişim Formları API Yanıtı
class UserContactFormsResponse {
  final bool error;
  final bool success;
  final List<UserContactForm> contacts;
  final int totalItems;

  UserContactFormsResponse({
    required this.error,
    required this.success,
    required this.contacts,
    required this.totalItems,
  });

  factory UserContactFormsResponse.fromJson(Map<String, dynamic> json) {
    return UserContactFormsResponse(
      error: json['error'] as bool? ?? false,
      success: json['success'] as bool? ?? false,
      contacts: (json['data']?['contacts'] as List<dynamic>?)
              ?.map((e) => UserContactForm.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalItems: json['data']?['totalItems'] as int? ?? 0,
    );
  }

  bool get isSuccess => success && !error;
}

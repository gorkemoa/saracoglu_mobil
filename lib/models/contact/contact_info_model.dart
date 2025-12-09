/// İletişim Bilgileri Model
/// API: service/general/general/contact/infos

class ContactInfoResponse {
  final bool error;
  final bool success;
  final ContactInfo? data;

  ContactInfoResponse({
    required this.error,
    required this.success,
    this.data,
  });

  bool get isSuccess => success && !error;

  factory ContactInfoResponse.fromJson(Map<String, dynamic> json) {
    return ContactInfoResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? ContactInfo.fromJson(json['data']) : null,
    );
  }
}

class ContactInfo {
  final String compExcerpt;
  final String compName;
  final String compAddress;
  final String compCustomerPhone;
  final String compPhone;
  final String compFax;
  final String compEmail;
  final String compFacebook;
  final String compInstagram;
  final String compTwitter;
  final String compYoutube;
  final String compLinkedin;

  ContactInfo({
    required this.compExcerpt,
    required this.compName,
    required this.compAddress,
    required this.compCustomerPhone,
    required this.compPhone,
    required this.compFax,
    required this.compEmail,
    required this.compFacebook,
    required this.compInstagram,
    required this.compTwitter,
    required this.compYoutube,
    required this.compLinkedin,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      compExcerpt: json['compExcerpt'] ?? '',
      compName: json['compName'] ?? '',
      compAddress: json['compAddress'] ?? '',
      compCustomerPhone: json['compCustomerPhone'] ?? '',
      compPhone: json['compPhone'] ?? '',
      compFax: json['compFax'] ?? '',
      compEmail: json['compEmail'] ?? '',
      compFacebook: json['compFacebook'] ?? '',
      compInstagram: json['compInstagram'] ?? '',
      compTwitter: json['compTwitter'] ?? '',
      compYoutube: json['compYoutube'] ?? '',
      compLinkedin: json['compLinkedin'] ?? '',
    );
  }
}

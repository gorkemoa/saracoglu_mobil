/// Adres türleri
class AddressType {
  static const String individual = '1'; // Bireysel
  static const String corporate = '2';  // Kurumsal
}

/// Adres ekleme isteği için model
class AddAddressRequest {
  final String userToken;
  final String userFirstName;
  final String userLastName;
  final String addressTitle;
  final String addressType; // 1: Bireysel, 2: Kurumsal
  final String addressPhone;
  final String addressEmail;
  final String addressCityID;
  final String addressDistrictID;
  final String addressNeighbourhoodID;
  final String address;
  final String invoiceAddress;
  final String postalCode;
  final String? identityNumber; // Bireysel ise zorunlu
  final String? realCompanyName; // Kurumsal ise zorunlu
  final String? taxNumber; // Kurumsal ise zorunlu
  final String? taxAdministration; // Kurumsal ise zorunlu

  AddAddressRequest({
    required this.userToken,
    required this.userFirstName,
    required this.userLastName,
    required this.addressTitle,
    required this.addressType,
    required this.addressPhone,
    required this.addressEmail,
    required this.addressCityID,
    required this.addressDistrictID,
    required this.addressNeighbourhoodID,
    required this.address,
    required this.invoiceAddress,
    required this.postalCode,
    this.identityNumber,
    this.realCompanyName,
    this.taxNumber,
    this.taxAdministration,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'addressTitle': addressTitle,
      'addressType': addressType,
      'addressPhone': addressPhone,
      'addressEmail': addressEmail,
      'addressCityID': addressCityID,
      'addressDistrictID': addressDistrictID,
      'addressNeighbourhoodID': addressNeighbourhoodID,
      'address': address,
      'invoiceAddress': invoiceAddress,
      'postalCode': postalCode,
      'identityNumber': identityNumber ?? '',
      'realCompanyName': realCompanyName ?? '',
      'taxNumber': taxNumber ?? '',
      'taxAdministration': taxAdministration ?? '',
    };
  }
}

/// Adres ekleme yanıtı için model
class AddAddressResponse {
  final bool error;
  final bool success;
  final String? message;
  final String? statusCode;

  AddAddressResponse({
    required this.error,
    required this.success,
    this.message,
    this.statusCode,
  });

  factory AddAddressResponse.fromJson(Map<String, dynamic> json) {
    return AddAddressResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'],
      statusCode: json['200'],
    );
  }

  bool get isSuccess => success && !error;

  factory AddAddressResponse.errorResponse(String message) {
    return AddAddressResponse(
      error: true,
      success: false,
      message: message,
    );
  }
}

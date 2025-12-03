/// Adres güncelleme isteği için model
class UpdateAddressRequest {
  final String userToken;
  final int addressID;
  final String userFirstName;
  final String userLastName;
  final String addressTitle;
  final int addressType; // 1: Bireysel, 2: Kurumsal
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

  UpdateAddressRequest({
    required this.userToken,
    required this.addressID,
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
      'addressID': addressID,
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

/// Adres güncelleme yanıtı için model
class UpdateAddressResponse {
  final bool error;
  final bool success;
  final String? message;

  UpdateAddressResponse({
    required this.error,
    required this.success,
    this.message,
  });

  factory UpdateAddressResponse.fromJson(Map<String, dynamic> json) {
    return UpdateAddressResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'],
    );
  }

  bool get isSuccess => success && !error;

  factory UpdateAddressResponse.errorResponse(String message) {
    return UpdateAddressResponse(
      error: true,
      success: false,
      message: message,
    );
  }
}

/// Adres silme isteği için model
class DeleteAddressRequest {
  final String userToken;
  final int addressID;

  DeleteAddressRequest({
    required this.userToken,
    required this.addressID,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'addressID': addressID,
    };
  }
}

/// Adres silme yanıtı için model
class DeleteAddressResponse {
  final bool error;
  final bool success;
  final String? message;

  DeleteAddressResponse({
    required this.error,
    required this.success,
    this.message,
  });

  factory DeleteAddressResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAddressResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'],
    );
  }

  bool get isSuccess => success && !error;

  factory DeleteAddressResponse.errorResponse(String message) {
    return DeleteAddressResponse(
      error: true,
      success: false,
      message: message,
    );
  }
}

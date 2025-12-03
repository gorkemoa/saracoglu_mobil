/// Kullanıcı adresi modeli (API'den gelen)
class UserAddress {
  final int userID;
  final int addressID;
  final String addressFirstName;
  final String addressLastName;
  final String addressName;
  final String addressTitle;
  final int addressTypeID;
  final String addressType;
  final String addressPhone;
  final String addressEmail;
  final String addressCity;
  final int cityID;
  final int districtID;
  final String addressDistrict;
  final String addressNeighbourhood;
  final int neighbourhoodID;
  final String address;
  final String invoiceAddress;
  final int identityNumber;
  final String realCompanyName;
  final String taxNumber;
  final String taxAdministration;
  final String postalCode;

  UserAddress({
    required this.userID,
    required this.addressID,
    required this.addressFirstName,
    required this.addressLastName,
    required this.addressName,
    required this.addressTitle,
    required this.addressTypeID,
    required this.addressType,
    required this.addressPhone,
    required this.addressEmail,
    required this.addressCity,
    required this.cityID,
    required this.districtID,
    required this.addressDistrict,
    required this.addressNeighbourhood,
    required this.neighbourhoodID,
    required this.address,
    required this.invoiceAddress,
    required this.identityNumber,
    required this.realCompanyName,
    required this.taxNumber,
    required this.taxAdministration,
    required this.postalCode,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      userID: json['userID'] ?? 0,
      addressID: json['addressID'] ?? 0,
      addressFirstName: json['addressfirstName'] ?? '',
      addressLastName: json['addresslastName'] ?? '',
      addressName: json['addressName'] ?? '',
      addressTitle: json['addressTitle'] ?? '',
      addressTypeID: json['addressTypeID'] ?? 1,
      addressType: json['addressType'] ?? '',
      addressPhone: json['addressPhone'] ?? '',
      addressEmail: json['addressEmail'] ?? '',
      addressCity: json['addressCity'] ?? '',
      cityID: json['cityID'] ?? 0,
      districtID: json['districtID'] ?? 0,
      addressDistrict: json['addressDistrict'] ?? '',
      addressNeighbourhood: json['addressNeighbourhood'] ?? '',
      neighbourhoodID: json['neighbourhoodID'] ?? 0,
      address: json['address'] ?? '',
      invoiceAddress: json['invoiceAddress'] ?? '',
      identityNumber: json['identityNumber'] ?? 0,
      realCompanyName: json['realCompanyName'] ?? '',
      taxNumber: json['taxNumber'] ?? '',
      taxAdministration: json['taxAdministration'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'addressID': addressID,
      'addressfirstName': addressFirstName,
      'addresslastName': addressLastName,
      'addressName': addressName,
      'addressTitle': addressTitle,
      'addressTypeID': addressTypeID,
      'addressType': addressType,
      'addressPhone': addressPhone,
      'addressEmail': addressEmail,
      'addressCity': addressCity,
      'cityID': cityID,
      'districtID': districtID,
      'addressDistrict': addressDistrict,
      'addressNeighbourhood': addressNeighbourhood,
      'neighbourhoodID': neighbourhoodID,
      'address': address,
      'invoiceAddress': invoiceAddress,
      'identityNumber': identityNumber,
      'realCompanyName': realCompanyName,
      'taxNumber': taxNumber,
      'taxAdministration': taxAdministration,
      'postalCode': postalCode,
    };
  }

  /// Tam adres stringi oluştur
  String get fullAddress => '$address, $addressNeighbourhood, $addressDistrict/$addressCity';
}

/// Kullanıcı adresleri yanıtı
class UserAddressesResponse {
  final bool error;
  final bool success;
  final String? message;
  final int totalItems;
  final String emptyMessage;
  final List<UserAddress> addresses;

  UserAddressesResponse({
    required this.error,
    required this.success,
    this.message,
    required this.totalItems,
    required this.emptyMessage,
    required this.addresses,
  });

  factory UserAddressesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    
    return UserAddressesResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'],
      totalItems: data?['totalItems'] ?? 0,
      emptyMessage: data?['emptyMessage'] ?? '',
      addresses: (data?['addresses'] as List<dynamic>?)
              ?.map((e) => UserAddress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isSuccess => success && !error;

  factory UserAddressesResponse.errorResponse(String message) {
    return UserAddressesResponse(
      error: true,
      success: false,
      message: message,
      totalItems: 0,
      emptyMessage: '',
      addresses: [],
    );
  }
}

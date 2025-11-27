/// Teslimat adresi modeli
class DeliveryAddress {
  final String id;
  final String title;
  final String fullAddress;
  final String city;
  final String district;
  final String phone;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.city,
    required this.district,
    required this.phone,
    this.isDefault = false,
  });

  /// JSON'dan DeliveryAddress oluştur
  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as String,
      title: json['title'] as String,
      fullAddress: json['fullAddress'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      phone: json['phone'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// DeliveryAddress'i JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fullAddress': fullAddress,
      'city': city,
      'district': district,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  /// Adresi kopyala ve belirli alanları değiştir
  DeliveryAddress copyWith({
    String? id,
    String? title,
    String? fullAddress,
    String? city,
    String? district,
    String? phone,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

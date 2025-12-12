class SavedCardModel {
  final String? ctoken;
  final String? last4;
  final String? requireCvv;
  final String? month;
  final String? year;
  final String? cBank;
  final String? cName;
  final String? cBrand;
  final String? cType;
  final String? businessCard;
  final String? initial;
  final String? schema;

  SavedCardModel({
    this.ctoken,
    this.last4,
    this.requireCvv,
    this.month,
    this.year,
    this.cBank,
    this.cName,
    this.cBrand,
    this.cType,
    this.businessCard,
    this.initial,
    this.schema,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      ctoken: json['ctoken'] as String?,
      last4: json['last_4'] as String?,
      requireCvv: json['require_cvv'] as String?,
      month: json['month'] as String?,
      year: json['year'] as String?,
      cBank: json['c_bank'] as String?,
      cName: json['c_name'] as String?,
      cBrand: json['c_brand'] as String?,
      cType: json['c_type'] as String?,
      businessCard: json['businessCard'] as String?,
      initial: json['initial'] as String?,
      schema: json['schema'] as String?,
    );
  }

  // UI helper methods
  String get maskedNumber => '**** **** **** $last4';
  String get expiryDate => '$month/$year';
  String get cardProvider => schema ?? 'UNKNOWN';
}

class SavedCardResponseModel {
  final bool error;
  final bool success;
  final List<SavedCardModel>? data;
  final String? message; // For error 200 field or explicit message if any

  SavedCardResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.message,
  });

  factory SavedCardResponseModel.fromJson(Map<String, dynamic> json) {
    return SavedCardResponseModel(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SavedCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['200'] as String?,
    );
  }
}

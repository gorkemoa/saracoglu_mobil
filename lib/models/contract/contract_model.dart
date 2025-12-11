/// Genel Sözleşme/Metin Modeli (Gizlilik Politikası, Üyelik Sözleşmesi vb.)
/// GET: service/general/general/contracts/...
class ContractResponse {
  final bool error;
  final bool success;
  final ContractData? data;
  final String? message;

  ContractResponse({
    required this.error,
    required this.success,
    this.data,
    this.message,
  });

  factory ContractResponse.fromJson(Map<String, dynamic> json) {
    return ContractResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? ContractData.fromJson(json['data']) : null,
      message: json['message']?.toString(),
    );
  }

  factory ContractResponse.errorResponse(String errorMessage) {
    return ContractResponse(error: true, success: false, message: errorMessage);
  }

  bool get isSuccess => success && !error;
}

/// Sözleşme İçerik Verisi
class ContractData {
  final int postID;
  final String postTitle;
  final String postContent;

  ContractData({
    required this.postID,
    required this.postTitle,
    required this.postContent,
  });

  factory ContractData.fromJson(Map<String, dynamic> json) {
    return ContractData(
      postID: json['postID'] ?? 0,
      postTitle: json['postTitle'] ?? '',
      postContent: json['postContent'] ?? '',
    );
  }
}

import 'banner_model.dart';

class BannerResponse {
  final bool error;
  final bool success;
  final List<BannerModel> banners;
  final String statusMessage;

  BannerResponse({
    required this.error,
    required this.success,
    required this.banners,
    required this.statusMessage,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final bannersList = data['banners'] as List<dynamic>? ?? [];

    return BannerResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      banners: bannersList
          .map((banner) => BannerModel.fromJson(banner as Map<String, dynamic>))
          .toList(),
      statusMessage: json['200'] ?? '',
    );
  }
}

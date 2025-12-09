
class BannerModel {
  final int postID;
  final String postTitle;
  final String postExcerpt;
  final String postBody;
  final String postMainImage;
  final String postThumbImage;

  BannerModel({
    required this.postID,
    required this.postTitle,
    required this.postExcerpt,
    required this.postBody,
    required this.postMainImage,
    required this.postThumbImage,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      postID: json['postID'] ?? 0,
      postTitle: json['postTitle'] ?? '',
      postExcerpt: json['postExcerpt'] ?? '',
      postBody: json['postBody'] ?? '',
      postMainImage: json['postMainImage'] ?? '',
      postThumbImage: json['postThumbImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postID': postID,
      'postTitle': postTitle,
      'postExcerpt': postExcerpt,
      'postBody': postBody,
      'postMainImage': postMainImage,
      'postThumbImage': postThumbImage,
    };
  }
}

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

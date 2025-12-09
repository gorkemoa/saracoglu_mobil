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

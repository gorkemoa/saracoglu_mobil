/// Kategori modeli
/// API'den gelen kategori listesi için model
class CategoryModel {
  final int catID;
  final String catName;
  final String catMainImage;
  final String catThumbImage;
  final String catThumbImage1;
  final String catThumbImage2;

  CategoryModel({
    required this.catID,
    required this.catName,
    required this.catMainImage,
    required this.catThumbImage,
    required this.catThumbImage1,
    required this.catThumbImage2,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      catID: json['catID'] ?? 0,
      catName: json['catName'] ?? '',
      catMainImage: json['catMainImage'] ?? '',
      catThumbImage: json['catThumbImage'] ?? '',
      catThumbImage1: json['catThumbImage1'] ?? '',
      catThumbImage2: json['catThumbImage2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catID': catID,
      'catName': catName,
      'catMainImage': catMainImage,
      'catThumbImage': catThumbImage,
      'catThumbImage1': catThumbImage1,
      'catThumbImage2': catThumbImage2,
    };
  }
}

/// Kategori listesi response modeli
class CategoryListResponse {
  final bool error;
  final bool success;
  final List<CategoryModel> categories;

  CategoryListResponse({
    required this.error,
    required this.success,
    required this.categories,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final categoriesList = data?['categories'] as List<dynamic>? ?? [];

    return CategoryListResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      categories: categoriesList
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isSuccess => success && !error;
}

/// FAQ Model
/// API: service/general/general/faq/catList & service/general/general/faq/list

// FAQ Kategorileri Response
class FAQCategoriesResponse {
  final bool error;
  final bool success;
  final List<FAQCategory> categories;

  FAQCategoriesResponse({
    required this.error,
    required this.success,
    required this.categories,
  });

  bool get isSuccess => success && !error;

  factory FAQCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return FAQCategoriesResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      categories: json['data'] != null
          ? (json['data'] as List).map((e) => FAQCategory.fromJson(e)).toList()
          : [],
    );
  }
}

class FAQCategory {
  final int catID;
  final String catName;

  FAQCategory({
    required this.catID,
    required this.catName,
  });

  factory FAQCategory.fromJson(Map<String, dynamic> json) {
    return FAQCategory(
      catID: json['catID'] ?? 0,
      catName: json['catName'] ?? '',
    );
  }
}

// FAQ Listesi Response
class FAQListResponse {
  final bool error;
  final bool success;
  final List<FAQItem> faqs;

  FAQListResponse({
    required this.error,
    required this.success,
    required this.faqs,
  });

  bool get isSuccess => success && !error;

  factory FAQListResponse.fromJson(Map<String, dynamic> json) {
    return FAQListResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      faqs: json['data'] != null && json['data']['faqs'] != null
          ? (json['data']['faqs'] as List).map((e) => FAQItem.fromJson(e)).toList()
          : [],
    );
  }
}

class FAQItem {
  final int faqID;
  final int catID;
  final String catName;
  final String faqTitle;
  final String faqDesc;

  FAQItem({
    required this.faqID,
    required this.catID,
    required this.catName,
    required this.faqTitle,
    required this.faqDesc,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      faqID: json['faqID'] ?? 0,
      catID: json['catID'] ?? 0,
      catName: json['catName'] ?? '',
      faqTitle: json['faqTitle'] ?? '',
      faqDesc: json['faqDesc'] ?? '',
    );
  }
}

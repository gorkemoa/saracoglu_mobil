/// Kullanıcı yorumu modeli
class UserComment {
  final int userID;
  final int commentID;
  final int productID;
  final String userName;
  final bool showName;
  final String commentDesc;
  final int commentRating;
  final int commentLike;
  final int commentDislike;
  final String productTitle;
  final String productImage;
  final String commentDate;
  final String commentApproval;

  UserComment({
    required this.userID,
    required this.commentID,
    required this.productID,
    required this.userName,
    required this.showName,
    required this.commentDesc,
    required this.commentRating,
    required this.commentLike,
    required this.commentDislike,
    required this.productTitle,
    required this.productImage,
    required this.commentDate,
    required this.commentApproval,
  });

  factory UserComment.fromJson(Map<String, dynamic> json) {
    return UserComment(
      userID: json['userID'] ?? 0,
      commentID: json['commentID'] ?? 0,
      productID: json['productID'] ?? 0,
      userName: json['userName'] ?? '',
      showName: json['showName'] ?? false,
      commentDesc: json['commentDesc'] ?? '',
      commentRating: json['commentRating'] ?? 0,
      commentLike: json['commentLike'] ?? 0,
      commentDislike: json['commentDislike'] ?? 0,
      productTitle: json['productTitle'] ?? '',
      productImage: json['productImage'] ?? '',
      commentDate: json['commentDate'] ?? '',
      commentApproval: json['commentApproval'] ?? '',
    );
  }

  /// Onay durumu

  /// Beklemede mi
}

/// Kullanıcı yorumları response modeli
class UserCommentsResponse {
  final int totalItems;
  final String emptyMessage;
  final List<UserComment> comments;
  final bool error;
  final bool success;

  UserCommentsResponse({
    required this.totalItems,
    required this.emptyMessage,
    required this.comments,
    required this.error,
    required this.success,
  });

  factory UserCommentsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    List<UserComment> commentsList = [];
    if (data != null && data['comments'] != null) {
      commentsList = (data['comments'] as List)
          .map((item) => UserComment.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return UserCommentsResponse(
      totalItems: data?['totalItems'] ?? 0,
      emptyMessage: data?['emptyMessage'] ?? '',
      comments: commentsList,
      error: json['error'] ?? true,
      success: json['success'] ?? false,
    );
  }

  bool get isEmpty => comments.isEmpty;
  bool get isNotEmpty => comments.isNotEmpty;
}

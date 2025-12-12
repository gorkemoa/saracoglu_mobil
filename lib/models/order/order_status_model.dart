class OrderStatusModel {
  final int statusID;
  final String statusName;
  final String statusColor;

  OrderStatusModel({
    required this.statusID,
    required this.statusName,
    required this.statusColor,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      statusID: json['statusID'] ?? 0,
      statusName: json['statusName'] ?? '',
      statusColor: json['statusColor'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusID': statusID,
      'statusName': statusName,
      'statusColor': statusColor,
    };
  }
}

class OrderStatusListResponse {
  final bool isSuccess;
  final String? message;
  final List<OrderStatusModel> statusList;

  OrderStatusListResponse({
    required this.isSuccess,
    this.message,
    required this.statusList,
  });

  factory OrderStatusListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> list = [];
    final data = json['data'];

    if (data is List) {
      list = data;
    } else if (data is Map && data['statusies'] is List) {
      list = data['statusies'];
    } else if (data is Map && data['statusTitles'] is List) {
      // Fallback for consistency with other endpoints if needed
      list = data['statusTitles'];
    }

    List<OrderStatusModel> statusList = list
        .map((i) => OrderStatusModel.fromJson(i))
        .toList();

    return OrderStatusListResponse(
      isSuccess: json['success'] ?? false,
      message: json['message'] as String?,
      statusList: statusList,
    );
  }

  factory OrderStatusListResponse.errorResponse(String message) {
    return OrderStatusListResponse(
      isSuccess: false,
      message: message,
      statusList: [],
    );
  }
}

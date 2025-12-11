/// Bildirim modeli
class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String type;
  final int typeId;
  final String url;
  final bool isRead;
  final String createDate;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.typeId,
    required this.url,
    required this.isRead,
    required this.createDate,
  });

  /// JSON'dan model oluştur
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      typeId: json['type_id'] ?? 0,
      url: json['url'] ?? '',
      isRead: json['isRead'] ?? false,
      createDate: json['create_date'] ?? '',
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'type_id': typeId,
      'url': url,
      'isRead': isRead,
      'create_date': createDate,
    };
  }

  /// copyWith metodu
  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    String? type,
    int? typeId,
    String? url,
    bool? isRead,
    String? createDate,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      typeId: typeId ?? this.typeId,
      url: url ?? this.url,
      isRead: isRead ?? this.isRead,
      createDate: createDate ?? this.createDate,
    );
  }
}

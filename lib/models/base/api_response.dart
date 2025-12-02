/// Genel API yanıt modeli
/// Tüm API yanıtları bu yapıda gelir
class ApiResponse<T> {
  final bool error;
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.error,
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  bool get isSuccess => success && !error;
  bool get isError => error || !success;
}

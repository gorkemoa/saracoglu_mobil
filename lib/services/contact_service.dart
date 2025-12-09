import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../models/contact/contact_subject_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// İletişim Servisi
/// Kullanıcı iletişim formlarını yönetir
class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  /// User token'ı AuthService'den al
  String get _userToken => _authService.token ?? '';

  /// İletişim konularını getir
  Future<ContactSubjectsResponse?> getContactSubjects() async {
    try {
      final endpoint = ApiConstants.getContactSubjects;

      _logger.d('📤 Request URL: $endpoint');

      final result = await _networkService.get(endpoint);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = ContactSubjectsResponse.fromJson(result.data!);
        if (response.isSuccess) {
          _logger.i('✅ İletişim konuları getirildi: ${response.subjects.length} konu');
          return response;
        }
      }

      _logger.w('⚠️ İletişim konuları getirilemedi: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ İletişim konuları getirme hatası', error: e);
      return null;
    }
  }

  /// İletişim mesajı gönder
  Future<SendContactMessageResponse?> sendContactMessage({
    required int subjectId,
    required String message,
  }) async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ Mesaj göndermek için giriş yapılmalı');
        return null;
      }

      final endpoint = ApiConstants.sendContactMessage;
      final body = {
        'userToken': _userToken,
        'subject': subjectId,
        'message': message,
      };

      _logger.d('📤 Request URL: $endpoint');
      _logger.d('📤 Request Body: $body');

      final result = await _networkService.post(endpoint, body: body);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = SendContactMessageResponse.fromJson(result.data!);
        if (response.isSuccess) {
          _logger.i('✅ Mesaj gönderildi: ${response.successMessage}');
          return response;
        }
      }

      _logger.w('⚠️ Mesaj gönderilemedi: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ Mesaj gönderme hatası', error: e);
      return null;
    }
  }

  /// Kullanıcının iletişim formlarını getir
  Future<UserContactFormsResponse?> getUserContactForms() async {
    try {
      if (_userToken.isEmpty) {
        _logger.w('⚠️ İletişim formlarını görmek için giriş yapılmalı');
        return null;
      }

      final endpoint = '${ApiConstants.getUserContactForms}?userToken=$_userToken';

      _logger.d('📤 Request URL: $endpoint');

      final result = await _networkService.get(endpoint);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        final response = UserContactFormsResponse.fromJson(result.data!);
        if (response.isSuccess) {
          _logger.i('✅ İletişim formları getirildi: ${response.totalItems} form');
          return response;
        }
      }

      _logger.w('⚠️ İletişim formları getirilemedi: ${result.errorMessage}');
      return null;
    } catch (e) {
      _logger.e('❌ İletişim formları getirme hatası', error: e);
      return null;
    }
  }
}

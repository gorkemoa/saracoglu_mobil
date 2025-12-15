import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../models/auth/login_model.dart';
import '../models/auth/register_model.dart';
import '../models/auth/code_check_model.dart';
import '../models/auth/send_verification_code_model.dart';
import '../models/auth/forgot_password_model.dart';
import '../models/user/user_model.dart';
import '../models/user/update_user_model.dart';
import '../models/user/update_password_model.dart';
import '../models/user/delete_user_model.dart';
import 'network_service.dart';
import '../models/auth/social_login_request.dart';
import '../views/auth/login_page.dart';

/// SharedPreferences keys
class _StorageKeys {
  static const String userId = 'user_id';
  static const String userToken = 'user_token';
}

/// Kimlik doğrulama servisi - Singleton pattern
/// Kullanıcı oturum durumunu yönetir
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _setupUnauthorizedCallback();
  }

  final NetworkService _networkService = NetworkService();

  // Kullanıcı bilgileri
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Register için geçici token'lar
  String? _pendingCodeToken;
  int? _pendingUserId;

  // 403 hatası için global context (Navigator için)
  static GlobalKey<NavigatorState>? navigatorKey;

  // Getters
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  UserModel? get currentUser => _currentUser;
  String? get userId => _currentUser?.id.toString();
  String? get userName => _currentUser?.userName;
  String? get userEmail => _currentUser?.email;
  String? get userPhone => _currentUser?.phone;
  String? get token => _currentUser?.token;

  /// 403 callback'i ayarla
  void _setupUnauthorizedCallback() {
    _networkService.onUnauthorized = () {
      _handleUnauthorized();
    };
  }

  /// 403 hatası geldiğinde çağrılır
  void _handleUnauthorized() async {
    // Kullanıcı bilgilerini temizle
    await _clearStoredCredentials();
    _currentUser = null;
    _networkService.clearAuthToken();
    notifyListeners();

    // Login sayfasına yönlendir
    if (navigatorKey?.currentContext != null) {
      final context = navigatorKey!.currentContext!;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginPage(
            redirectMessage: 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
            fromSessionExpired: true,
          ),
        ),
        (route) => false,
      );
    }
  }

  /// Uygulama başlangıcında kaydedilmiş oturumu kontrol et
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt(_StorageKeys.userId);
    final storedToken = prefs.getString(_StorageKeys.userToken);

    if (storedUserId != null && storedToken != null) {
      // Token'ı network service'e set et
      _networkService.setAuthToken(storedToken);

      // Geçici kullanıcı modeli oluştur
      _currentUser = UserModel(id: storedUserId, token: storedToken);

      // Kullanıcı bilgilerini API'den getir (arka planda)
      getUser(storedUserId);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Kullanıcı bilgilerini SharedPreferences'a kaydet
  Future<void> _saveCredentials(int userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_StorageKeys.userId, userId);
    await prefs.setString(_StorageKeys.userToken, token);
  }

  /// Kaydedilmiş kullanıcı bilgilerini temizle
  Future<void> _clearStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_StorageKeys.userId);
    await prefs.remove(_StorageKeys.userToken);
  }

  /// Kullanıcı girişi yap
  Future<LoginResponse> login(LoginRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _networkService.post(
        ApiConstants.login,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = LoginResponse.fromJson(result.data!);

        if (response.isSuccess && response.data != null) {
          // Token'ı network service'e kaydet
          _networkService.setAuthToken(response.data!.token);

          // Kullanıcı modelini oluştur
          _currentUser = UserModel(
            id: response.data!.userID,
            token: response.data!.token,
          );

          // Credentials'ı kaydet (kalıcı oturum)
          await _saveCredentials(response.data!.userID, response.data!.token);

          notifyListeners();
        }

        return response;
      } else {
        // Hata durumu - API'den gelen mesajı döndür
        return LoginResponse(
          error: true,
          success: false,
          data: LoginData(
            status: 'error',
            message: result.errorMessage ?? 'Giriş başarısız',
            userID: 0,
            token: '',
          ),
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return LoginResponse(
        error: true,
        success: false,
        data: LoginData(
          status: 'error',
          message: 'Bir hata oluştu: ${e.toString()}',
          userID: 0,
          token: '',
        ),
      );
    }
  }

  /// Sosyal Medya ile giriş yap
  Future<LoginResponse> loginSocial(SocialLoginRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _networkService.post(
        ApiConstants.loginSocial,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = LoginResponse.fromJson(result.data!);

        if (response.isSuccess && response.data != null) {
          // Token'ı network service'e kaydet
          _networkService.setAuthToken(response.data!.token);

          // Kullanıcı modelini oluştur
          _currentUser = UserModel(
            id: response.data!.userID,
            token: response.data!.token,
          );

          // Credentials'ı kaydet (kalıcı oturum)
          await _saveCredentials(response.data!.userID, response.data!.token);

          notifyListeners();
        }

        return response;
      } else {
        // Hata durumu - API'den gelen mesajı döndür
        return LoginResponse(
          error: true,
          success: false,
          data: LoginData(
            status: 'error',
            message: result.errorMessage ?? 'Giriş başarısız',
            userID: 0,
            token: '',
          ),
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return LoginResponse(
        error: true,
        success: false,
        data: LoginData(
          status: 'error',
          message: 'Bir hata oluştu: ${e.toString()}',
          userID: 0,
          token: '',
        ),
      );
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    await _clearStoredCredentials();
    _currentUser = null;
    _pendingCodeToken = null;
    _pendingUserId = null;
    _networkService.clearAuthToken();
    notifyListeners();
  }

  /// Kayıt ol
  Future<RegisterResponse> register(RegisterRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _networkService.post(
        ApiConstants.register,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = RegisterResponse.fromJson(result.data!);

        if (response.isSuccess && response.data != null) {
          // codeToken ve userToken'ı kaydet (doğrulama için)
          _pendingCodeToken = response.data!.codeToken;
          _pendingUserId = response.data!.userID;
        }

        notifyListeners();
        return response;
      } else {
        notifyListeners();
        return RegisterResponse(
          error: true,
          success: false,
          successMessage: result.errorMessage ?? 'Kayıt başarısız',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return RegisterResponse(
        error: true,
        success: false,
        successMessage: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Doğrulama kodu kontrol et
  Future<CodeCheckResponse> checkCode(String code) async {
    if (_pendingCodeToken == null) {
      return CodeCheckResponse(
        error: true,
        success: false,
        successMessage: 'Doğrulama token\'ı bulunamadı',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      final request = CodeCheckRequest(
        code: code,
        codeToken: _pendingCodeToken!,
      );

      final result = await _networkService.post(
        ApiConstants.checkCode,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = CodeCheckResponse.fromJson(result.data!);

        if (response.isSuccess && response.data != null) {
          // passToken == userToken, kullanıcıyı giriş yaptır
          final userToken = response.data!.passToken;

          // Token'ı network service'e kaydet
          _networkService.setAuthToken(userToken);

          // Kullanıcı modelini oluştur
          _currentUser = UserModel(id: _pendingUserId!, token: userToken);

          // Credentials'ı kaydet (kalıcı oturum)
          await _saveCredentials(_pendingUserId!, userToken);

          // Geçici token'ları temizle
          _pendingCodeToken = null;
          _pendingUserId = null;

          notifyListeners();
        }

        return response;
      } else {
        notifyListeners();
        return CodeCheckResponse(
          error: true,
          success: false,
          successMessage: result.errorMessage ?? 'Doğrulama başarısız',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return CodeCheckResponse(
        error: true,
        success: false,
        successMessage: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Bekleyen codeToken var mı?
  bool get hasPendingVerification => _pendingCodeToken != null;

  /// Doğrulama kodu gönder (giriş yapmış kullanıcılar için)
  /// sendType: 1 = SMS, 2 = E-posta
  Future<SendVerificationCodeResponse> sendVerificationCode(
    int sendType,
  ) async {
    if (_currentUser == null) {
      return SendVerificationCodeResponse(
        error: true,
        success: false,
        message: 'Kullanıcı bilgisi bulunamadı',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      final request = SendVerificationCodeRequest(
        userToken: _currentUser!.token,
        sendType: sendType,
      );

      final result = await _networkService.post(
        ApiConstants.sendVerificationCode,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = SendVerificationCodeResponse.fromJson(result.data!);

        if (response.isSuccess && response.data != null) {
          // codeToken'ı kaydet (doğrulama için)
          _pendingCodeToken = response.data!.codeToken;
          _pendingUserId = _currentUser!.id;
        }

        notifyListeners();
        return response;
      } else {
        notifyListeners();
        return SendVerificationCodeResponse(
          error: true,
          success: false,
          message: result.errorMessage ?? 'Kod gönderme başarısız',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return SendVerificationCodeResponse(
        error: true,
        success: false,
        message: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// E-posta doğrulama kodu kontrol et (giriş yapmış kullanıcılar için)
  Future<CodeCheckResponse> verifyEmailCode(String code) async {
    if (_pendingCodeToken == null) {
      return CodeCheckResponse(
        error: true,
        success: false,
        successMessage: 'Doğrulama token\'ı bulunamadı',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      final request = CodeCheckRequest(
        code: code,
        codeToken: _pendingCodeToken!,
      );

      final result = await _networkService.post(
        ApiConstants.checkCode,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = CodeCheckResponse.fromJson(result.data!);

        if (response.isSuccess) {
          // Doğrulama başarılı, kullanıcı bilgilerini güncelle
          if (_currentUser != null) {
            _currentUser = _currentUser!.copyWith(isApproved: true);
          }

          // Geçici token'ları temizle
          _pendingCodeToken = null;
          _pendingUserId = null;

          notifyListeners();
        }

        return response;
      } else {
        notifyListeners();
        return CodeCheckResponse(
          error: true,
          success: false,
          successMessage: result.errorMessage ?? 'Doğrulama başarısız',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return CodeCheckResponse(
        error: true,
        success: false,
        successMessage: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Şifremi unuttum - doğrulama kodu gönder
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ForgotPasswordRequest(userEmail: email);

      final result = await _networkService.post(
        ApiConstants.forgotPassword,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = ForgotPasswordResponse.fromJson(result.data!);

        if (response.isSuccess && response.data != null) {
          // codeToken'ı kaydet (doğrulama için)
          _pendingCodeToken = response.data!.codeToken;
          _pendingUserId = response.data!.userId;
        }

        notifyListeners();
        return response;
      } else {
        notifyListeners();
        return ForgotPasswordResponse(
          error: true,
          success: false,
          message: result.errorMessage ?? 'İşlem başarısız',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return ForgotPasswordResponse(
        error: true,
        success: false,
        message: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Şifre sıfırlama doğrulama kodu kontrolü
  Future<CodeCheckResponse> verifyForgotPasswordCode(String code) async {
    if (_pendingCodeToken == null) {
      return CodeCheckResponse(
        error: true,
        success: false,
        successMessage: 'Doğrulama token\'ı bulunamadı',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      final request = CodeCheckRequest(
        code: code,
        codeToken: _pendingCodeToken!,
      );

      final result = await _networkService.post(
        ApiConstants.checkCode,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = CodeCheckResponse.fromJson(result.data!);

        if (response.isSuccess) {
          // Geçici token'ları temizle
          _pendingCodeToken = null;
          _pendingUserId = null;
        }

        notifyListeners();
        return response;
      } else {
        notifyListeners();
        return CodeCheckResponse(
          error: true,
          success: false,
          successMessage: result.errorMessage ?? 'Doğrulama başarısız',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return CodeCheckResponse(
        error: true,
        success: false,
        successMessage: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Kullanıcı bilgilerini getir (getUser - PUT)
  /// userId: Login'den gelen kullanıcı ID'si
  Future<GetUserResponse> getUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;

      final request = GetUserRequest(
        userToken: _currentUser?.token ?? '',
        version: version,
        platform: AppConstants.platform,
      );

      // Endpoint: service/user/id/{userId}
      final result = await _networkService.put(
        '${ApiConstants.getUser}/$userId',
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = GetUserResponse.fromJson(result.data!);

        if (response.isSuccess && response.user != null) {
          // Kullanıcı bilgilerini güncelle
          _currentUser = response.user;
          _networkService.setAuthToken(response.user!.token);
          notifyListeners();
        }

        return response;
      } else {
        notifyListeners();
        return GetUserResponse(error: true, success: false, user: null);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return GetUserResponse(error: true, success: false, user: null);
    }
  }

  /// Kullanıcı bilgilerini güncelle (updateUser - PUT)
  /// userId: Kullanıcı ID'si
  /// request: Güncellenecek bilgiler
  Future<UpdateUserResponse> updateUserInfo(
    int userId,
    UpdateUserRequest request,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Endpoint: service/user/update/{userId}/account
      final result = await _networkService.put(
        '${ApiConstants.updateUser}/$userId/account',
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = UpdateUserResponse.fromJson(result.data!);

        if (response.isSuccess) {
          // Başarılı güncelleme sonrası güncel bilgileri getir
          await getUser(userId);
        }

        notifyListeners();
        return response;
      } else {
        notifyListeners();
        return UpdateUserResponse(
          error: true,
          success: false,
          message: result.errorMessage,
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return UpdateUserResponse(
        error: true,
        success: false,
        message: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Kullanıcı bilgilerini local olarak güncelle
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Şifre güncelle
  Future<UpdatePasswordResponse> updatePassword(
    UpdatePasswordRequest request,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _networkService.put(
        ApiConstants.updatePassword,
        body: request.toJson(),
      );

      _isLoading = false;
      notifyListeners();

      if (result.isSuccess && result.data != null) {
        return UpdatePasswordResponse.fromJson(result.data!);
      } else {
        return UpdatePasswordResponse.error(
          result.errorMessage ?? 'Şifre güncellenirken bir hata oluştu',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return UpdatePasswordResponse.error(e.toString());
    }
  }

  /// Hesabı sil
  Future<DeleteUserResponse> deleteUser() async {
    try {
      if (_currentUser == null) {
        return DeleteUserResponse.error('Kullanıcı bilgisi bulunamadı');
      }

      _isLoading = true;
      notifyListeners();

      final request = DeleteUserRequest(userToken: _currentUser!.token);

      final result = await _networkService.delete(
        ApiConstants.deleteUser,
        body: request.toJson(),
      );

      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        final response = DeleteUserResponse.fromJson(result.data!);

        if (response.isSuccess) {
          // Hesap silindi, çıkış yap
          await logout();
        }

        notifyListeners();
        return response;
      } else {
        notifyListeners();
        return DeleteUserResponse.error(
          result.errorMessage ?? 'Hesap silinirken bir hata oluştu',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return DeleteUserResponse.error(e.toString());
    }
  }
}

/// Kullanıcı giriş kontrolü yapan yardımcı sınıf
class AuthGuard {
  /// Kullanıcı giriş yapmış mı kontrol et
  /// Giriş yapmamışsa LoginPage'e yönlendir
  static Future<bool> checkAuth(BuildContext context, {String? message}) async {
    final authService = AuthService();

    if (!authService.isLoggedIn) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            redirectMessage:
                message ?? 'Bu işlem için giriş yapmanız gerekiyor',
          ),
        ),
      );

      return result == true;
    }
    return true;
  }

  /// Senkron versiyon - Sadece kontrol yapar, yönlendirme yapmaz
  static bool isLoggedIn() {
    return AuthService().isLoggedIn;
  }

  /// Giriş yapmamışsa SnackBar göster ve false döndür
  static bool checkAuthWithSnackBar(BuildContext context, {String? message}) {
    final authService = AuthService();

    if (!authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message ?? 'Bu işlem için giriş yapmanız gerekiyor',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Giriş Yap',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(redirectMessage: message),
                ),
              );
            },
          ),
        ),
      );
      return false;
    }
    return true;
  }
}

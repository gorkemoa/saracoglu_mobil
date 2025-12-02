import 'package:flutter/material.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../models/auth/login_model.dart';
import '../models/user/user_model.dart';
import '../models/user/update_user_model.dart';
import '../models/user/update_password_model.dart';
import '../models/user/delete_user_model.dart';
import 'network_service.dart';
import '../views/auth/login_page.dart';

/// Kimlik doğrulama servisi - Singleton pattern
/// Kullanıcı oturum durumunu yönetir
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final NetworkService _networkService = NetworkService();

  // Kullanıcı bilgileri
  UserModel? _currentUser;
  bool _isLoading = false;

  // Getters
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String? get userId => _currentUser?.id.toString();
  String? get userName => _currentUser?.userName;
  String? get userEmail => _currentUser?.email;
  String? get userPhone => _currentUser?.phone;
  String? get token => _currentUser?.token;

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
    _currentUser = null;
    _networkService.clearAuthToken();
    notifyListeners();
  }



  /// Kullanıcı bilgilerini getir (getUser - PUT)
  /// userId: Login'den gelen kullanıcı ID'si
  Future<GetUserResponse> getUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = GetUserRequest(
        userToken: _currentUser?.token ?? '',
        version: AppConstants.appVersion,
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
        return GetUserResponse(
          error: true,
          success: false,
          user: null,
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return GetUserResponse(
        error: true,
        success: false,
        user: null,
      );
    }
  }

  /// Kullanıcı bilgilerini güncelle (updateUser - PUT)
  /// userId: Kullanıcı ID'si
  /// request: Güncellenecek bilgiler
  Future<UpdateUserResponse> updateUserInfo(int userId, UpdateUserRequest request) async {
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
  Future<UpdatePasswordResponse> updatePassword(UpdatePasswordRequest request) async {
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
        return UpdatePasswordResponse.error(result.errorMessage ?? 'Şifre güncellenirken bir hata oluştu');
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
        return DeleteUserResponse.error(result.errorMessage ?? 'Hesap silinirken bir hata oluştu');
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
  static Future<bool> checkAuth(
    BuildContext context, {
    String? message,
  }) async {
    final authService = AuthService();

    if (!authService.isLoggedIn) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            redirectMessage: message ?? 'Bu işlem için giriş yapmanız gerekiyor',
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
                child: Text(message ?? 'Bu işlem için giriş yapmanız gerekiyor'),
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

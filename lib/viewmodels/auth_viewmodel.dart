import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/auth/login_model.dart';
import '../models/auth/register_model.dart';
import '../models/user/user_model.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service.dart';
import '../models/auth/social_login_request.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

/// Auth ViewModel
/// Login, Register ve Auth işlemlerini yöneten ViewModel
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocialAuthService _socialAuthService = SocialAuthService();

  // State
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  bool get isLoggedIn => _authService.isLoggedIn;
  UserModel? get currentUser => _authService.currentUser;

  /// Loading state'i set et
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Error message'ı set et
  void _setError(String? message) {
    _errorMessage = message;
    _isSuccess = false;
    notifyListeners();
  }

  /// Success state'i set et
  void _setSuccess() {
    _isSuccess = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// State'i temizle
  void clearState() {
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }

  /// Login işlemi
  Future<bool> login({
    required String userName,
    required String password,
  }) async {
    clearState();
    _setLoading(true);

    try {
      final request = LoginRequest(userName: userName, password: password);

      final response = await _authService.login(request);

      _setLoading(false);

      if (response.isSuccess) {
        _setSuccess();
        return true;
      } else {
        // API'den gelen hata mesajını göster
        _setError(response.data?.message ?? 'Giriş başarısız');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Bir hata oluştu: ${e.toString()}');
      return false;
    }
  }

  /// Logout işlemi
  Future<void> logout() async {
    await _authService.logout();
    clearState();
  }

  /// Register işlemi
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String userName,
    required String email,
    required String password,
  }) async {
    clearState();
    _setLoading(true);

    try {
      final request = RegisterRequest(
        userFirstname: firstName,
        userLastname: lastName,
        userName: userName,
        userEmail: email,
        userPassword: password,
        version: await _getAppVersion(),
        platform: AppConstants.platform,
      );

      final response = await _authService.register(request);

      _setLoading(false);

      if (response.isSuccess) {
        _setSuccess();
        return true;
      } else {
        // API'den gelen hata mesajını göster
        _setError(response.successMessage ?? 'Kayıt başarısız');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Bir hata oluştu: ${e.toString()}');
      return false;
    }
  }

  /// Doğrulama kodu kontrol et
  Future<bool> verifyCode(String code) async {
    clearState();
    _setLoading(true);

    try {
      final response = await _authService.checkCode(code);

      _setLoading(false);

      if (response.isSuccess) {
        _setSuccess();
        return true;
      } else {
        // API'den gelen hata mesajını göster
        _setError(response.successMessage ?? 'Doğrulama başarısız');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Bir hata oluştu: ${e.toString()}');
      return false;
    }
  }

  /// Bekleyen doğrulama var mı?
  bool get hasPendingVerification => _authService.hasPendingVerification;

  /// Google ile giriş
  Future<bool> loginWithGoogle() async {
    clearState();
    _setLoading(true);

    try {
      final googleUser = await _socialAuthService.signInWithGoogle();

      if (googleUser == null) {
        // Kullanıcı iptal etti veya hata
        _setLoading(false);
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.idToken;

      if (accessToken == null) {
        _setLoading(false);
        _setError('Google erişim anahtarı alınamadı');
        return false;
      }

      // Cihaz bilgilerini al
      final deviceData = await _getDeviceInfo();

      final request = SocialLoginRequest(
        platform: 'google',
        deviceID: deviceData['deviceId'] ?? 'unknown',
        devicePlatform: Platform.isIOS ? 'ios' : 'android',
        version: await _getAppVersion(),
        accessToken: accessToken,
        fcmToken: 'dummy_fcm_token', // TODO: FCM token entegrasyonu yapılmalı
        idToken: googleAuth.idToken,
      );

      final response = await _authService.loginSocial(request);

      _setLoading(false);

      if (response.isSuccess) {
        _setSuccess();
        return true;
      } else {
        _setError(response.data?.message ?? 'Google ile giriş başarısız');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Bir hata oluştu: ${e.toString()}');
      return false;
    }
  }

  /// Apple ile giriş
  Future<bool> loginWithApple() async {
    clearState();
    _setLoading(true);

    try {
      final credential = await _socialAuthService.signInWithApple();

      if (credential == null) {
        _setLoading(false);
        return false;
      }

      final idToken = credential.identityToken;
      final authCode = credential.authorizationCode;

      if (idToken == null) {
        _setLoading(false);
        _setError('Apple kimlik anahtarı alınamadı');
        return false;
      }

      // Cihaz bilgilerini al
      final deviceData = await _getDeviceInfo();

      final request = SocialLoginRequest(
        platform: 'apple',
        deviceID: deviceData['deviceId'] ?? 'unknown',
        devicePlatform: Platform.isIOS ? 'ios' : 'android',
        version: await _getAppVersion(),
        accessToken:
            authCode, // Apple için auth code'u access token olarak gönderiyoruz
        idToken: idToken,
        fcmToken: 'dummy_fcm_token',
      );

      final response = await _authService.loginSocial(request);

      _setLoading(false);

      if (response.isSuccess) {
        _setSuccess();
        return true;
      } else {
        _setError(response.data?.message ?? 'Apple ile giriş başarısız');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Bir hata oluştu: ${e.toString()}');
      return false;
    }
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceData = <String, String>{};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData['deviceId'] = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData['deviceId'] = iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      deviceData['deviceId'] = 'unknown';
    }

    return deviceData;
  }

  /// Uygulama versiyonunu getir
  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}

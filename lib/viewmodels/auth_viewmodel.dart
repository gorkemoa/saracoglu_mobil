import 'package:flutter/foundation.dart';

import '../models/auth/login_model.dart';
import '../models/user/user_model.dart';
import '../services/auth_service.dart';

/// Auth ViewModel
/// Login, Register ve Auth işlemlerini yöneten ViewModel
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

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
      final request = LoginRequest(
        userName: userName,
        password: password,
      );

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
}

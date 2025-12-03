import '../core/constants/api_constants.dart';
import '../models/address/add_address_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// Adres yönetimi servisi - Singleton pattern
class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();

  /// Yeni adres ekle
  Future<AddAddressResponse> addAddress(AddAddressRequest request) async {
    try {
      final result = await _networkService.post(
        ApiConstants.addAddress,
        body: request.toJson(),
      );

      if (result.isSuccess && result.data != null) {
        return AddAddressResponse.fromJson(result.data!);
      } else {
        return AddAddressResponse.errorResponse(
          result.errorMessage ?? 'Adres eklenirken bir hata oluştu',
        );
      }
    } catch (e) {
      return AddAddressResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
    }
  }

  /// Kullanıcı token'ını al
  String? get userToken => _authService.currentUser?.token;

  /// Kullanıcı adını al
  String? get userFirstName => _authService.currentUser?.firstName;

  /// Kullanıcı soyadını al
  String? get userLastName => _authService.currentUser?.lastName;

  /// Kullanıcı e-postasını al
  String? get userEmail => _authService.currentUser?.email;
}

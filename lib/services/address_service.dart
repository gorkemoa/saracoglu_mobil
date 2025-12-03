import '../core/constants/api_constants.dart';
import '../models/address/add_address_model.dart';
import '../models/address/update_address_model.dart';
import '../models/address/user_address_model.dart';
import 'network_service.dart';
import 'auth_service.dart';

/// Adres yönetimi servisi - Singleton pattern
class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final NetworkService _networkService = NetworkService();
  final AuthService _authService = AuthService();

  /// Kullanıcının adreslerini getir
  Future<UserAddressesResponse> getAddresses() async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return UserAddressesResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      final result = await _networkService.get(
        '${ApiConstants.getUserAddresses}?userToken=$token',
      );

      if (result.isSuccess && result.data != null) {
        return UserAddressesResponse.fromJson(result.data!);
      } else {
        return UserAddressesResponse.errorResponse(
          result.errorMessage ?? 'Adresler yüklenirken bir hata oluştu',
        );
      }
    } catch (e) {
      return UserAddressesResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
    }
  }

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

  /// Adres güncelle
  Future<UpdateAddressResponse> updateAddress(UpdateAddressRequest request) async {
    try {
      final result = await _networkService.put(
        ApiConstants.updateAddress,
        body: request.toJson(),
      );

      if (result.isSuccess && result.data != null) {
        return UpdateAddressResponse.fromJson(result.data!);
      } else {
        return UpdateAddressResponse.errorResponse(
          result.errorMessage ?? 'Adres güncellenirken bir hata oluştu',
        );
      }
    } catch (e) {
      return UpdateAddressResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
    }
  }

  /// Adres sil
  Future<DeleteAddressResponse> deleteAddress(int addressID) async {
    try {
      final token = _authService.currentUser?.token;
      if (token == null) {
        return DeleteAddressResponse.errorResponse('Oturum açmanız gerekiyor');
      }

      final request = DeleteAddressRequest(
        userToken: token,
        addressID: addressID,
      );

      final result = await _networkService.delete(
        ApiConstants.deleteAddress,
        body: request.toJson(),
      );

      if (result.isSuccess && result.data != null) {
        return DeleteAddressResponse.fromJson(result.data!);
      } else {
        return DeleteAddressResponse.errorResponse(
          result.errorMessage ?? 'Adres silinirken bir hata oluştu',
        );
      }
    } catch (e) {
      return DeleteAddressResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
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

import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../models/contract/contract_model.dart';
import 'network_service.dart';

/// Sözleşme ve Yasal Metin Servisi
/// Singleton pattern
class ContractService {
  static final ContractService _instance = ContractService._internal();
  factory ContractService() => _instance;
  ContractService._internal();

  final NetworkService _networkService = NetworkService();
  final Logger _logger = Logger();

  /// Gizlilik Politikası getir
  Future<ContractResponse> getPrivacyPolicy() async {
    try {
      _logger.d('📤 Get Privacy Policy Request');

      final result = await _networkService.get(ApiConstants.getPrivacyPolicy);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        return ContractResponse.fromJson(result.data!);
      } else {
        return ContractResponse.errorResponse(
          result.errorMessage ?? 'Gizlilik politikası yüklenemedi',
        );
      }
    } catch (e) {
      _logger.e('❌ Gizlilik politikası yükleme hatası', error: e);
      return ContractResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
    }
  }

  /// Üyelik Sözleşmesi getir
  Future<ContractResponse> getMembershipAgreement() async {
    try {
      _logger.d('📤 Get Membership Agreement Request');

      final result = await _networkService.get(
        ApiConstants.getMembershipAgreement,
      );

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        return ContractResponse.fromJson(result.data!);
      } else {
        return ContractResponse.errorResponse(
          result.errorMessage ?? 'Üyelik sözleşmesi yüklenemedi',
        );
      }
    } catch (e) {
      _logger.e('❌ Üyelik sözleşmesi yükleme hatası', error: e);
      return ContractResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
    }
  }

  /// KVKK Aydınlatma Metni getir
  Future<ContractResponse> getKVKKPolicy() async {
    try {
      _logger.d('📤 Get KVKK Policy Request');

      final result = await _networkService.get(ApiConstants.getKVKKPolicy);

      _logger.d('📥 Response Status: ${result.statusCode}');
      _logger.d('📥 Response Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        return ContractResponse.fromJson(result.data!);
      } else {
        return ContractResponse.errorResponse(
          result.errorMessage ?? 'KVKK metni yüklenemedi',
        );
      }
    } catch (e) {
      _logger.e('❌ KVKK metni yükleme hatası', error: e);
      return ContractResponse.errorResponse('Bir hata oluştu: ${e.toString()}');
    }
  }
}

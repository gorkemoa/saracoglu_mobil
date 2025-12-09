import '../core/constants/api_constants.dart';
import '../models/banner/banner_model.dart';
import 'network_service.dart';

class BannerService {
  BannerService._internal();
  static final BannerService _instance = BannerService._internal();
  factory BannerService() => _instance;

  final NetworkService _networkService = NetworkService();

  /// Banner listesini getirir
Future<List<BannerModel>> getBanners() async {
  try {
    final response = await _networkService.get(ApiConstants.getBanners);

    if (response.statusCode == 200 && response.data != null) {
      final Map<String, dynamic> json =
          Map<String, dynamic>.from(response.data as Map);

      final bannerResponse = BannerResponse.fromJson(json);

      return bannerResponse.success ? bannerResponse.banners : [];
    }

    return [];
  } catch (e) {
    return [];
  }
}


}

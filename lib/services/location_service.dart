import '../core/constants/api_constants.dart';
import '../models/location/location_model.dart';
import 'network_service.dart';

/// Lokasyon servisi - Şehir, İlçe, Mahalle bilgilerini getirir
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final NetworkService _networkService = NetworkService();

  // Cache'ler
  List<City>? _cachedCities;
  final Map<int, List<District>> _cachedDistricts = {};
  final Map<int, List<Neighbourhood>> _cachedNeighbourhoods = {};

  /// Tüm şehirleri getir
  Future<CitiesResponse> getCities({bool forceRefresh = false}) async {
    // Cache kontrolü
    if (!forceRefresh && _cachedCities != null) {
      return CitiesResponse(
        error: false,
        success: true,
        cities: _cachedCities!,
      );
    }

    try {
      final result = await _networkService.get(ApiConstants.getCities);

      if (result.isSuccess && result.data != null) {
        final response = CitiesResponse.fromJson(result.data!);
        if (response.isSuccess) {
          _cachedCities = response.cities;
        }
        return response;
      } else {
        return CitiesResponse(
          error: true,
          success: false,
          cities: [],
        );
      }
    } catch (e) {
      return CitiesResponse(
        error: true,
        success: false,
        cities: [],
      );
    }
  }

  /// Şehre göre ilçeleri getir
  Future<DistrictsResponse> getDistricts(int cityNo, {bool forceRefresh = false}) async {
    // Cache kontrolü
    if (!forceRefresh && _cachedDistricts.containsKey(cityNo)) {
      return DistrictsResponse(
        error: false,
        success: true,
        districts: _cachedDistricts[cityNo]!,
      );
    }

    try {
      final endpoint = '${ApiConstants.getDistricts}/$cityNo/districts';
      final result = await _networkService.get(endpoint);

      if (result.isSuccess && result.data != null) {
        final response = DistrictsResponse.fromJson(result.data!);
        if (response.isSuccess) {
          _cachedDistricts[cityNo] = response.districts;
        }
        return response;
      } else {
        return DistrictsResponse(
          error: true,
          success: false,
          districts: [],
        );
      }
    } catch (e) {
      return DistrictsResponse(
        error: true,
        success: false,
        districts: [],
      );
    }
  }

  /// İlçeye göre mahalleleri getir
  Future<NeighbourhoodsResponse> getNeighbourhoods(int districtNo, {bool forceRefresh = false}) async {
    // Cache kontrolü
    if (!forceRefresh && _cachedNeighbourhoods.containsKey(districtNo)) {
      return NeighbourhoodsResponse(
        error: false,
        success: true,
        neighbourhoods: _cachedNeighbourhoods[districtNo]!,
      );
    }

    try {
      final endpoint = '${ApiConstants.getNeighbourhoods}/$districtNo/neighbourhood';
      final result = await _networkService.get(endpoint);

      if (result.isSuccess && result.data != null) {
        final response = NeighbourhoodsResponse.fromJson(result.data!);
        if (response.isSuccess) {
          _cachedNeighbourhoods[districtNo] = response.neighbourhoods;
        }
        return response;
      } else {
        return NeighbourhoodsResponse(
          error: true,
          success: false,
          neighbourhoods: [],
        );
      }
    } catch (e) {
      return NeighbourhoodsResponse(
        error: true,
        success: false,
        neighbourhoods: [],
      );
    }
  }

  /// Cache'i temizle
  void clearCache() {
    _cachedCities = null;
    _cachedDistricts.clear();
    _cachedNeighbourhoods.clear();
  }
}

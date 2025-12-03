/// Şehir modeli
class City {
  final String name;
  final int no;

  City({required this.name, required this.no});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['cityName'] ?? '',
      no: json['cityNo'] ?? 0,
    );
  }
}

/// İlçe modeli
class District {
  final String name;
  final int no;

  District({required this.name, required this.no});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      name: json['districtName'] ?? '',
      no: json['districtNo'] ?? 0,
    );
  }
}

/// Mahalle modeli
class Neighbourhood {
  final String name;
  final String no;

  Neighbourhood({required this.name, required this.no});

  factory Neighbourhood.fromJson(Map<String, dynamic> json) {
    return Neighbourhood(
      name: json['name'] ?? '',
      no: json['neighbourhoodNo']?.toString() ?? '0',
    );
  }
}

/// Şehirler listesi yanıtı
class CitiesResponse {
  final bool error;
  final bool success;
  final List<City> cities;

  CitiesResponse({
    required this.error,
    required this.success,
    required this.cities,
  });

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    final citiesJson = json['data']?['cities'] as List<dynamic>? ?? [];
    return CitiesResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      cities: citiesJson
          .map((c) => City.fromJson(c as Map<String, dynamic>))
          .where((c) => c.no != 0) // "Tümü" seçeneğini filtrele
          .toList(),
    );
  }

  bool get isSuccess => success && !error;
}

/// İlçeler listesi yanıtı
class DistrictsResponse {
  final bool error;
  final bool success;
  final List<District> districts;

  DistrictsResponse({
    required this.error,
    required this.success,
    required this.districts,
  });

  factory DistrictsResponse.fromJson(Map<String, dynamic> json) {
    final districtsJson = json['data']?['districts'] as List<dynamic>? ?? [];
    return DistrictsResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      districts: districtsJson
          .map((d) => District.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isSuccess => success && !error;
}

/// Mahalleler listesi yanıtı
class NeighbourhoodsResponse {
  final bool error;
  final bool success;
  final List<Neighbourhood> neighbourhoods;

  NeighbourhoodsResponse({
    required this.error,
    required this.success,
    required this.neighbourhoods,
  });

  factory NeighbourhoodsResponse.fromJson(Map<String, dynamic> json) {
    final neighbourhoodsJson =
        json['data']?['neighborhoods'] as List<dynamic>? ?? [];
    return NeighbourhoodsResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      neighbourhoods: neighbourhoodsJson
          .map((n) => Neighbourhood.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isSuccess => success && !error;
}

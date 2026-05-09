class Country {
  final String commonName;
  final String officialName;
  final String? capital;
  final String region;
  final String? subregion;
  final int population;
  final String flagPng;
  final double? capitalLatitude;
  final double? capitalLongitude;
  final Map<String, String> languages;
  final List<Currency> currencies;
  final List<String> timezones;
  final List<String> borders;
  final double area;

  const Country({
    required this.commonName,
    required this.officialName,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.flagPng,
    required this.capitalLatitude,
    required this.capitalLongitude,
    required this.languages,
    required this.currencies,
    required this.timezones,
    required this.borders,
    required this.area,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>?;
    final flags = json['flags'] as Map<String, dynamic>?;

    final capitalList = json['capital'] as List<dynamic>?;
    final capitalInfo = json['capitalInfo'] as Map<String, dynamic>?;
    final latlng = capitalInfo?['latlng'] as List<dynamic>?;

    final languagesJson = json['languages'] as Map<String, dynamic>?;
    final currenciesJson = json['currencies'] as Map<String, dynamic>?;

    return Country(
      commonName: name?['common']?.toString() ?? 'Nombre desconocido',
      officialName: name?['official']?.toString() ?? 'Nombre oficial desconocido',
      capital: capitalList != null && capitalList.isNotEmpty
          ? capitalList.first.toString()
          : null,
      region: json['region']?.toString() ?? 'Región desconocida',
      subregion: json['subregion']?.toString(),
      population: (json['population'] as num?)?.toInt() ?? 0,
      flagPng: flags?['png']?.toString() ?? '',
      capitalLatitude: latlng != null && latlng.length >= 2
          ? (latlng[0] as num).toDouble()
          : null,
      capitalLongitude: latlng != null && latlng.length >= 2
          ? (latlng[1] as num).toDouble()
          : null,
      languages: languagesJson?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {},
      currencies: currenciesJson?.entries.map((entry) {
            final value = entry.value as Map<String, dynamic>;
            return Currency(
              code: entry.key,
              name: value['name']?.toString() ?? entry.key,
              symbol: value['symbol']?.toString(),
            );
          }).toList() ??
          [],
      timezones:
          (json['timezones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      borders:
          (json['borders'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      area: (json['area'] as num?)?.toDouble() ?? 0,
    );
  }

  bool get hasCapitalCoordinates =>
      capitalLatitude != null && capitalLongitude != null;

  double? get populationDensity {
    if (area <= 0) return null;
    return population / area;
  }
}

class Currency {
  final String code;
  final String name;
  final String? symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  String get formatted {
    if (symbol == null || symbol!.isEmpty) return '$name ($code)';
    return '$name ($symbol, $code)';
  }
}
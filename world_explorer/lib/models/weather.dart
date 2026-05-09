class Weather {
  final CurrentWeather current;
  final List<DailyForecast> dailyForecasts;

  const Weather({
    required this.current,
    required this.dailyForecasts,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current_weather'] as Map<String, dynamic>?;
    final dailyJson = json['daily'] as Map<String, dynamic>?;

    if (currentJson == null) {
      throw const FormatException('Missing current_weather');
    }

    final times = (dailyJson?['time'] as List<dynamic>?) ?? [];
    final maxTemps = (dailyJson?['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (dailyJson?['temperature_2m_min'] as List<dynamic>?) ?? [];
    final codes = (dailyJson?['weathercode'] as List<dynamic>?) ?? [];

    final daily = <DailyForecast>[];
    for (var i = 0; i < times.length; i++) {
      if (i < maxTemps.length && i < minTemps.length && i < codes.length) {
        daily.add(
          DailyForecast(
            date: DateTime.parse(times[i].toString()),
            maxTemperature: (maxTemps[i] as num).toDouble(),
            minTemperature: (minTemps[i] as num).toDouble(),
            weatherCode: (codes[i] as num).toInt(),
          ),
        );
      }
    }

    return Weather(
      current: CurrentWeather.fromJson(currentJson),
      dailyForecasts: daily,
    );
  }
}

class CurrentWeather {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final DateTime time;

  const CurrentWeather({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature'] as num).toDouble(),
      windSpeed: (json['windspeed'] as num).toDouble(),
      weatherCode: (json['weathercode'] as num).toInt(),
      time: DateTime.parse(json['time'].toString()),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
  });
}
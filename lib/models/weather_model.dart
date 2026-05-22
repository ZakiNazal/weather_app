class AirQuality {
  final int? aqi;
  final double? pm25;
  final double? pm10;
  final double? ozone;

  AirQuality({this.aqi, this.pm25, this.pm10, this.ozone});

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    return AirQuality(
      aqi: json['aqi'] is num ? (json['aqi'] as num).toInt() : null,
      pm25: json['pm2_5'] is num ? (json['pm2_5'] as num).toDouble() : null,
      pm10: json['pm10'] is num ? (json['pm10'] as num).toDouble() : null,
      ozone: json['o3'] is num ? (json['o3'] as num).toDouble() : null,
    );
  }
}

class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final double? windSpeed;
  final int? windDeg;
  final int? humidity;
  final double? feelsLike;
  final int? visibility;
  final int? pressure;
  final double? uvIndex;
  final DateTime? sunrise;
  final DateTime? sunset;
  final AirQuality? airQuality;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    this.hourly = const [],
    this.daily = const [],
    this.windSpeed,
    this.windDeg,
    this.humidity,
    this.feelsLike,
    this.visibility,
    this.pressure,
    this.uvIndex,
    this.sunrise,
    this.sunset,
    this.airQuality,
  });
}

class HourlyForecast {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String condition;
  final double? precipProbability;

  HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.condition,
    this.precipProbability,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List?;
    final weatherItem = weatherList?.isNotEmpty == true
        ? weatherList![0] as Map<String, dynamic>?
        : null;
    final pop = json['pop'];

    return HourlyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
          (json['dt'] as num).toInt() * 1000),
      temperature:
          json['temp'] is num ? (json['temp'] as num).toDouble() : 0.0,
      description: weatherItem?['description'] as String? ?? '',
      condition: weatherItem?['main'] as String? ?? '',
      precipProbability: pop is num ? pop.toDouble() * 100 : null,
    );
  }
}

class DailyForecast {
  final DateTime dateTime;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String condition;
  final double? precipProbability;

  DailyForecast({
    required this.dateTime,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.condition,
    this.precipProbability,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final tempMap = json['temp'] as Map<String, dynamic>?;
    final weatherList = json['weather'] as List?;
    final weatherItem = weatherList?.isNotEmpty == true
        ? weatherList![0] as Map<String, dynamic>?
        : null;
    final pop = json['pop'];

    return DailyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
          (json['dt'] as num).toInt() * 1000),
      maxTemp: tempMap?['max'] is num
          ? (tempMap!['max'] as num).toDouble()
          : 0.0,
      minTemp: tempMap?['min'] is num
          ? (tempMap!['min'] as num).toDouble()
          : 0.0,
      description: weatherItem?['description'] as String? ?? '',
      condition: weatherItem?['main'] as String? ?? '',
      precipProbability: pop is num ? pop.toDouble() * 100 : null,
    );
  }
}

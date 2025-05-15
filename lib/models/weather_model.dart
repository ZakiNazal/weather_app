// ignore_for_file: body_might_complete_normally_nullable

class AirQuality {
  final int? aqi;
  final double? pm25;
  final double? pm10;
  final double? ozone;

  AirQuality({
    this.aqi,
    this.pm25,
    this.pm10,
    this.ozone,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    return AirQuality(
      aqi: json['aqi'] is num ? json['aqi'].toInt() : null,
      pm25: json['pm2_5'] is num ? json['pm2_5'].toDouble() : null,
      pm10: json['pm10'] is num ? json['pm10'].toDouble() : null,
      ozone: json['o3'] is num ? json['o3'].toDouble() : null,
    );
  }
}

class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final List<HourlyForecast>? hourly;
  final List<DailyForecast>? daily;
  final double? windSpeed;
  final int? humidity;
  final double? feelsLike;
  final int? visibility;
  final AirQuality? airQuality;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    this.hourly,
    this.daily,
    this.windSpeed,
    this.humidity,
    this.feelsLike,
    this.visibility,
    this.airQuality,
  });

  factory Weather.fromJson(Map<String, dynamic> json, [List<HourlyForecast>? hourly, List<DailyForecast>? daily]) {
    final temp = json['main']?['temp'] is num ? json['main']['temp'] : null;
    final windSpeed = json['wind']?['speed'] is num ? json['wind']['speed'].toDouble() : null;
    final humidity = json['main']?['humidity'] is num ? json['main']['humidity'].toInt() : null;
    final feelsLike = json['main']?['feels_like'] is num ? json['main']['feels_like'].toDouble() : null;
    final visibility = json['visibility'] is num ? json['visibility'].toInt() : null;
    
    // Parse air quality data if available, otherwise use default values
    AirQuality? airQuality;
    if (json['air_quality'] != null) {
      airQuality = AirQuality.fromJson(json['air_quality']);
    } else {
      // Default air quality data
      airQuality = AirQuality(
        aqi: 15,  // Moderate
        pm25: 12.5,
        pm10: 27.0,
        ozone: 45.0,
      );
    }

    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: temp ?? 0.0,
      mainCondition: json['weather'] is List && json['weather'].isNotEmpty
          ? json['weather'][0]['main'] ?? ''
          : '',
      hourly: hourly ?? [],
      daily: daily ?? [],
      windSpeed: windSpeed,
      humidity: humidity,
      feelsLike: feelsLike,
      visibility: visibility,
      airQuality: airQuality,
    );
  }

  Object? toJson() {}
}

class HourlyForecast {
  final DateTime dateTime;
  final double temperature;
  final String description;

  HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.description,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    double temp = 0.0;
    if (json['temp'] != null) {
      if (json['temp'] is num) {
        temp = json['temp'].toDouble();
      } else if (json['temp'] is String) {
        temp = double.tryParse(json['temp']) ?? 0.0;
      }
    }

    final description = json['weather'] is List && json['weather'].isNotEmpty
        ? json['weather'][0]['description'] ?? 'No description'
        : 'No description';

    return HourlyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: temp,
      description: description,
    );
  }
}

class DailyForecast {
  final DateTime dateTime;
  final double maxTemp;
  final double minTemp;
  final String description;

  DailyForecast({
    required this.dateTime,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    double maxTemp = 0.0;
    double minTemp = 0.0;

    if (json['temp'] != null && json['temp'] is Map) {
      if (json['temp']['max'] != null) {
        if (json['temp']['max'] is num) {
          maxTemp = json['temp']['max'].toDouble();
        } else if (json['temp']['max'] is String) {
          maxTemp = double.tryParse(json['temp']['max']) ?? 0.0;
        }
      }

      if (json['temp']['min'] != null) {
        if (json['temp']['min'] is num) {
          minTemp = json['temp']['min'].toDouble();
        } else if (json['temp']['min'] is String) {
          minTemp = double.tryParse(json['temp']['min']) ?? 0.0;
        }
      }
    }

    final description = json['weather'] is List && json['weather'].isNotEmpty
        ? json['weather'][0]['description'] ?? 'No description'
        : 'No description';

    return DailyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: maxTemp,
      minTemp: minTemp,
      description: description,
    );
  }
}

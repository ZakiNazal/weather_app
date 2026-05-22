import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const _oneCallUrl =
      'https://api.openweathermap.org/data/3.0/onecall';

  final String apiKey;
  WeatherService(this.apiKey);

  Future<Weather> getWeatherFromCoordinates(double lat, double lon) async {
    final currentRes = await http.get(
      Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );
    if (currentRes.statusCode != 200) {
      throw Exception('Weather fetch failed (${currentRes.statusCode})');
    }
    final currentJson =
        jsonDecode(currentRes.body) as Map<String, dynamic>;

    final forecastRes = await http.get(
      Uri.parse(
        '$_oneCallUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric&exclude=minutely,alerts',
      ),
    );
    if (forecastRes.statusCode != 200) {
      throw Exception('Forecast fetch failed (${forecastRes.statusCode})');
    }
    final forecastJson =
        jsonDecode(forecastRes.body) as Map<String, dynamic>;

    final current = forecastJson['current'] as Map<String, dynamic>?;

    final hourly = <HourlyForecast>[];
    if (forecastJson['hourly'] is List) {
      for (final item in (forecastJson['hourly'] as List).take(24)) {
        hourly.add(HourlyForecast.fromJson(item as Map<String, dynamic>));
      }
    }

    final daily = <DailyForecast>[];
    if (forecastJson['daily'] is List) {
      for (final item in (forecastJson['daily'] as List).take(7)) {
        daily.add(DailyForecast.fromJson(item as Map<String, dynamic>));
      }
    }

    final mainData = currentJson['main'] as Map<String, dynamic>?;
    final windData = currentJson['wind'] as Map<String, dynamic>?;
    final sysData = currentJson['sys'] as Map<String, dynamic>?;
    final weatherList = currentJson['weather'] as List?;
    final mainCondition = weatherList?.isNotEmpty == true
        ? (weatherList![0] as Map<String, dynamic>)['main'] as String? ?? ''
        : '';

    DateTime? sunrise, sunset;
    if (sysData?['sunrise'] is num) {
      sunrise = DateTime.fromMillisecondsSinceEpoch(
          (sysData!['sunrise'] as num).toInt() * 1000);
    }
    if (sysData?['sunset'] is num) {
      sunset = DateTime.fromMillisecondsSinceEpoch(
          (sysData!['sunset'] as num).toInt() * 1000);
    }

    return Weather(
      cityName: currentJson['name'] as String? ?? 'Unknown',
      temperature: mainData?['temp'] is num
          ? (mainData!['temp'] as num).toDouble()
          : 0.0,
      mainCondition: mainCondition,
      hourly: hourly,
      daily: daily,
      windSpeed: windData?['speed'] is num
          ? (windData!['speed'] as num).toDouble()
          : null,
      windDeg: windData?['deg'] is num
          ? (windData!['deg'] as num).toInt()
          : null,
      humidity: mainData?['humidity'] is num
          ? (mainData!['humidity'] as num).toInt()
          : null,
      feelsLike: mainData?['feels_like'] is num
          ? (mainData!['feels_like'] as num).toDouble()
          : null,
      visibility: currentJson['visibility'] is num
          ? (currentJson['visibility'] as num).toInt()
          : null,
      pressure: mainData?['pressure'] is num
          ? (mainData!['pressure'] as num).toInt()
          : null,
      uvIndex: current?['uvi'] is num
          ? (current!['uvi'] as num).toDouble()
          : null,
      sunrise: sunrise,
      sunset: sunset,
      airQuality: null,
    );
  }

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
    }
    return Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));
  }

  Future<Weather> getWeather(String cityName) async {
    final res = await http.get(
      Uri.parse('$_baseUrl?q=$cityName&appid=$apiKey&units=metric'),
    );
    if (res.statusCode != 200) {
      throw Exception('City not found: $cityName');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final lat = (json['coord']?['lat'] as num?)?.toDouble();
    final lon = (json['coord']?['lon'] as num?)?.toDouble();
    if (lat == null || lon == null) {
      throw Exception('Invalid coordinates for: $cityName');
    }
    return getWeatherFromCoordinates(lat, lon);
  }
}

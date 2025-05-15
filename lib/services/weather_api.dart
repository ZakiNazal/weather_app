// weather_api.dart

// ignore_for_file: constant_identifier_names, deprecated_member_use, avoid_print, non_constant_identifier_names

import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  static const ONE_CALL_URL = 'https://api.openweathermap.org/data/3.0/onecall';

  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeatherFromCoordinates(double lat, double lon) async {
    // Get current weather data
    final response = await http.get(
      Uri.parse('$BASE_URL?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data: ${response.body}');
    }

    final json = jsonDecode(response.body);

    // Get One Call API data
    final oneCallResponse = await http.get(
      Uri.parse('$ONE_CALL_URL?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (oneCallResponse.statusCode != 200) {
      print('Status Code: ${oneCallResponse.statusCode}');
      print('Response Body: ${oneCallResponse.body}');
      throw Exception('Failed to load forecast data: ${oneCallResponse.body}');
    }

    late final Map<String, dynamic> oneCallJson;
    try {
      oneCallJson = jsonDecode(oneCallResponse.body);
      print('One Call API Response: $oneCallJson'); // Debug full response
    } catch (e) {
      print("JSON decode error: $e");
      print("Raw response: ${oneCallResponse.body}");
      rethrow;
    }

    // Parse hourly forecast
    List<HourlyForecast> hourly = [];
    if (oneCallJson['hourly'] != null && oneCallJson['hourly'] is List) {
      for (var item in oneCallJson['hourly'].take(24)) {
        print('Hourly forecast item: $item'); // Debug full hourly item
        print('Hourly temp type: ${item['temp'].runtimeType}'); // Debug temp type
        print('Hourly temp value: ${item['temp']}'); // Debug temp value
        final forecast = HourlyForecast.fromJson(item);
        print('Parsed hourly temp: ${forecast.temperature}'); // Debug parsed temp
        hourly.add(forecast);
      }
    }

    // Parse daily forecast
    List<DailyForecast> daily = [];
    if (oneCallJson['daily'] != null && oneCallJson['daily'] is List) {
      for (var item in oneCallJson['daily'].take(7)) {
        print('Daily forecast item: $item'); // Debug full daily item
        print('Daily temp type: ${item['temp']?['max'].runtimeType}'); // Debug temp type
        print('Daily max temp value: ${item['temp']?['max']}'); // Debug temp value
        print('Daily min temp value: ${item['temp']?['min']}'); // Debug temp value
        final forecast = DailyForecast.fromJson(item);
        print('Parsed daily max temp: ${forecast.maxTemp}'); // Debug parsed max temp
        print('Parsed daily min temp: ${forecast.minTemp}'); // Debug parsed min temp
        daily.add(forecast);
      }
    }

    return Weather.fromJson(json, hourly, daily);
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

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load city data: ${response.body}');
    }

    final json = jsonDecode(response.body);
    final lat = json['coord']?['lat']?.toDouble();
    final lon = json['coord']?['lon']?.toDouble();

    if (lat == null || lon == null) {
      throw Exception('Invalid coordinates for city: $cityName');
    }

    return getWeatherFromCoordinates(lat, lon);
  }
}

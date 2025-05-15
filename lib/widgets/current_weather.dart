// current_weather.dart

// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/temperature_converter.dart';
import 'package:weather_app/services/weather_icon.dart';

class CurrentWeather extends StatefulWidget {
  final bool isCelsius;
  final Weather? weather;

  const CurrentWeather({
    super.key,
    required this.isCelsius,
    required this.weather,
  });

  @override
  State<CurrentWeather> createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather> {

  void _updateCurrentDate() {
    if (mounted) {
      setState(() {
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _updateCurrentDate();

    // Optional: Update date every minute
    Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCurrentDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.weather;

    if (weather == null) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No weather data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.cityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.mainCondition,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  WeatherIcon.getIcon(weather.mainCondition),
                  key: ValueKey(weather.mainCondition),
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TemperatureConverter.formatTemperature(weather.temperature, widget.isCelsius),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (weather.feelsLike != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Feels like',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      TemperatureConverter.formatTemperature(weather.feelsLike, widget.isCelsius),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (weather.windSpeed != null)
                _buildInfoBox(
                  'Wind',
                  '${weather.windSpeed!.round()} m/s',
                  Icons.air,
                ),
              if (weather.humidity != null)
                _buildInfoBox(
                  'Humidity',
                  '${weather.humidity}%',
                  Icons.water_drop,
                ),
              if (weather.visibility != null)
                _buildInfoBox(
                  'Visibility',
                  '${(weather.visibility! / 1000).round()} km',
                  Icons.visibility,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.teal,
            size: 25,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

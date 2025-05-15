// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_icon.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast>? hourly;
  final bool isCelsius;

  const HourlyForecastWidget({
    super.key,
    required this.hourly,
    required this.isCelsius, required hourlyForecasts,
  });

  String formatTemp(double temp) {
    if (!isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return '${temp.round()}°${isCelsius ? 'C' : 'F'}';
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    if (hourly == null || hourly!.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No hourly forecast available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourly!.length,
        itemBuilder: (context, index) {
          final hour = hourly![index];
          final isCurrentHour = index == 0;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrentHour ? Colors.teal.shade700 : Colors.teal,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade500,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isCurrentHour ? 'Now' : formatTime(hour.dateTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    WeatherIcon.getIcon(hour.description),
                    key: ValueKey(hour.description),
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatTemp(hour.temperature),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  WeatherIcon.getFormattedCondition(hour.description),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
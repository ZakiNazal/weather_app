// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/services/weather_icon.dart'; // For DateFormat

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast>? forecast;
  final bool isCelsius;

  const DailyForecastWidget({
    super.key, 
    required this.forecast,
    required this.isCelsius,
  });

  String formatTemp(double temp) {
    print('Daily temp before conversion: $temp'); // Debug print
    if (!isCelsius) {
      // Convert Celsius to Fahrenheit
      temp = (temp * 9 / 5) + 32;
      print('Daily temp after conversion: $temp'); // Debug print
    }
    return '${temp.round()}°${isCelsius ? 'C' : 'F'}';
  }

  @override
  Widget build(BuildContext context) {
    print('Building DailyForecastWidget with ${forecast!.length} items'); // Debug print
    if (forecast == null || forecast!.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No forecast data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: forecast!.length,
      itemBuilder: (context, index) {
        final day = forecast![index];
        print('Daily item $index: ${day.maxTemp}°C/${day.minTemp}°C'); // Debug print
        final date = DateFormat.E().format(day.dateTime); // e.g., "Mon"
        final isToday = index == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isToday ? Colors.teal.shade700 : Colors.teal,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Today' : date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.MMMd().format(day.dateTime),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: Icon(
                      WeatherIcon.getIcon(day.description),
                      key: ValueKey(day.description),
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formatTemp(day.maxTemp),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("•", 
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                           ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          formatTemp(day.minTemp),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      WeatherIcon.getFormattedCondition(day.description),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_icon.dart';
import 'package:weather_app/utils/weather_theme.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecast;
  final bool isCelsius;

  const DailyForecastWidget({
    super.key,
    required this.forecast,
    required this.isCelsius,
  });

  String _temp(double t) {
    if (!isCelsius) t = t * 9 / 5 + 32;
    return '${t.round()}°';
  }

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return GlassCard(
        child: Center(
          child: Text('No forecast data',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        ),
      );
    }

    // Compute global min/max for temp bar scaling
    final allMax = forecast.map((d) => d.maxTemp).reduce((a, b) => a > b ? a : b);
    final allMin = forecast.map((d) => d.minTemp).reduce((a, b) => a < b ? a : b);
    final range = (allMax - allMin).clamp(1.0, double.infinity);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: List.generate(forecast.length, (i) {
          final day = forecast[i];
          final isToday = i == 0;
          final isLast = i == forecast.length - 1;
          final label = isToday ? 'Today' : DateFormat.E().format(day.dateTime);
          final date = DateFormat.MMMd().format(day.dateTime);
          final precip = day.precipProbability;

          // Temp bar positions (0..1)
          final barStart = ((day.minTemp - allMin) / range).clamp(0.0, 1.0);
          final barEnd = ((day.maxTemp - allMin) / range).clamp(0.0, 1.0);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // Day label
                    SizedBox(
                      width: 52,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              )),
                          Text(date,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                              )),
                        ],
                      ),
                    ),
                    // Icon + optional precip
                    SizedBox(
                      width: 44,
                      child: Column(
                        children: [
                          Icon(WeatherIcon.getIcon(day.condition),
                              color: Colors.white, size: 24),
                          if (precip != null && precip > 5)
                            Text(
                              '${precip.round()}%',
                              style: TextStyle(
                                  color: Colors.lightBlue.shade200,
                                  fontSize: 10),
                            ),
                        ],
                      ),
                    ),
                    // Min temp
                    SizedBox(
                      width: 34,
                      child: Text(
                        _temp(day.minTemp),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Temp range bar
                    Expanded(
                      child: LayoutBuilder(builder: (_, c) {
                        final w = c.maxWidth;
                        return Stack(children: [
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Positioned(
                            left: w * barStart,
                            width: (w * (barEnd - barStart)).clamp(8.0, w),
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF42A5F5),
                                  Color(0xFFFF7043),
                                ]),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ]);
                      }),
                    ),
                    const SizedBox(width: 8),
                    // Max temp
                    SizedBox(
                      width: 34,
                      child: Text(
                        _temp(day.maxTemp),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 0,
                ),
            ],
          );
        }),
      ),
    );
  }
}

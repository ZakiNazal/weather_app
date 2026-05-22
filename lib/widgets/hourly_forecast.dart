import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_icon.dart';
import 'package:weather_app/utils/weather_theme.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final bool isCelsius;

  const HourlyForecastWidget({
    super.key,
    required this.hourly,
    required this.isCelsius,
  });

  String _formatTemp(double temp) {
    if (!isCelsius) temp = temp * 9 / 5 + 32;
    return '${temp.round()}°';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    if (h == 0) return '12 AM';
    if (h < 12) return '$h AM';
    if (h == 12) return '12 PM';
    return '${h - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) {
      return GlassCard(
        child: Center(
          child: Text('No hourly data',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        ),
      );
    }

    return SizedBox(
      height: 135,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final h = hourly[i];
          final isNow = i == 0;
          final precip = h.precipProbability;

          return Container(
              width: 78,
              decoration: BoxDecoration(
                color: isNow
                    ? Colors.white.withValues(alpha: 0.28)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isNow ? 0.4 : 0.18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isNow ? 'Now' : _formatTime(h.dateTime),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: isNow ? 1.0 : 0.7),
                        fontSize: 12,
                        fontWeight:
                            isNow ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                    Icon(
                      WeatherIcon.getIcon(h.condition),
                      color: Colors.white,
                      size: 26,
                    ),
                    Text(
                      _formatTemp(h.temperature),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (precip != null && precip > 5)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop_rounded,
                              size: 11,
                              color: Colors.lightBlue.shade200),
                          const SizedBox(width: 2),
                          Text(
                            '${precip.round()}%',
                            style: TextStyle(
                              color: Colors.lightBlue.shade200,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(height: 14),
                  ],
                ),
              ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:weather_app/utils/weather_theme.dart';

class AirQualityWidget extends StatelessWidget {
  final int? aqi;
  final double? pm25;
  final double? pm10;
  final double? ozone;

  const AirQualityWidget({
    super.key,
    this.aqi,
    this.pm25,
    this.pm10,
    this.ozone,
  });

  String _level(int v) {
    if (v <= 50) return 'Good';
    if (v <= 100) return 'Moderate';
    if (v <= 150) return 'Unhealthy for Some';
    if (v <= 200) return 'Unhealthy';
    if (v <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color _color(int v) {
    if (v <= 50) return const Color(0xFF4CAF50);
    if (v <= 100) return const Color(0xFFFFC107);
    if (v <= 150) return const Color(0xFFFF9800);
    if (v <= 200) return const Color(0xFFF44336);
    if (v <= 300) return const Color(0xFF9C27B0);
    return const Color(0xFF795548);
  }

  String _description(int v) {
    if (v <= 50) return 'Air quality is satisfactory with little or no risk.';
    if (v <= 100) return 'Acceptable quality; some risk for sensitive individuals.';
    if (v <= 150) return 'Sensitive groups may experience health effects.';
    if (v <= 200) return 'Everyone may begin to experience health effects.';
    if (v <= 300) return 'Health warnings of emergency conditions.';
    return 'Health alert: serious effects for everyone.';
  }

  @override
  Widget build(BuildContext context) {
    if (aqi == null) {
      return GlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Air quality data unavailable',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
        ),
      );
    }

    final color = _color(aqi!);
    final level = _level(aqi!);
    final desc = _description(aqi!);
    final barValue = (aqi! / 300).clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '$aqi',
                    style: TextStyle(
                      color: color,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AQI',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: color.withValues(alpha: 0.5)),
                        ),
                        child: Text(level,
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barValue,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Text(desc,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  height: 1.4)),
          if (pm25 != null || pm10 != null || ozone != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (pm25 != null) _pollutant('PM2.5', pm25!),
                if (pm10 != null) _pollutant('PM10', pm10!),
                if (ozone != null) _pollutant('O₃', ozone!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _pollutant(String label, double value) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
          const SizedBox(height: 2),
          Text('${value.round()} μg',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

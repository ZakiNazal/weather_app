import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/temperature_converter.dart';
import 'package:weather_app/services/weather_icon.dart';
import 'package:weather_app/utils/weather_theme.dart';

class CurrentWeather extends StatelessWidget {
  final Weather weather;
  final bool isCelsius;

  const CurrentWeather({
    super.key,
    required this.weather,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHero(),
        const SizedBox(height: 16),
        _buildStatsRow(),
        if (weather.uvIndex != null) ...[
          const SizedBox(height: 12),
          _buildUvRow(),
        ],
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Icon(
            WeatherIcon.getIcon(weather.mainCondition),
            key: ValueKey(weather.mainCondition),
            size: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          TemperatureConverter.formatTemperature(weather.temperature, isCelsius),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 76,
            fontWeight: FontWeight.w200,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          WeatherIcon.getFormattedCondition(weather.mainCondition),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        if (weather.feelsLike != null) ...[
          const SizedBox(height: 4),
          Text(
            'Feels like ${TemperatureConverter.formatTemperature(weather.feelsLike, isCelsius)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatsRow() {
    final windDir = WeatherTheme.windDirection(weather.windDeg);
    final windLabel = weather.windSpeed != null
        ? '${(weather.windSpeed! * 3.6).round()} km/h${windDir.isNotEmpty ? ' $windDir' : ''}'
        : null;

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          if (windLabel != null)
            _stat(Icons.air_rounded, 'Wind', windLabel),
          if (weather.humidity != null)
            _stat(Icons.water_drop_rounded, 'Humidity', '${weather.humidity}%'),
          if (weather.visibility != null)
            _stat(Icons.visibility_rounded, 'Visibility',
                '${(weather.visibility! / 1000).toStringAsFixed(1)} km'),
          if (weather.pressure != null)
            _stat(Icons.speed_rounded, 'Pressure', '${weather.pressure} hPa'),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget _buildUvRow() {
    final uvi = weather.uvIndex!;
    final uvColor = WeatherTheme.uvColor(uvi);
    final uvLabel = WeatherTheme.uvLabel(uvi);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.wb_sunny_rounded, color: uvColor, size: 20),
          const SizedBox(width: 10),
          const Text('UV Index',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            uvi.toStringAsFixed(1),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: uvColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: uvColor.withValues(alpha: 0.5)),
            ),
            child: Text(uvLabel,
                style: TextStyle(
                    color: uvColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (uvi / 11).clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(uvColor),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

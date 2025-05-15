import 'package:flutter/material.dart';

class WeatherIcon {
  // Formats a string so each word starts with uppercase (e.g., "clear sky" → "Clear Sky")
  static String toTitleCase(String text) {
    if (text.isEmpty) return '';

    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Get icon based on condition
  static IconData getIcon(String? condition) {
    if (condition == null || condition.isEmpty) return Icons.help_rounded;

    final lower = condition.toLowerCase();

    if (lower.contains('clear')) {
      return Icons.wb_sunny_rounded; // ☀️ Clear sky, clear, clear day
    } else if (lower.contains('cloud') ||
        lower.contains('few clouds') ||
        lower.contains('scattered clouds')) {
      return Icons.cloud_rounded; // ⛅ Cloudy
    } else if (lower.contains('rain') || lower.contains('drizzle')) {
      return Icons.water_drop_rounded; // 🌧️ Rain or drizzle
    } else if (lower.contains('thunderstorm')) {
      return Icons.flash_on_rounded; // ⚡ Thunderstorm
    } else if (lower.contains('snow')) {
      return Icons.ac_unit_rounded; // ❄️ Snow
    } else if (lower.contains('mist') ||
        lower.contains('fog') ||
        lower.contains('haze') ||
        lower.contains('smoke') ||
        lower.contains('dust')) {
      return Icons.filter_hdr_rounded; // 🌫️ Fog/Mist
    } else if (lower.contains('wind')) {
      return Icons.air_rounded; // 💨 Windy
    } else {
      return Icons.help_rounded; // ❓ Unknown condition
    }
  }

  // Optional: Get title case version of condition
  static String getFormattedCondition(String? condition) {
    if (condition == null || condition.isEmpty) return 'Unknown';
    return toTitleCase(condition);
  }
}
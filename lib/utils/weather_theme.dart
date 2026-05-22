import 'package:flutter/material.dart';

class WeatherTheme {
  static List<Color> getGradient(String condition, DateTime now) {
    final hour = now.hour;
    final cond = condition.toLowerCase();
    final isNight = hour >= 20 || hour < 6;
    final isSunrise = hour >= 6 && hour < 9;
    final isSunset = hour >= 17 && hour < 20;

    if (isNight) {
      if (cond.contains('rain') || cond.contains('drizzle')) {
        return [const Color(0xFF0a0e1a), const Color(0xFF141b2d), const Color(0xFF1c2540)];
      }
      if (cond.contains('thunder') || cond.contains('storm')) {
        return [const Color(0xFF0d0019), const Color(0xFF1a0a2e), const Color(0xFF2d1b69)];
      }
      if (cond.contains('snow')) {
        return [const Color(0xFF1a1a2e), const Color(0xFF2d3561), const Color(0xFF3d4a7a)];
      }
      return [const Color(0xFF0f0c29), const Color(0xFF1a1a3e), const Color(0xFF302b63)];
    }

    if (isSunrise) {
      return [const Color(0xFF1a1a2e), const Color(0xFFb5451b), const Color(0xFFe96c5a), const Color(0xFFf7c59f)];
    }

    if (isSunset) {
      return [const Color(0xFF2c1654), const Color(0xFF614385), const Color(0xFFc84b31), const Color(0xFFf7971e)];
    }

    // Daytime
    if (cond.contains('clear')) {
      return [const Color(0xFF0d47a1), const Color(0xFF1565c0), const Color(0xFF1e88e5), const Color(0xFF42a5f5)];
    }
    if (cond.contains('cloud')) {
      return [const Color(0xFF2c3e50), const Color(0xFF37474f), const Color(0xFF546e7a), const Color(0xFF78909c)];
    }
    if (cond.contains('rain') || cond.contains('drizzle')) {
      return [const Color(0xFF1c2331), const Color(0xFF2c3e50), const Color(0xFF34495e), const Color(0xFF415a77)];
    }
    if (cond.contains('thunder') || cond.contains('storm')) {
      return [const Color(0xFF1a0a2e), const Color(0xFF2d1b69), const Color(0xFF3d2b79), const Color(0xFF4a3090)];
    }
    if (cond.contains('snow')) {
      return [const Color(0xFF3a6186), const Color(0xFF4a7ab5), const Color(0xFF7fb3d3), const Color(0xFFb8d4e8)];
    }
    if (cond.contains('mist') || cond.contains('fog') || cond.contains('haze') || cond.contains('smoke')) {
      return [const Color(0xFF374151), const Color(0xFF4a5568), const Color(0xFF718096), const Color(0xFF90a0b7)];
    }

    return [const Color(0xFF0d47a1), const Color(0xFF1565c0), const Color(0xFF1e88e5), const Color(0xFF42a5f5)];
  }

  static String windDirection(int? deg) {
    if (deg == null) return '';
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }

  static String uvLabel(double uvi) {
    if (uvi <= 2) return 'Low';
    if (uvi <= 5) return 'Moderate';
    if (uvi <= 7) return 'High';
    if (uvi <= 10) return 'Very High';
    return 'Extreme';
  }

  static Color uvColor(double uvi) {
    if (uvi <= 2) return const Color(0xFF4CAF50);
    if (uvi <= 5) return const Color(0xFFFFC107);
    if (uvi <= 7) return const Color(0xFFFF9800);
    if (uvi <= 10) return const Color(0xFFF44336);
    return const Color(0xFF9C27B0);
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.opacity = 0.15,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: br,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          borderRadius: br,
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: child,
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _apiKey = '780d36db197b4fd3ad214843105937f3';
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  Future<Weather?> _fetchWeather() async {
    final service = WeatherService(_apiKey);
    try {
      final position = await service.getCurrentLocation();
      return await service.getWeatherFromCoordinates(
          position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
        parent: _anim, curve: const Interval(0, 0.5, curve: Curves.easeIn));

    final loadFuture = _fetchWeather();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2400), () async {
        if (!mounted) return;
        final weather = await loadFuture;
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(weather: weather)),
        );
      });
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f0c29), Color(0xFF1a1a3e), Color(0xFF302b63)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: const _WeatherOrb(),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fade,
                child: const Text(
                  'WeatherSphere',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fade,
                child: Text(
                  'Your forecast, beautifully.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeTransition(
                opacity: _fade,
                child: SizedBox(
                  width: 120,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherOrb extends StatefulWidget {
  const _WeatherOrb();

  @override
  State<_WeatherOrb> createState() => _WeatherOrbState();
}

class _WeatherOrbState extends State<_WeatherOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final glow = 0.15 + _pulse.value * 0.1;
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF5B8DEF).withValues(alpha: 0.9),
                const Color(0xFF302b63).withValues(alpha: 0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B8DEF).withValues(alpha: glow),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _OrbPainter(_pulse.value),
            child: const Center(
              child: Icon(Icons.wb_sunny_rounded,
                  size: 60, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      final r = (size.width / 2 - 8) - i * 14.0;
      final offset = sin(t * pi * 2 + i * pi / 3) * 2;
      canvas.drawCircle(Offset(cx, cy), r + offset, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

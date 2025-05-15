// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<Weather?> _loadWeather;

  Future<Weather?> _fetchWeather() async {
    final service = WeatherService("780d36db197b4fd3ad214843105937f3");
    try {
      final position = await service.getCurrentLocation();
      return await service.getWeatherFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWeather = _fetchWeather();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _loadWeather.then((weather) {
          if (weather != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(weather: weather),
              ),
            );
          }
        }).catchError((e) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 250,
              width: 250,
              child: RiveAnimation.asset('assets/rive/weather_icon.riv'),
            ),
            const SizedBox(height: 10),
            const Text(
              'WeatherSphere',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bringing you the forecast... With Ease!',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Use LatLng from google_maps_flutter
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/full_screen_map.dart';
import 'package:weather_app/screens/search_page.dart';
import 'package:weather_app/screens/settings_page.dart';
import 'package:weather_app/screens/splash_screen.dart';
import 'package:weather_app/services/weather_api.dart';
import 'widgets/current_weather.dart';
import 'widgets/hourly_forecast.dart';
import 'widgets/daily_forecast.dart';
import 'widgets/air_quality.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WeatherSphere',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.weather});
  final Weather? weather;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late bool isCelsius = true;
  Weather? _weather;
  bool _isLoading = true;
  String? _error;
  LatLng? _lastKnownLocation;
  String? _lastKnownCityName;

  @override
  void initState() {
    super.initState();
    if (widget.weather != null) {
      _weather = widget.weather;
      _isLoading = false;
      _fetchLastKnownLocation();
    } else {
      _fetchWeatherAndLocation();
    }
  }

  Future<void> _fetchLastKnownLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _lastKnownLocation = LatLng(position.latitude, position.longitude);
        // Use the cityName from the Weather model if available
        _lastKnownCityName = _weather?.cityName ?? "Last Known Location";
      } else {
        _lastKnownLocation = const LatLng(21.5434, 39.1729); // Default Jeddah
        _lastKnownCityName = "Jeddah";
      }
    } catch (e) {
      print("Error getting last known location: $e");
      _lastKnownLocation = const LatLng(21.5434, 39.1729); // Default Jeddah
      _lastKnownCityName = "Jeddah";
    }
  }

  Future<void> _fetchWeatherAndLocation() async {
    final service = WeatherService(
      "780d36db197b4fd3ad214843105937f3",
    ); // Replace with your actual API key
    try {
      final position = await service.getCurrentLocation();
      final weather = await service.getWeatherFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _weather = weather;
        _isLoading = false;
        _error = null;
        _lastKnownLocation = LatLng(position.latitude, position.longitude);
        _lastKnownCityName = weather.cityName;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
        _lastKnownLocation = const LatLng(21.5434, 39.1729); // Default Jeddah
        _lastKnownCityName = "Jeddah";
      });
    } finally {
      if (_lastKnownLocation == null) {
        _lastKnownLocation = const LatLng(21.5434, 39.1729); // Default Jeddah
        _lastKnownCityName = "Jeddah";
      }
    }
  }

  void toggleTempUnit() {
    setState(() {
      isCelsius = !isCelsius;
    });
  }

  Widget _buildWeatherContent() {
    return RefreshIndicator(
      onRefresh: _fetchWeatherAndLocation,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurrentWeather(weather: _weather!, isCelsius: isCelsius),
            const SizedBox(height: 25),
            const Text(
              'Hourly Forecast',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            HourlyForecastWidget(
              hourly: _weather?.hourly ?? [],
              isCelsius: isCelsius,
              hourlyForecasts: null,
            ),
            const SizedBox(height: 25),
            const Text(
              '7-Day Forecast',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DailyForecastWidget(
              forecast: _weather?.daily ?? [],
              isCelsius: isCelsius,
            ),
            const SizedBox(height: 25),
            const Text(
              'Air Quality',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AirQualityWidget(
              aqi: _weather?.airQuality?.aqi ?? 75,
              pm25: _weather?.airQuality?.pm25 ?? 12.5,
              pm10: _weather?.airQuality?.pm10 ?? 25.0,
              ozone: _weather?.airQuality?.ozone ?? 45.0,
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.center,
              child: Text(
                '© 2025 WeatherSphere. Made with ❤️ for Weather Enthusiasts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Error loading weather: $_error",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchWeatherAndLocation,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorContent()
          : _buildWeatherContent(),
      const SettingPage(),
      const SearchPage(),
    ];

    return Scaffold(
      appBar:
          _currentIndex == 0
              ? AppBar(
                backgroundColor: Colors.teal,
                elevation: 0,
                title: Row(
                  children: [
                    const Icon(
                      Icons.cloud_circle_rounded,
                      size: 35,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'WeatherSphere',
                      style: TextStyle(
                        fontSize: 19.7,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: toggleTempUnit,
                    icon: Icon(
                      isCelsius ? Icons.toggle_on : Icons.toggle_off,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
              : null,
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Map tab
            LatLng defaultLocation = const LatLng(21.5434, 39.1729);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => FullScreenMap(
                      initialLocation: _lastKnownLocation ?? defaultLocation,
                      cityName: _lastKnownCityName ?? "Current Location",
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                    ),
              ),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: 'Home',
            activeIcon: IconButton(
              onPressed: () => setState(() => _currentIndex = 0),
              icon: const Icon(Icons.home_rounded, color: Colors.teal),
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_rounded),
            label: 'Map',
            activeIcon: IconButton(
              onPressed: () async {
                LatLng defaultLocation = const LatLng(21.5434, 39.1729);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FullScreenMap(
                          initialLocation:
                              _lastKnownLocation ?? defaultLocation,
                          cityName: _lastKnownCityName ?? "Current Location",
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                        ),
                  ),
                );
              },
              icon: const Icon(Icons.map_rounded, color: Colors.teal),
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_rounded),
            label: 'Search',
            activeIcon: IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            const SearchPage(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                  ),
                );
                if (result is Weather) {
                  setState(() {
                    _weather = result;
                  });
                }
              },
              icon: const Icon(Icons.search_rounded, color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/full_screen_map.dart';
import 'package:weather_app/screens/search_page.dart';
import 'package:weather_app/screens/settings_page.dart';
import 'package:weather_app/screens/splash_screen.dart';
import 'package:weather_app/services/weather_api.dart';
import 'package:weather_app/utils/weather_theme.dart';
import 'widgets/air_quality.dart';
import 'widgets/current_weather.dart';
import 'widgets/daily_forecast.dart';
import 'widgets/hourly_forecast.dart';
import 'widgets/sunrise_sunset.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565c0)),
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
  static const _apiKey = '780d36db197b4fd3ad214843105937f3';

  bool isCelsius = true;
  Weather? _weather;
  bool _isLoading = true;
  String? _error;
  LatLng? _lastKnownLocation;
  String? _lastKnownCityName;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));
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
      final position = await Geolocator.getLastKnownPosition();
      if (mounted) {
        setState(() {
          _lastKnownLocation = position != null
              ? LatLng(position.latitude, position.longitude)
              : const LatLng(21.5434, 39.1729);
          _lastKnownCityName = _weather?.cityName ?? 'Jeddah';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _lastKnownLocation = const LatLng(21.5434, 39.1729);
          _lastKnownCityName = 'Jeddah';
        });
      }
    }
  }

  Future<void> _fetchWeatherAndLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = WeatherService(_apiKey);
      final position = await service.getCurrentLocation();
      final weather = await service.getWeatherFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoading = false;
          _lastKnownLocation = LatLng(position.latitude, position.longitude);
          _lastKnownCityName = weather.cityName;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
          _lastKnownLocation ??= const LatLng(21.5434, 39.1729);
          _lastKnownCityName ??= 'Jeddah';
        });
      }
    }
  }

  List<Color> get _gradient {
    if (_weather == null) {
      return [const Color(0xFF0f0c29), const Color(0xFF302b63)];
    }
    return WeatherTheme.getGradient(_weather!.mainCondition, DateTime.now());
  }

  void _openMap() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => FullScreenMap(
          initialLocation: _lastKnownLocation ?? const LatLng(21.5434, 39.1729),
          cityName: _lastKnownCityName ?? 'Current Location',
          transitionsBuilder: (_, animation, __, child) {
            final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }

  Future<void> _openSearch() async {
    final result = await Navigator.push<Weather>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const SearchPage(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _weather = result;
        _lastKnownCityName = result.cityName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? _buildLoading()
              : _error != null
                  ? _buildError()
                  : _buildContent(bottomPad),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(bottomPad),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Getting your weather...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 72, color: Colors.white54),
            const SizedBox(height: 24),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _fetchWeatherAndLocation,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1565c0),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double bottomPad) {
    final w = _weather!;
    return RefreshIndicator(
      onRefresh: _fetchWeatherAndLocation,
      color: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.15),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _buildTopBar(w),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 90),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CurrentWeather(weather: w, isCelsius: isCelsius),
                const SizedBox(height: 16),
                if (w.sunrise != null && w.sunset != null) ...[
                  SunriseSunsetWidget(sunrise: w.sunrise!, sunset: w.sunset!),
                  const SizedBox(height: 16),
                ],
                _buildSectionLabel('Hourly Forecast'),
                const SizedBox(height: 10),
                HourlyForecastWidget(hourly: w.hourly, isCelsius: isCelsius),
                const SizedBox(height: 16),
                _buildSectionLabel('7-Day Forecast'),
                const SizedBox(height: 10),
                DailyForecastWidget(forecast: w.daily, isCelsius: isCelsius),
                if (w.airQuality != null) ...[
                  const SizedBox(height: 16),
                  _buildSectionLabel('Air Quality'),
                  const SizedBox(height: 10),
                  AirQualityWidget(
                    aqi: w.airQuality!.aqi,
                    pm25: w.airQuality!.pm25,
                    pm10: w.airQuality!.pm10,
                    ozone: w.airQuality!.ozone,
                  ),
                ],
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    '© 2026 WeatherSphere',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Weather w) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      w.cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                _greeting(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        _topBarBtn(
          isCelsius ? '°C' : '°F',
          null,
          () => setState(() => isCelsius = !isCelsius),
          isText: true,
        ),
        const SizedBox(width: 8),
        _topBarBtn(null, Icons.settings_rounded, () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 350),
              reverseTransitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => const SettingPage(),
              transitionsBuilder: (_, animation, __, child) {
                final slide = Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ));
                return SlideTransition(position: slide, child: child);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _topBarBtn(String? label, IconData? icon, VoidCallback onTap,
      {bool isText = false}) {
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.18,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: isText
              ? Text(label!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15))
              : Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildBottomNav(double bottomPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad + 12),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.50),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_rounded, 'Home', null),
            _navItem(Icons.map_rounded, 'Map', _openMap),
            _navItem(Icons.search_rounded, 'Search', _openSearch),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback? onTap) {
    final isHome = label == 'Home';
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isHome
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.55),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isHome
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight:
                    isHome ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    if (hour < 20) return 'Good evening!';
    return 'Good night!';
  }
}

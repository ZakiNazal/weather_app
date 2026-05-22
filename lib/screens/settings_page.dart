import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _autoLocation = true;
  String _defaultCity = 'Jeddah';
  bool _showWindSpeed = true;
  bool _showAirQuality = false;
  bool _onCellularData = true;
  String _temperatureUnit = 'Celsius';
  String _windSpeedUnit = 'km/h';
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  ThemeMode _themeMode = ThemeMode.system;

  final _cities = ['Jeddah', 'Riyadh', 'Dubai', 'London', 'Tokyo'];
  final _tempUnits = ['Celsius', 'Fahrenheit'];
  final _windUnits = ['km/h', 'm/s', 'mph'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _autoLocation = p.getBool('autoLocation') ?? true;
      _defaultCity = p.getString('defaultCity') ?? 'Jeddah';
      _showWindSpeed = p.getBool('showWindSpeed') ?? true;
      _showAirQuality = p.getBool('showAirQuality') ?? false;
      _onCellularData = p.getBool('onCellularData') ?? true;
      _temperatureUnit = p.getString('temperatureUnit') ?? 'Celsius';
      _windSpeedUnit = p.getString('windSpeedUnit') ?? 'km/h';
      _notificationsEnabled = p.getBool('notificationsEnabled') ?? true;
      final t = p.getString('notificationTime');
      if (t != null) {
        final parts = t.split(':');
        _notificationTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      final tm = p.getString('themeMode');
      _themeMode = tm == 'light'
          ? ThemeMode.light
          : tm == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('autoLocation', _autoLocation);
    await p.setString('defaultCity', _defaultCity);
    await p.setBool('showWindSpeed', _showWindSpeed);
    await p.setBool('showAirQuality', _showAirQuality);
    await p.setBool('onCellularData', _onCellularData);
    await p.setString('temperatureUnit', _temperatureUnit);
    await p.setString('windSpeedUnit', _windSpeedUnit);
    await p.setBool('notificationsEnabled', _notificationsEnabled);
    await p.setString(
        'notificationTime', '${_notificationTime.hour}:${_notificationTime.minute}');
    await p.setString('themeMode', _themeMode.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: const Text('Settings',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _section('Location', Icons.location_on_rounded, [
            _switchRow(
              'Use Current Location',
              'Auto-detect city via GPS',
              _autoLocation,
              (v) => setState(() {
                _autoLocation = v;
                _save();
              }),
            ),
            if (!_autoLocation)
              _dropdownRow<String>(
                'Default City',
                'Fallback when GPS is off',
                _defaultCity,
                _cities,
                (v) => setState(() {
                  _defaultCity = v!;
                  _save();
                }),
              ),
          ]),
          _section('Display', Icons.tune_rounded, [
            _dropdownRow<String>(
              'Temperature Unit',
              'Celsius or Fahrenheit',
              _temperatureUnit,
              _tempUnits,
              (v) => setState(() {
                _temperatureUnit = v!;
                _save();
              }),
            ),
            _dropdownRow<String>(
              'Wind Speed Unit',
              'Unit for wind speed display',
              _windSpeedUnit,
              _windUnits,
              (v) => setState(() {
                _windSpeedUnit = v!;
                _save();
              }),
            ),
            _switchRow(
              'Show Wind Speed',
              'Display wind in forecast',
              _showWindSpeed,
              (v) => setState(() {
                _showWindSpeed = v;
                _save();
              }),
            ),
            _switchRow(
              'Show Air Quality',
              'Display AQI section',
              _showAirQuality,
              (v) => setState(() {
                _showAirQuality = v;
                _save();
              }),
            ),
          ]),
          _section('Notifications', Icons.notifications_rounded, [
            _switchRow(
              'Daily Weather Alert',
              'Morning forecast notification',
              _notificationsEnabled,
              (v) => setState(() {
                _notificationsEnabled = v;
                _save();
              }),
            ),
            if (_notificationsEnabled)
              _tapRow(
                'Notification Time',
                _notificationTime.format(context),
                () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _notificationTime,
                    builder: (ctx, child) => Theme(
                      data: ThemeData.dark(),
                      child: child!,
                    ),
                  );
                  if (picked != null && mounted) {
                    setState(() => _notificationTime = picked);
                    _save();
                  }
                },
              ),
          ]),
          _section('Appearance', Icons.palette_rounded, [
            _dropdownRow<ThemeMode>(
              'App Theme',
              'System, Light, or Dark',
              _themeMode,
              [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
              (v) => setState(() {
                _themeMode = v!;
                _save();
              }),
              labelOf: (m) => m.name[0].toUpperCase() + m.name.substring(1),
            ),
          ]),
          _section('Data', Icons.cloud_sync_rounded, [
            _switchRow(
              'Use Cellular Data',
              'Allow updates over mobile network',
              _onCellularData,
              (v) => setState(() {
                _onCellularData = v;
                _save();
              }),
            ),
            _infoRow('Update Frequency', 'Every 30 minutes'),
          ]),
          _section('About', Icons.info_outline_rounded, [
            _infoRow('Version', 'WeatherSphere v1.0.0'),
            _tapRow('Privacy Policy', '', () {}),
            _tapRow('Contact Us', '', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 0, 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text(title.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(rows.length, (i) {
              return Column(
                children: [
                  rows[i],
                  if (i < rows.length - 1)
                    Divider(
                      height: 0,
                      indent: 16,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(
      String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                Text(sub,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF3B82F6),
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _dropdownRow<T>(String title, String sub, T value, List<T> items,
      ValueChanged<T?> onChanged,
      {String Function(T)? labelOf}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                Text(sub,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          DropdownButton<T>(
            value: value,
            dropdownColor: const Color(0xFF1F2937),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            underline: const SizedBox(),
            icon: const Icon(Icons.expand_more_rounded,
                color: Colors.white38, size: 18),
            items: items
                .map((e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(labelOf != null ? labelOf(e) : e.toString()),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _tapRow(String title, String value, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
            if (value.isNotEmpty)
              Text(value,
                  style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            if (value.isEmpty)
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
          Text(value,
              style: const TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }
}

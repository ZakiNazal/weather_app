// settings_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // ⚙️ Settings Values
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

  final List<String> _cities = ['Jeddah', 'Riyadh', 'Dubai', 'London', 'Tokyo'];
  final List<String> _tempUnits = ['Celsius', 'Fahrenheit'];
  final List<String> _windUnits = ['km/h', 'm/s', 'mph'];
  final List<ThemeMode> _themeModes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 💾 Load Settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoLocation = prefs.getBool('autoLocation') ?? true;
      _defaultCity = prefs.getString('defaultCity') ?? 'Jeddah';
      _showWindSpeed = prefs.getBool('showWindSpeed') ?? true;
      _showAirQuality = prefs.getBool('showAirQuality') ?? false;
      _onCellularData = prefs.getBool('onCellularData') ?? true;
      _temperatureUnit = prefs.getString('temperatureUnit') ?? 'Celsius';
      _windSpeedUnit = prefs.getString('windSpeedUnit') ?? 'km/h';
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      final timeString = prefs.getString('notificationTime');
      if (timeString != null) {
        final parts = timeString.split(':');
        _notificationTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      final themeString = prefs.getString('themeMode');
      _themeMode = themeString == 'light'
          ? ThemeMode.light
          : themeString == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system;
    });
  }

  // 💾 Save Settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLocation', _autoLocation);
    await prefs.setString('defaultCity', _defaultCity);
    await prefs.setBool('showWindSpeed', _showWindSpeed);
    await prefs.setBool('showAirQuality', _showAirQuality);
    await prefs.setBool('onCellularData', _onCellularData);
    await prefs.setString('temperatureUnit', _temperatureUnit);
    await prefs.setString('windSpeedUnit', _windSpeedUnit);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString(
      'notificationTime',
      '${_notificationTime.hour}:${_notificationTime.minute}',
    );
    await prefs.setString('themeMode', _themeMode.name);
    //  Notify the app to rebuild with the new theme
    if (mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  // 🔄 Update Functions
  void _toggleAutoLocation(bool value) {
    setState(() => _autoLocation = value);
    _saveSettings();
  }

  void _updateDefaultCity(String? value) {
    if (value != null) setState(() => _defaultCity = value);
    _saveSettings();
  }

  void _toggleWindSpeed(bool value) {
    setState(() => _showWindSpeed = value);
    _saveSettings();
  }

  void _toggleAirQuality(bool value) {
    setState(() => _showAirQuality = value);
    _saveSettings();
  }

  void _toggleCellularData(bool value) {
    setState(() => _onCellularData = value);
    _saveSettings();
  }

  void _updateTemperatureUnit(String? value) {
    if (value != null) setState(() => _temperatureUnit = value);
    _saveSettings();
  }

  void _updateWindSpeedUnit(String? value) {
    if (value != null) setState(() => _windSpeedUnit = value);
    _saveSettings();
  }

  void _toggleNotifications(bool value) {
    setState(() => _notificationsEnabled = value);
    _saveSettings();
  }

  Future<void> _selectNotificationTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null && picked != _notificationTime) {
      setState(() => _notificationTime = picked);
      _saveSettings();
    }
  }

  void _updateThemeMode(ThemeMode? value) {
    if (value != null) setState(() => _themeMode = value);
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'Location',
            children: [
              _buildSettingRow(
                title: 'Use Current Location',
                subtitle: 'Automatically detect your city based on GPS',
                trailing: Switch(
                  value: _autoLocation,
                  onChanged: _toggleAutoLocation,
                  activeColor: Colors.teal,
                ),
              ),
              if (!_autoLocation)
                _buildSettingRow(
                  title: 'Default City',
                  subtitle: 'Choose city for manual weather updates',
                  trailing: DropdownButton<String>(
                    value: _defaultCity,
                    onChanged: _updateDefaultCity,
                    items: _cities
                        .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ))
                        .toList(),
                    underline: Container(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'Display Preferences',
            children: [
              _buildSettingRow(
                title: 'Temperature Unit',
                subtitle: 'Set the preferred unit for temperature display',
                trailing: DropdownButton<String>(
                  value: _temperatureUnit,
                  onChanged: _updateTemperatureUnit,
                  items: _tempUnits
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  underline: Container(),
                ),
              ),
              _buildSettingRow(
                title: 'Wind Speed Unit',
                subtitle: 'Set the preferred unit for wind speed display',
                trailing: DropdownButton<String>(
                  value: _windSpeedUnit,
                  onChanged: _updateWindSpeedUnit,
                  items: _windUnits
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  underline: Container(),
                ),
              ),
              _buildSettingRow(
                title: 'Show Wind Speed',
                subtitle: 'Display wind speed in forecast details',
                trailing: Switch(
                  value: _showWindSpeed,
                  onChanged: _toggleWindSpeed,
                  activeColor: Colors.teal,
                ),
              ),
              _buildSettingRow(
                title: 'Show Air Quality',
                subtitle: 'Display AQI and pollutant information',
                trailing: Switch(
                  value: _showAirQuality,
                  onChanged: _toggleAirQuality,
                  activeColor: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'Notifications',
            children: [
              _buildSettingRow(
                title: 'Daily Weather Notifications',
                subtitle:
                    'Receive a daily weather forecast at a specific time',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: Colors.teal,
                ),
              ),
              if (_notificationsEnabled)
                _buildSettingRow(
                  title: 'Notification Time',
                  subtitle: 'Set the time for your daily weather update',
                  trailing: InkWell(
                    onTap: () => _selectNotificationTime(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _notificationTime.format(context),
                        style: const TextStyle(fontSize: 16, color: Colors.teal),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'App Theme',
            children: [
              _buildSettingRow(
                title: 'Theme Mode',
                subtitle: 'Choose the appearance of the app',
                trailing: DropdownButton<ThemeMode>(
                  value: _themeMode,
                  onChanged: _updateThemeMode,
                  items: _themeModes
                      .map((mode) => DropdownMenuItem(
                            value: mode,
                            child: Text(mode.toString().split('.').last),
                          ))
                      .toList(),
                  underline: Container(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'Data Usage',
            children: [
              _buildSettingRow(
                title: 'Use Cellular Data',
                subtitle: 'Allow data usage over mobile network',
                trailing: Switch(
                  value: _onCellularData,
                  onChanged: _toggleCellularData,
                  activeColor: Colors.teal,
                ),
              ),
              _buildSettingRow(
                title: 'Forecast Update Frequency',
                subtitle: 'How often the app refreshes weather data',
                trailing: const Text(
                  "Every 30 minutes",
                  style: TextStyle(color: Colors.grey),
                ),
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'About',
            children: [
              _buildAboutItem(
                  title: 'App Version', value: 'WeatherSphere v1.0.0'),
              _buildAboutItem(
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Implement link to privacy policy
                },
              ),
              _buildAboutItem(
                title: 'Contact Us',
                onTap: () {
                  // TODO: Implement contact us action
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required String title,
    String? subtitle,
    required Widget trailing,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      color: enabled ? Colors.black87 : Colors.grey),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                          color: enabled ? Colors.grey[600] : Colors.grey[400],
                          fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          Opacity(opacity: enabled ? 1.0 : 0.6, child: trailing),
        ],
      ),
    );
  }

  Widget _buildAboutItem({
    required String title,
    String? value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle:
          value != null ? Text(value, style: const TextStyle(color: Colors.grey)) : null,
      onTap: onTap,
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey)
          : null,
    );
  }
}
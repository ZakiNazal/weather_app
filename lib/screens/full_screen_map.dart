// full_screen_map.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class FullScreenMap extends StatefulWidget {
  final LatLng initialLocation;
  final String cityName;
  final SlideTransition Function(
    dynamic context,
    dynamic animation,
    dynamic secondaryAnimation,
    dynamic child,
  ) transitionsBuilder;

  const FullScreenMap({
    super.key,
    required this.initialLocation,
    required this.cityName,
    required this.transitionsBuilder,
  });

  @override
  _FullScreenMapState createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  GoogleMapController? _controller;
  LatLng? _currentLocation;
  String? _currentCityName;
  bool _isMapReady = false;
  MapType _mapType = MapType.normal;

  bool get _isSatellite => _mapType == MapType.satellite;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    _currentCityName = widget.cityName;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!mounted) return;
    setState(() {
      _controller = controller;
      _isMapReady = true;
    });
    if (_currentLocation != null) {
      _controller!.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    }
  }

  void _zoomIn() {
    if (mounted && _isMapReady && _controller != null) {
      _controller!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() {
    if (mounted && _isMapReady && _controller != null) {
      _controller!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _isSatellite ? MapType.normal : MapType.satellite;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        if (_isMapReady && _controller != null) {
          _controller!.animateCamera(
              CameraUpdate.newLatLng(_currentLocation!));
        }
      }
    } catch (e) {
      print("Error getting location: $e");
      if (mounted) {
        setState(() {
          _currentLocation = const LatLng(21.5434, 39.1729);
        });
        if (_isMapReady && _controller != null) {
          _controller!.animateCamera(
              CameraUpdate.newLatLng(_currentLocation!));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        // No BackdropFilter — gradient scrim is enough and costs nothing
        flexibleSpace: _GradientScrim(),
        title: Text(
          _currentCityName ?? widget.cityName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
          ),
        ),
        leading: _SolidIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          isSatellite: _isSatellite,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 12,
                  ),
                  myLocationEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  mapType: _mapType,
                  markers: {
                    Marker(
                      markerId: const MarkerId("userLocation"),
                      position: _currentLocation!,
                      infoWindow: InfoWindow(
                        title: _currentCityName ?? widget.cityName,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  },
                ),
                // RepaintBoundary isolates the panel's repaints from the map
                Positioned(
                  right: 16,
                  bottom: 40,
                  child: RepaintBoundary(
                    child: _ControlPanel(
                      isMapReady: _isMapReady,
                      isSatellite: _isSatellite,
                      onLocate: _getCurrentLocation,
                      onZoomIn: _zoomIn,
                      onZoomOut: _zoomOut,
                      onToggleMapType: _toggleMapType,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _GradientScrim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.65),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  final bool isMapReady;
  final bool isSatellite;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleMapType;
  final Future<void> Function() onLocate;

  const _ControlPanel({
    required this.isMapReady,
    required this.isSatellite,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleMapType,
    required this.onLocate,
  });

  @override
  Widget build(BuildContext context) {
    // Dark on normal map (light tiles), slightly lighter on satellite (dark tiles)
    final bgColor = isSatellite
        ? Colors.black.withValues(alpha: 0.50)
        : Colors.black.withValues(alpha: 0.72);
    final borderColor = isSatellite
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PanelButton(
            icon: Icons.my_location_rounded,
            enabled: isMapReady,
            onTap: isMapReady ? onLocate : null,
          ),
          const SizedBox(height: 6),
          _PanelButton(
            icon: Icons.add_rounded,
            enabled: isMapReady,
            onTap: isMapReady ? onZoomIn : null,
          ),
          const SizedBox(height: 6),
          _PanelButton(
            icon: Icons.remove_rounded,
            enabled: isMapReady,
            onTap: isMapReady ? onZoomOut : null,
          ),
          const SizedBox(height: 6),
          _PanelButton(
            icon: isSatellite
                ? Icons.map_rounded
                : Icons.satellite_alt_rounded,
            enabled: isMapReady,
            onTap: isMapReady ? onToggleMapType : null,
          ),
        ],
      ),
    );
  }
}

class _PanelButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _PanelButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.12 : 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: enabled ? 0.25 : 0.08),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.3),
          size: 20,
        ),
      ),
    );
  }
}

class _SolidIconButton extends StatelessWidget {
  final IconData icon;
  final bool isSatellite;
  final VoidCallback onTap;

  const _SolidIconButton({
    required this.icon,
    required this.isSatellite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

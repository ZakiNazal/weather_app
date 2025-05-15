// full_screen_map.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    _currentCityName = widget.cityName;
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!mounted) return; // Check if the widget is still in the tree
    setState(() {
      _controller = controller;
      _isMapReady = true;
    });
    if (_currentLocation != null) {
      _controller!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!));
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
      print("Location permissions are permanently denied, we cannot request them.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) { // Check if the widget is still in the tree
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
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _currentLocation = LatLng(21.5434, 39.1729); // Jeddah fallback
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
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: Text(
          _currentCityName ?? widget.cityName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              alignment: Alignment.bottomRight,
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
                  mapType: MapType.normal,
                  markers: {
                    Marker(
                      markerId: const MarkerId("userLocation"),
                      position: _currentLocation!,
                      infoWindow:
                          InfoWindow(title: _currentCityName ?? widget.cityName),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: null,
                        backgroundColor: Colors.teal,
                        mini: true,
                        onPressed: _isMapReady ? _getCurrentLocation : null,
                        child: const Icon(Icons.my_location_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: null,
                        backgroundColor: Colors.teal,
                        mini: true,
                        onPressed: _isMapReady ? _zoomIn : null,
                        child:
                            const Icon(Icons.add_rounded, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: null,
                        backgroundColor: Colors.teal,
                        mini: true,
                        onPressed: _isMapReady ? _zoomOut : null,
                        child:
                            const Icon(Icons.remove_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
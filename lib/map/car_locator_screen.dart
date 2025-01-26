import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_service.dart';
import 'marker_service.dart';
import 'car_details_dialog.dart';

class CarLocatorScreen extends StatefulWidget {
  const CarLocatorScreen({super.key});

  @override
  State<CarLocatorScreen> createState() => _CarLocatorScreenState();
}

class _CarLocatorScreenState extends State<CarLocatorScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // Initial camera position for the map centered on Kigali
  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-1.9403, 30.0601),
    zoom: 14.4746,
  );

  final LocationService _locationService = LocationService();
  final MarkerService _markerService = MarkerService();
  LatLng? _userLocation;
  BitmapDescriptor? _userIcon;

  // Car locations categorized by district
  final Map<String, List<LatLng>> _carsByDistrict = {
    'Musanze': [
      LatLng(-1.4992, 29.6358),
      LatLng(-1.5012, 29.6382),
      LatLng(-1.5025, 29.6330),
      LatLng(-1.5038, 29.6375),
      LatLng(-1.5049, 29.6312),
    ],
    'Kigali': [
      LatLng(-1.9500, 30.0605),
      LatLng(-1.9485, 30.0590),
      LatLng(-1.9493, 30.0582),
      LatLng(-1.9512, 30.0610),
      LatLng(-1.9521, 30.0575),
    ],
    'Huye': [
      LatLng(-2.6078, 29.7394),
      LatLng(-2.6065, 29.7358),
      LatLng(-2.6090, 29.7332),
      LatLng(-2.6082, 29.7371),
      LatLng(-2.6105, 29.7325),
    ],
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addNearbyCarMarkers(); // Add car markers after map is created
      _loadUserIcon(); // Load user location icon
      _getCurrentLocation(); // Get user location
    });
  }

  Future<void> _loadUserIcon() async {
    _userIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/images/user_icon.png');
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission before accessing the location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied. Please allow access.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        return;
      }

      // Get current user location from location service
      _userLocation = await _locationService.getCurrentLocation();

      if (_userLocation != null && _userIcon != null) {
        setState(() {
          // Add user location marker
          _markerService.addCustomMarker(
            _userLocation!,
            'Your Location',
            _showCarDetails,
            icon: _userIcon,
          );
        });

        // Animate camera to the new location
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _userLocation!,
              zoom: 14.4746,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _addNearbyCarMarkers() {
    _carsByDistrict.forEach((district, carLocations) {
      for (var car in carLocations) {
        _markerService.addCustomMarker(car, 'Car in $district', _showCarDetails,
            icon: _userIcon); // Pass the icon
      }
    });
    setState(() {});
  }

  void _showCarDetails(LatLng position) {
    CarDetailsDialog.showCarDetails(
      context,
      position,
      CarDetailsDialog.shareCarDetails,
      userLocation: _userLocation, // Pass user location
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal, // Set map type to terrain
        initialCameraPosition: _initialPosition, // Set initial camera position
        myLocationEnabled: true, // Show user's location on map
        myLocationButtonEnabled: true, // Enable my location button
        compassEnabled: true, // Enable compass for orientation
        zoomControlsEnabled: true, // Enable zoom buttons
        markers: _markerService.markers, // Add markers to map
        polylines: _markerService.polylines, // Add polylines to map
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }
        },
        mapToolbarEnabled: true, // Enable map toolbar
        onTap: (LatLng position) {
          _markerService.addCustomMarker(
              position, 'New Marker', _showCarDetails,
              icon: _userIcon); // Add icon for new marker
          setState(() {});
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation, // Get current location on click
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

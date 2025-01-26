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
    zoom: 14.5,
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        _loadUserIcon(),
        _getCurrentLocation(),
      ]);
      _addNearbyCarMarkers();
    });
  }

  Future<void> _loadUserIcon() async {
    try {
      _userIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/user_icon.png',
      );
    } catch (e) {
      print('Error loading user icon: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
          return;
        }
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        print('Location services are disabled. Please enable them.');
        return;
      }

      _userLocation = await _locationService.getCurrentLocation();

      if (_userLocation != null && _userIcon != null) {
        setState(() {
          _markerService.addCustomMarker(
            _userLocation!,
            'Your Location',
            _showCarDetails,
            icon: _userIcon!,
          );
        });

        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _userLocation!, zoom: 14.5),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _addNearbyCarMarkers() {
    setState(() {
      _carsByDistrict.forEach((district, carLocations) {
        for (var car in carLocations) {
          _markerService.addCustomMarker(
            car,
            'Car in $district',
            _showCarDetails,
            iconPath: 'assets/images/carIcon.png',
          );
        }
      });
    });
  }

  void _showCarDetails(LatLng position) {
    CarDetailsDialog.showCarDetails(
      context,
      position,
      CarDetailsDialog.shareCarDetails,
      userLocation: _userLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        zoomControlsEnabled: true,
        markers: _markerService.markers,
        polylines: _markerService.polylines,
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }
        },
        mapToolbarEnabled: true,
        onTap: (LatLng position) {
          setState(() {
            _markerService.addCustomMarker(
              position,
              'New Marker',
              _showCarDetails,
              icon: _userIcon,
            );
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

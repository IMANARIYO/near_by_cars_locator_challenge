import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Check if running on emulator
      if (kDebugMode) {
        // Hard-code a specific location for emulator in Rwanda
        // return LatLng(-1.9403, 30.0601);  // Kigali coordinates
        return LatLng(-2.6078, 29.7434); // huye coordinates
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print(': $e');
      return null;
    }
  }
}

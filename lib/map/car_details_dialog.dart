import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CarDetailsDialog {
  static void showCarDetails(
      BuildContext context, LatLng carPosition, Function shareDetails,
      {LatLng? userLocation}) {
    // Calculate distance between user and car if user location is available
    double? distance;
    if (userLocation != null) {
      distance = Geolocator.distanceBetween(
              userLocation.latitude,
              userLocation.longitude,
              carPosition.latitude,
              carPosition.longitude) /
          1000; // Convert to kilometers
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Car Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (distance != null)
                Text('Distance: ${distance.toStringAsFixed(2)} km'),
              Text('Latitude: ${carPosition.latitude.toStringAsFixed(4)}'),
              Text('Longitude: ${carPosition.longitude.toStringAsFixed(4)}'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  shareDetails(carPosition);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static void shareCarDetails(LatLng position) {
    final String carLocation =
        'Car Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    print('Sharing: $carLocation');
  }
}

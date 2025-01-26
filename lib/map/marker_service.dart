import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerService {
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  // Load PNG and resize it
  Future<BitmapDescriptor> _loadCarIcon(
      {int width = 100, int height = 100,
    String iconPath = 'assets/images/user_icon.png',
  }) async {
    // final ByteData data = await rootBundle.load('assets/images/carIcon.png');
    final ByteData data = await rootBundle.load(iconPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Decode the image and resize it
    img.Image? image = img.decodeImage(bytes);
    img.Image resized = img.copyResize(image!, width: width, height: height);

    // Convert back to Uint8List
    final Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resized));

    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  // Function to add a custom marker with a resized icon
  Future<void> addCustomMarker(
    LatLng position,
     String title, 
     Function onTap,
      {BitmapDescriptor? icon,
       int width = 100,
    int height = 100,
    String iconPath = 'assets/images/user_icon.png',
  }) async {
    BitmapDescriptor carIcon = await _loadCarIcon(
      width: width,
      height: height,
      iconPath: iconPath,
    );

    markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        icon: carIcon,
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(
          title: title,
          snippet: '${position.latitude}, ${position.longitude}',
        ),
        onTap: () => onTap(position),
      ),
    );
  }
  // Function to add a polyline (optional for path visualization)
  void addPolyline(List<LatLng> path,
      {Color color = Colors.blue, int width = 5}) {
    polylines.add(
      Polyline(
        polylineId: PolylineId(path.toString()),
        points: path,
        color: color,
        width: width,
      ),
    );
  }
  
}


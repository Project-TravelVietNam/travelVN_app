import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMarker extends Marker {
  LocationMarker({
    required LatLng point,
    required String label,
    required Color markerColor,
    required IconData icon,
  }) : super(
    point: point,
    width: 80,
    height: 80,
    child: Column(
      children: [
        Icon(icon, color: markerColor),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    ),
  );
} 
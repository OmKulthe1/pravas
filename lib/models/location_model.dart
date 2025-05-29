import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  final String address;
  final LatLng coordinates;
  final String? placeId;

  Location({
    required this.address,
    required this.coordinates,
    this.placeId,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] as String,
      coordinates: LatLng(
        json['coordinates']['lat'] as double,
        json['coordinates']['lng'] as double,
      ),
      placeId: json['placeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': {
        'lat': coordinates.latitude,
        'lng': coordinates.longitude,
      },
      'placeId': placeId,
    };
  }
} 
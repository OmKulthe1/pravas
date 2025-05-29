import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_model.dart';

class PlacesService {
  static final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static const String baseUrl = 'https://maps.googleapis.com/maps/api';

  static Future<List<Location>> getPlacePredictions(String input) async {
    if (input.isEmpty) return [];

    final response = await http.get(
      Uri.parse(
        '$baseUrl/place/autocomplete/json?input=$input&key=$apiKey&components=country:in',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        return (data['predictions'] as List).map((prediction) {
          return Location(
            address: prediction['description'],
            coordinates: const LatLng(0, 0), // Will be updated with actual coordinates
            placeId: prediction['place_id'],
          );
        }).toList();
      }
    }
    return [];
  }

  static Future<Location?> getPlaceDetails(String placeId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/place/details/json?place_id=$placeId&fields=geometry,formatted_address&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        return Location(
          address: result['formatted_address'],
          coordinates: LatLng(
            result['geometry']['location']['lat'],
            result['geometry']['location']['lng'],
          ),
          placeId: placeId,
        );
      }
    }
    return null;
  }

  static Future<List<LatLng>> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
        return steps.map((step) {
          final startLocation = step['start_location'];
          return LatLng(
            startLocation['lat'],
            startLocation['lng'],
          );
        }).toList();
      }
    }
    return [];
  }
} 
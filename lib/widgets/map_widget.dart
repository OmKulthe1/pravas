import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_model.dart';
import '../services/places_service.dart';

class MapWidget extends StatefulWidget {
  final Location? pickupLocation;
  final Location? dropLocation;
  final Function(Set<Marker>)? onMarkersUpdated;

  const MapWidget({
    super.key,
    this.pickupLocation,
    this.dropLocation,
    this.onMarkersUpdated,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  static const LatLng _center = LatLng(28.6139, 77.2090); // New Delhi

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickupLocation != widget.pickupLocation ||
        oldWidget.dropLocation != widget.dropLocation) {
      _updateMarkers();
      _updateRoute();
    }
  }

  void _updateMarkers() {
    _markers = {};
    if (widget.pickupLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: widget.pickupLocation!.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: widget.pickupLocation!.address),
        ),
      );
    }
    if (widget.dropLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: widget.dropLocation!.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: widget.dropLocation!.address),
        ),
      );
    }
    widget.onMarkersUpdated?.call(_markers);
  }

  Future<void> _updateRoute() async {
    if (widget.pickupLocation == null || widget.dropLocation == null) {
      setState(() => _polylines = {});
      return;
    }

    final points = await PlacesService.getDirections(
      widget.pickupLocation!.coordinates,
      widget.dropLocation!.coordinates,
    );

    if (points.isNotEmpty) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        };
      });

      // Fit the map to show the entire route
      final bounds = points.fold<LatLngBounds>(
        LatLngBounds(
          southwest: points.first,
          northeast: points.first,
        ),
        (bounds, point) {
          final southwest = LatLng(
            min(bounds.southwest.latitude, point.latitude),
            min(bounds.southwest.longitude, point.longitude),
          );
          final northeast = LatLng(
            max(bounds.northeast.latitude, point.latitude),
            max(bounds.northeast.longitude, point.longitude),
          );
          return LatLngBounds(southwest: southwest, northeast: northeast);
        },
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: const CameraPosition(
        target: _center,
        zoom: 12.0,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
    );
  }
} 
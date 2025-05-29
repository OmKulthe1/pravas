import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/location_model.dart';
import '../services/places_service.dart';

class LocationInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final Function(Location) onLocationSelected;

  const LocationInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.onLocationSelected,
  });

  @override
  State<LocationInputField> createState() => _LocationInputFieldState();
}

class _LocationInputFieldState extends State<LocationInputField> {
  List<Location> _predictions = [];
  bool _isLoading = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    final RenderBox? box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 300;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, (box?.size.height ?? 56) + 6),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _predictions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return ListTile(
                      title: Text(
                        prediction.address,
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                      onTap: () => _onPredictionSelected(prediction),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: const Icon(Icons.location_on, color: Colors.deepPurple, size: 22),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  Future<void> _getPlacePredictions(String input) async {
    if (input.isEmpty) {
      setState(() => _predictions = []);
      _removeOverlay();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final predictions = await PlacesService.getPlacePredictions(input);
      setState(() => _predictions = predictions);
      if (_predictions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (e) {
      setState(() => _predictions = []);
      _removeOverlay();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onPredictionSelected(Location prediction) async {
    final details = await PlacesService.getPlaceDetails(prediction.placeId!);
    if (details != null) {
      HapticFeedback.mediumImpact();
      widget.onLocationSelected(details);
      widget.controller.text = details.address;
      setState(() => _predictions = []);
      _removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        child: TextField(
          key: _fieldKey,
          controller: widget.controller,
          style: GoogleFonts.poppins(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: widget.hintText,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
            prefixIcon: Icon(widget.icon, color: Colors.deepPurple),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() => _predictions = []);
                      _removeOverlay();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: _getPlacePredictions,
        ),
      ),
    );
  }
} 
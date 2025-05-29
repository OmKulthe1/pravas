import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/location_model.dart';
import '../widgets/location_input_field.dart';
import '../widgets/map_widget.dart';

const kPurple = Color(0xFF7B61FF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _pickupDate;
  DateTime? _dropDate;
  final _pickupAddressController = TextEditingController();
  final _dropAddressController = TextEditingController();
  Location? _pickupLocation;
  Location? _dropLocation;
  Set<Marker> _markers = {};

  void _showCupertinoDatePicker({required bool isPickup}) {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final minDate = DateTime(now.year, now.month, now.day);
    final selected = isPickup ? _pickupDate : _dropDate;
    final initial = (selected != null && !selected.isBefore(minDate)) ? selected : minDate;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 320,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: CupertinoDatePicker(
                initialDateTime: initial,
                minimumDate: minDate,
                maximumDate: minDate.add(const Duration(days: 30)),
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (date) {
                  setState(() {
                    if (isPickup) {
                      _pickupDate = date;
                    } else {
                      _dropDate = date;
                    }
                  });
                },
              ),
            ),
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _dropAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      body: Stack(
        children: [
          // Main content with map expanding to fill space
          Padding(
            padding: const EdgeInsets.only(bottom: 220), // enough space for bottom controls
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar area
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pravas',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your Luggage, our responsibility',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Pickup/Drop fields card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        children: [
                          LocationInputField(
                            controller: _pickupAddressController,
                            hintText: 'Pickup Location',
                            icon: CupertinoIcons.location_solid,
                            onLocationSelected: (location) {
                              setState(() => _pickupLocation = location);
                            },
                          ),
                          const SizedBox(height: 12),
                          LocationInputField(
                            controller: _dropAddressController,
                            hintText: 'Dropoff Location',
                            icon: CupertinoIcons.map_pin_ellipse,
                            onLocationSelected: (location) {
                              setState(() => _dropLocation = location);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Map fills remaining space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: MapWidget(
                        pickupLocation: _pickupLocation,
                        dropLocation: _dropLocation,
                        onMarkersUpdated: (markers) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _markers = markers);
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom controls always anchored
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xFFF8F8FF),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date pickers and payment row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showCupertinoDatePicker(isPickup: true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.calendar, color: kPurple, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _pickupDate == null
                                        ? 'Pickup Date'
                                        : DateFormat('dd MMM, yyyy').format(_pickupDate!),
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showCupertinoDatePicker(isPickup: false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.calendar, color: kPurple, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _dropDate == null
                                        ? 'Dropoff Date'
                                        : DateFormat('dd MMM, yyyy').format(_dropDate!),
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Payment row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.creditcard, color: kPurple, size: 20),
                          const SizedBox(width: 10),
                          Text('Paying Via', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.black87)),
                          const Spacer(),
                          Icon(CupertinoIcons.chevron_forward, color: Colors.black38, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Book Now button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: kPurple,
                        borderRadius: BorderRadius.circular(14),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          if (_formKey.currentState!.validate()) {
                            // Handle booking
                          }
                        },
                        child: Text(
                          'Book Now',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
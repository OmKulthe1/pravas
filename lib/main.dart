import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  // Initialize Google Maps with API key
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  if (apiKey == null) {
    throw Exception('Google Maps API key not found in .env file');
  }
  
  runApp(const PravasApp());
}

class PravasApp extends StatelessWidget {
  const PravasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pravas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

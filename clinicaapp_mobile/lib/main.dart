import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const ClinicaAppMobile());
}

class ClinicaAppMobile extends StatelessWidget {
  const ClinicaAppMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinicApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5E9), 
          brightness: Brightness.dark
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'clinic_optimization_page.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  static const String _urgenciasVet = "3005722844";
  static const String _ambulanciaAnimal = "3135677740";

  Future<void> _makeCall(String number) async {
    HapticFeedback.vibrate();
    final Uri url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Emergencia SOS"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          AppleCard(
            padding: const EdgeInsets.all(22),
            border: Border.all(color: AppleTheme.red.withValues(alpha: 0.35), width: 1.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppleIconBox(icon: Icons.emergency_rounded, color: AppleTheme.red, size: 54, iconSize: 28),
                    AppleBadge(text: "ATENCIÓN 24/7", color: AppleTheme.red),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Asistencia Veterinaria Inmediata",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppleTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Comunícate directamente con nuestra línea de urgencias o ubica la clínica abierta más cercana.",
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppleTheme.textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _EmergencyContactCard(
            title: "Urgencias Veterinarias 24h",
            phone: _urgenciasVet,
            subtitle: "Orientación médica inmediata",
            icon: Icons.phone_in_talk_rounded,
            color: AppleTheme.red,
            onCall: () => _makeCall(_urgenciasVet),
          ),
          const SizedBox(height: 12),
          _EmergencyContactCard(
            title: "Ambulancia Animal",
            phone: _ambulanciaAnimal,
            subtitle: "Traslado asistido en Cartagena",
            icon: Icons.local_shipping_rounded,
            color: AppleTheme.orange,
            onCall: () => _makeCall(_ambulanciaAnimal),
          ),
          const SizedBox(height: 20),

          AppleButton(
            text: "Buscar Clínica Abierta Más Cercana",
            icon: Icons.near_me_rounded,
            backgroundColor: AppleTheme.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClinicOptimizationPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final String title;
  final String phone;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onCall;

  const _EmergencyContactCard({
    required this.title,
    required this.phone,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return AppleCard(
      onTap: onCall,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppleIconBox(icon: icon, color: color, size: 50, iconSize: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppleTheme.textPrimary,
                  ),
                ),
                Text(
                  "$subtitle • $phone",
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppleTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Llamar",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

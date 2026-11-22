import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/clinica.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'book_appointment_page.dart';

class ClinicDetailPage extends StatelessWidget {
  final Clinica clinica;
  const ClinicDetailPage({super.key, required this.clinica});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Detalle de Clínica"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          AppleCard(
            padding: const EdgeInsets.all(22),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppleIconBox(icon: Icons.local_hospital_rounded, color: AppleTheme.green, size: 56, iconSize: 28),
                    AppleBadge(text: "Sede Verificada", color: AppleTheme.blue),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  clinica.nombre,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppleTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clinica.descripcion.isNotEmpty
                      ? clinica.descripcion
                      : "Centro veterinario afiliado a la red ClinicaApp.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    color: AppleTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppleCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _RowItem(icon: Icons.location_on_outlined, label: "Dirección", value: clinica.direccion),
                const Divider(height: 22),
                _RowItem(icon: Icons.phone_outlined, label: "Teléfono", value: clinica.telefono),
                const Divider(height: 22),
                _RowItem(icon: Icons.mail_outline_rounded, label: "Correo", value: clinica.email),
              ],
            ),
          ),
          const SizedBox(height: 20),

          AppleButton(
            text: "Agendar Cita en esta Clínica",
            icon: Icons.calendar_today_rounded,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _RowItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppleTheme.blue, size: 20),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppleTheme.textSecondary)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppleTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}

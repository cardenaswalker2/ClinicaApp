import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cita.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class AppointmentDetailPage extends StatelessWidget {
  final Cita cita;
  const AppointmentDetailPage({super.key, required this.cita});

  Color _statusColor(String estado) {
    final u = estado.toUpperCase();
    if (u == 'COMPLETADA') return AppleTheme.green;
    if (u == 'CANCELADA') return AppleTheme.red;
    return AppleTheme.orange;
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(cita.estado);

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Detalle de Cita"),
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
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppleIconBox(icon: Icons.event_available_rounded, color: color, size: 52, iconSize: 26),
                    AppleBadge(text: cita.estado, color: color),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  cita.motivo.isNotEmpty ? cita.motivo : "Consulta Veterinaria",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppleTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Pago: ${cita.estadoPago}",
                  style: GoogleFonts.plusJakartaSans(fontSize: 14.5, color: AppleTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppleCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _DetailRow(icon: Icons.pets_rounded, label: "Mascota", value: cita.mascotaNombre ?? "No especificada"),
                const Divider(height: 22),
                _DetailRow(icon: Icons.local_hospital_rounded, label: "Clínica", value: cita.clinicaNombre ?? "Clínica"),
                const Divider(height: 22),
                _DetailRow(icon: Icons.schedule_rounded, label: "Fecha y hora", value: cita.fechaHora),
                const Divider(height: 22),
                _DetailRow(icon: Icons.payments_outlined, label: "Costo estimado", value: "\$${cita.costo.toStringAsFixed(0)}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

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
            style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppleTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}

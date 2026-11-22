import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/recordatorio.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class ReminderDetailPage extends StatelessWidget {
  final Recordatorio recordatorio;
  const ReminderDetailPage({super.key, required this.recordatorio});

  @override
  Widget build(BuildContext context) {
    DateTime? date;
    try {
      date = DateTime.parse(recordatorio.fechaHora);
    } catch (_) {}

    final formattedDate = date != null ? DateFormat('dd/MM/yyyy').format(date) : recordatorio.fechaHora;
    final formattedTime = date != null ? DateFormat('hh:mm a').format(date) : '';

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Detalle de Recordatorio"),
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
                    const AppleIconBox(icon: Icons.alarm_rounded, color: AppleTheme.green, size: 52, iconSize: 26),
                    AppleBadge(text: recordatorio.tipo, color: AppleTheme.blue),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  recordatorio.titulo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppleTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recordatorio.descripcion.isNotEmpty ? recordatorio.descripcion : "Sin descripción adicional.",
                  style: GoogleFonts.plusJakartaSans(fontSize: 14.5, color: AppleTheme.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Fecha", style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary)),
                    Text(
                      formattedTime.isNotEmpty ? "$formattedDate • $formattedTime" : formattedDate,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppleTheme.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Estado", style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary)),
                    AppleBadge(text: recordatorio.estado, color: AppleTheme.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

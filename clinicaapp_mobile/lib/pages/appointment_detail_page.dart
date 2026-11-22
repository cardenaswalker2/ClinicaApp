import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../models/cita.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Cita cita;
  const AppointmentDetailPage({super.key, required this.cita});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late Cita _cita;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _cita = widget.cita;
  }

  Color _statusColor(String estado) {
    final u = estado.toUpperCase();
    if (u == 'COMPLETADA') return AppleTheme.green;
    if (u == 'CANCELADA') return AppleTheme.red;
    return AppleTheme.orange;
  }

  Future<void> _cancelarCita() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppleTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Cancelar Cita", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: const Text("¿Seguro que deseas cancelar esta cita?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("No")),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppleTheme.red, foregroundColor: Colors.white),
            child: const Text("Sí, cancelar"),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _processing = true);
    try {
      final res = await http.put(Uri.parse("${AppConfig.baseUrl}/citas/${_cita.id}/cancelar"));
      if (res.statusCode == 200 && mounted) {
        setState(() => _cita = Cita.fromJson(json.decode(res.body)));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cita cancelada")));
      }
    } catch (_) {}
    if (mounted) setState(() => _processing = false);
  }

  Future<void> _reprogramarCita() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _processing = true);
    try {
      final res = await http.put(
        Uri.parse("${AppConfig.baseUrl}/citas/${_cita.id}/reprogramar"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"fechaHora": dt.toIso8601String()}),
      );
      if (res.statusCode == 200 && mounted) {
        setState(() => _cita = Cita.fromJson(json.decode(res.body)));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cita reprogramada")));
      }
    } catch (_) {}
    if (mounted) setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(_cita.estado);
    final isCancelable = _cita.estado.toUpperCase() == 'PENDIENTE';
    final isPaid = _cita.estadoPago.toUpperCase() == 'PAGADO';

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
                    AppleBadge(text: _cita.estado, color: color),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _cita.motivo.isNotEmpty ? _cita.motivo : "Consulta Veterinaria",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppleTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Pago: ${_cita.estadoPago}",
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
                _DetailRow(icon: Icons.pets_rounded, label: "Mascota", value: _cita.mascotaNombre ?? "No especificada"),
                const Divider(height: 22),
                _DetailRow(icon: Icons.local_hospital_rounded, label: "Clínica", value: _cita.clinicaNombre ?? "Clínica"),
                const Divider(height: 22),
                _DetailRow(icon: Icons.schedule_rounded, label: "Fecha y hora", value: _cita.fechaHora),
                const Divider(height: 22),
                _DetailRow(icon: Icons.payments_outlined, label: "Costo estimado", value: "\$${_cita.costo.toStringAsFixed(0)}"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (!isPaid) ...[
            AppleButton(
              text: "Pagar Cita (Stripe)",
              icon: Icons.credit_card_rounded,
              backgroundColor: AppleTheme.blue,
              onPressed: () async {
                final uri = Uri.parse("${AppConfig.webBaseUrl}/usuario/pagos/${_cita.id}");
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 10),
          ],

          AppleButton(
            text: "Ver Receta Médica",
            icon: Icons.description_outlined,
            outlined: true,
            onPressed: () async {
              final uri = Uri.parse("${AppConfig.webBaseUrl}/usuario/citas/${_cita.id}/receta");
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),

          if (isCancelable) ...[
            const SizedBox(height: 10),
            AppleButton(
              text: "Reprogramar Fecha/Hora",
              icon: Icons.edit_calendar_rounded,
              backgroundColor: AppleTheme.orange,
              isLoading: _processing,
              onPressed: _reprogramarCita,
            ),
            const SizedBox(height: 10),
            AppleButton(
              text: "Cancelar Cita",
              icon: Icons.cancel_outlined,
              backgroundColor: AppleTheme.red,
              outlined: true,
              isLoading: _processing,
              onPressed: _cancelarCita,
            ),
          ],
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/clinica.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'book_appointment_page.dart';

class ClinicDetailPage extends StatefulWidget {
  final Clinica clinica;
  const ClinicDetailPage({super.key, required this.clinica});

  @override
  State<ClinicDetailPage> createState() => _ClinicDetailPageState();
}

class _ClinicDetailPageState extends State<ClinicDetailPage> {
  List<dynamic> _resenas = [];
  bool _loadingResenas = true;

  @override
  void initState() {
    super.initState();
    _fetchResenas();
  }

  Future<void> _fetchResenas() async {
    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/clinicas/${widget.clinica.id}/resenas"));
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _resenas = json.decode(res.body) as List;
          _loadingResenas = false;
        });
      } else if (mounted) {
        setState(() => _loadingResenas = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingResenas = false);
    }
  }

  void _addReviewDialog() {
    final ctrl = TextEditingController();
    int stars = 5;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppleTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(22, 20, 22, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Calificar Clínica", style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, color: AppleTheme.orange, size: 32),
                    onPressed: () => setModal(() => stars = i + 1),
                  );
                }),
              ),
              AppleTextField(controller: ctrl, label: "Tu reseña", prefixIcon: Icons.rate_review_outlined, maxLines: 2),
              const SizedBox(height: 16),
              AppleButton(
                text: "Enviar Reseña",
                isLoading: saving,
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  setModal(() => saving = true);
                  try {
                    final res = await http.post(
                      Uri.parse("${AppConfig.baseUrl}/clinicas/${widget.clinica.id}/resenas"),
                      headers: {"Content-Type": "application/json"},
                      body: json.encode({
                        "usuarioId": AppConfig.userId ?? "",
                        "titulo": AppConfig.userName ?? "Tutor",
                        "comentario": ctrl.text.trim(),
                        "calificacion": stars,
                      }),
                    );
                    if (res.statusCode == 200 && ctx.mounted) {
                      Navigator.pop(ctx);
                      _fetchResenas();
                    }
                  } catch (_) {}
                  if (ctx.mounted) setModal(() => saving = false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinica = widget.clinica;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppleAvatar(
                      imageUrl: clinica.imagenUrl,
                      fallbackIcon: Icons.local_hospital_rounded,
                      color: AppleTheme.green,
                      size: 60,
                    ),
                    const AppleBadge(text: "Sede Verificada • 4.9★", color: AppleTheme.blue),
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
          const SizedBox(height: 16),

          AppleButton(
            text: "Agendar Cita en esta Clínica",
            icon: Icons.calendar_today_rounded,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
            ),
          ),
          const SizedBox(height: 24),

          AppleSectionHeader(
            title: "Reseñas de Tutores",
            actionText: "+ Calificar",
            onAction: _addReviewDialog,
          ),
          const SizedBox(height: 10),
          if (_loadingResenas)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppleTheme.blue)))
          else if (_resenas.isEmpty)
            AppleCard(
              child: Text("Aún no hay reseñas para esta clínica.", style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary)),
            )
          else
            ..._resenas.map((r) {
              final stars = (r["calificacion"] ?? 5) as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppleCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r["titulo"] ?? "Tutor", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          Row(
                            children: List.generate(
                              stars.clamp(1, 5),
                              (_) => const Icon(Icons.star_rounded, color: AppleTheme.orange, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(r["comentario"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppleTheme.textSecondary)),
                    ],
                  ),
                ),
              );
            }),
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

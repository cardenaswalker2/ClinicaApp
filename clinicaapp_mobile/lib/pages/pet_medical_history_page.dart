import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../models/historial_visita.dart';
import '../models/mascota.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'book_appointment_page.dart';

class PetMedicalHistoryPage extends StatefulWidget {
  final Mascota mascota;
  const PetMedicalHistoryPage({super.key, required this.mascota});

  @override
  State<PetMedicalHistoryPage> createState() => _PetMedicalHistoryPageState();
}

class _PetMedicalHistoryPageState extends State<PetMedicalHistoryPage> {
  List<HistorialVisita> _visitas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}/mascotas/${widget.mascota.id}/historial"),
      );
      if (res.statusCode == 200 && mounted) {
        final List list = json.decode(res.body);
        setState(() {
          _visitas = list.map((e) => HistorialVisita.fromJson(e)).toList();
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Historial Clínico"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppleTheme.blue))
          : RefreshIndicator(
              onRefresh: _fetchHistorial,
              color: AppleTheme.blue,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                children: [
                  AppleCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const AppleIconBox(icon: Icons.pets_rounded, color: AppleTheme.blue, size: 52, iconSize: 26),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.mascota.nombre,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppleTheme.textPrimary,
                                ),
                              ),
                              Text(
                                "${widget.mascota.especie} • ${widget.mascota.raza}",
                                style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppleTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        AppleBadge(text: "${_visitas.length} visitas", color: AppleTheme.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppleButton(
                    text: "Descargar Historial en PDF",
                    icon: Icons.picture_as_pdf_rounded,
                    outlined: true,
                    onPressed: () async {
                      final uri = Uri.parse("${AppConfig.webBaseUrl}/usuario/historial/${widget.mascota.id}/pdf");
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const SizedBox(height: 22),

                  const AppleSectionHeader(title: "Consultas y Tratamientos"),
                  const SizedBox(height: 12),

                  if (_visitas.isEmpty)
                    AppleCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const AppleIconBox(icon: Icons.medical_information_outlined, color: AppleTheme.blue, size: 54),
                          const SizedBox(height: 12),
                          Text(
                            "Sin atenciones registradas aún.",
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 14),
                          AppleButton(
                            text: "Agendar primera consulta",
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._visitas.map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppleCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppleBadge(text: v.fechaVisita, color: AppleTheme.blue),
                                    Text(
                                      v.clinicaNombre,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppleTheme.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  v.diagnostico,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppleTheme.textPrimary,
                                  ),
                                ),
                                if (v.tratamiento.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tratamiento: ${v.tratamiento}",
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppleTheme.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

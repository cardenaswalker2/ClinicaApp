import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class InfoDetailPage extends StatelessWidget {
  final String? title;
  final String? description;
  final IconData? icon;
  final Color? color;

  const InfoDetailPage({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppleTheme.blue;
    final items = [
      {
        "title": "Ecosistema Unificado",
        "desc": "Centraliza historiales médicos, citas, pagos y recordatorios en un solo lugar.",
        "icon": Icons.hub_rounded,
        "color": AppleTheme.blue,
      },
      {
        "title": "Optimización Geográfica (PLEB)",
        "desc": "Calcula la clínica abierta más cercana mediante programación lineal entera binaria.",
        "icon": Icons.near_me_rounded,
        "color": AppleTheme.green,
      },
      {
        "title": "Asistencia Inteligente",
        "desc": "Nova AI responde consultas clínicas y orienta sobre servicios veterinarios 24/7.",
        "icon": Icons.auto_awesome_rounded,
        "color": AppleTheme.purple,
      },
    ];

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: Text(title ?? "Información"),
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
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppleIconBox(
                  icon: icon ?? Icons.pets_rounded,
                  color: accent,
                  size: 56,
                  iconSize: 28,
                ),
                const SizedBox(height: 18),
                Text(
                  title ?? "ClinicaApp Veterinaria",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppleTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description ??
                      "Plataforma integral para el cuidado animal, gestión clínica, agendamiento inteligente y seguimiento preventivo.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    height: 1.5,
                    color: AppleTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AppleSectionHeader(title: "Pilares de ClinicaApp"),
          const SizedBox(height: 12),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppleCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AppleIconBox(icon: e["icon"] as IconData, color: e["color"] as Color),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e["title"] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppleTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e["desc"] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppleTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

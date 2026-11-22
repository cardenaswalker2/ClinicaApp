import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/mascota.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'add_edit_pet_page.dart';
import 'book_appointment_page.dart';
import 'pet_medical_history_page.dart';

class PetDetailPage extends StatefulWidget {
  final Mascota mascota;
  const PetDetailPage({super.key, required this.mascota});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  late Mascota _mascota;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mascota = widget.mascota;
  }

  Future<void> _refreshPet() async {
    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/mascotas/${_mascota.id}"));
      if (res.statusCode == 200 && mounted) {
        setState(() => _mascota = Mascota.fromJson(json.decode(res.body)));
      }
    } catch (_) {}
  }

  Future<void> _openWekaHealthCheck() async {
    String actividad = "MEDIA";
    String apetito = "NORMAL";
    String cojera = "NO";

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppleTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          bool predicting = false;
          return Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppleIconBox(icon: Icons.psychology_rounded, color: AppleTheme.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppleBadge(text: "Modelo Weka ML", color: AppleTheme.purple),
                          const SizedBox(height: 4),
                          Text(
                            "Evaluación de Salud — ${_mascota.nombre}",
                            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: actividad,
                  decoration: InputDecoration(
                    labelText: "Nivel de actividad física",
                    filled: true,
                    fillColor: AppleTheme.surfaceSecondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: ["ALTA", "MEDIA", "BAJA"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setModalState(() => actividad = v ?? "MEDIA"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: apetito,
                  decoration: InputDecoration(
                    labelText: "Apetito reciente",
                    filled: true,
                    fillColor: AppleTheme.surfaceSecondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: ["NORMAL", "DISMINUIDO", "AUMENTADO"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setModalState(() => apetito = v ?? "NORMAL"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: cojera,
                  decoration: InputDecoration(
                    labelText: "¿Presenta cojera o rigidez?",
                    filled: true,
                    fillColor: AppleTheme.surfaceSecondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: ["NO", "SI"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setModalState(() => cojera = v ?? "NO"),
                ),
                const SizedBox(height: 20),
                AppleButton(
                  text: "Analizar con Weka",
                  icon: Icons.auto_awesome_rounded,
                  backgroundColor: AppleTheme.purple,
                  isLoading: predicting,
                  onPressed: () async {
                    setModalState(() => predicting = true);
                    try {
                      final res = await http.post(
                        Uri.parse("${AppConfig.baseUrl}/weka/predict-health/${_mascota.id}"),
                        headers: {"Content-Type": "application/json"},
                        body: json.encode({
                          "actividad": actividad,
                          "apetito": apetito,
                          "cojera": cojera,
                        }),
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx, res.statusCode == 200 ? json.decode(res.body) as Map<String, dynamic> : null);
                      }
                    } catch (_) {
                      if (ctx.mounted) Navigator.pop(ctx, null);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );

    if (result != null && mounted) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppleTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Resultado Predictivo (Weka)", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
          content: Text(
            result.entries.map((e) => "• ${e.key}: ${e.value}").join("\n"),
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppleTheme.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("Entendido")),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo conectar con el servicio predictivo Weka")),
      );
    }
  }

  Future<void> _addPhotoDialog() async {
    final ctrl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppleTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Agregar foto", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: AppleTextField(controller: ctrl, label: "URL de imagen", prefixIcon: Icons.link_rounded),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppleTheme.blue, foregroundColor: Colors.white),
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
    if (url != null && url.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await http.post(
          Uri.parse("${AppConfig.baseUrl}/mascotas/${_mascota.id}/album"),
          headers: {"Content-Type": "application/json"},
          body: json.encode(url),
        );
        await _refreshPet();
      } catch (_) {}
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: Text(_mascota.nombre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppleTheme.blue),
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditPetPage(mascota: _mascota)),
              );
              if (res == true) _refreshPet();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppleTheme.blue))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                AppleCard(
                  padding: const EdgeInsets.all(22),
                  borderRadius: 24,
                  child: Column(
                    children: [
                      const AppleIconBox(icon: Icons.pets_rounded, color: AppleTheme.blue, size: 72, iconSize: 36),
                      const SizedBox(height: 14),
                      Text(
                        _mascota.nombre,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppleTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppleBadge(text: "${_mascota.especie} • ${_mascota.raza}", color: AppleTheme.blue),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: _InfoPill(label: "Edad", value: "${_mascota.edad} años")),
                          const SizedBox(width: 10),
                          Expanded(child: _InfoPill(label: "Especie", value: _mascota.especie)),
                          const SizedBox(width: 10),
                          Expanded(child: _InfoPill(label: "Sexo", value: _mascota.sexo)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                AppleButton(
                  text: "Ver Historial Clínico",
                  icon: Icons.medical_services_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PetMedicalHistoryPage(mascota: _mascota)),
                  ),
                ),
                const SizedBox(height: 10),
                AppleButton(
                  text: "Evaluar Salud con IA (Weka)",
                  icon: Icons.psychology_rounded,
                  backgroundColor: AppleTheme.purple,
                  onPressed: _openWekaHealthCheck,
                ),
                const SizedBox(height: 10),
                AppleButton(
                  text: "Agendar Cita para ${_mascota.nombre}",
                  icon: Icons.calendar_today_rounded,
                  outlined: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
                  ),
                ),
                const SizedBox(height: 22),

                AppleSectionHeader(
                  title: "Álbum de Fotos",
                  actionText: "+ Agregar",
                  onAction: _addPhotoDialog,
                ),
                const SizedBox(height: 10),
                if (_mascota.albumFotos.isEmpty)
                  AppleCard(
                    child: Text(
                      "Sin fotos adicionales en el álbum.",
                      style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mascota.albumFotos.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, idx) => ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        _mascota.albumFotos[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppleTheme.surfaceSecondary,
                          child: const Icon(Icons.broken_image_outlined, color: AppleTheme.textTertiary),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppleTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppleTheme.border),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppleTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppleTheme.textPrimary)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/historial_visita.dart';
import '../models/mascota.dart';
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

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

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
      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        if (mounted) {
          setState(() {
            _visitas = list.map((e) => HistorialVisita.fromJson(e)).toList();
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        title: Text(
          "Historial Clínico",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _auroraBase))
          : RefreshIndicator(
              onRefresh: _fetchHistorial,
              color: _auroraBase,
              backgroundColor: _surfaceDark,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  _buildPetSummaryCard(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Consultas y Tratamientos",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _auroraBase.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_visitas.length} registros",
                          style: GoogleFonts.outfit(
                            color: _auroraBase,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_visitas.isEmpty)
                    _buildEmptyState()
                  else
                    ..._visitas.map((v) => _buildVisitaCard(v)),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const BookAppointmentPage()),
              );
            },
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            label: Text(
              "Agendar Cita para ${widget.mascota.nombre}",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _auroraBase,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _auroraBase.withOpacity(0.2),
            backgroundImage: widget.mascota.fotoUrl.isNotEmpty
                ? NetworkImage(widget.mascota.fotoUrl)
                : null,
            child: widget.mascota.fotoUrl.isEmpty
                ? const Icon(Icons.pets, color: _auroraBase, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mascota.nombre,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.mascota.especie} • ${widget.mascota.raza}",
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  "${widget.mascota.sexo} • ${widget.mascota.edad} años",
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitaCard(HistorialVisita v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_hospital_rounded, color: Colors.greenAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    v.clinicaNombre,
                    style: GoogleFonts.outfit(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                v.fechaVisita.split('T')[0],
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            v.diagnostico,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tratamiento: ${v.tratamiento}",
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
          ),
          if (v.peso != null || v.temperatura != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (v.peso != null)
                  _buildMetricBadge("Peso: ${v.peso} kg", Icons.scale_rounded),
                const SizedBox(width: 8),
                if (v.temperatura != null)
                  _buildMetricBadge("Temp: ${v.temperatura} °C", Icons.thermostat_rounded),
              ],
            ),
          ],
          if (v.medicamentosRecetados.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: v.medicamentosRecetados.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Text(
                    "💊 $m",
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _auroraBase.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _auroraBase, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(color: _auroraBase, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              "Sin consultas médicas registradas",
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Las visitas veterinarias y diagnósticos aparecerán aquí.",
              style: GoogleFonts.outfit(color: Colors.white30, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

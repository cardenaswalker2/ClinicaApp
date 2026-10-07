import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'book_appointment_page.dart';

class ClinicOptimizationPage extends StatefulWidget {
  const ClinicOptimizationPage({super.key});

  @override
  State<ClinicOptimizationPage> createState() => _ClinicOptimizationPageState();
}

class _ClinicOptimizationPageState extends State<ClinicOptimizationPage> {
  bool _loading = true;
  Map<String, dynamic>? _resultado;
  double _radio = 15.0;

  // Ubicación por defecto de Cartagena
  final double _lat = 10.3910;
  final double _lng = -75.4794;

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _ejecutarOptimizacion();
  }

  Future<void> _ejecutarOptimizacion() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(
        "${AppConfig.baseUrl}/optimizacion/clinicas?lat=$_lat&lng=$_lng&radio=$_radio&email=${AppConfig.userEmail}",
      );
      final res = await http.get(uri);
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _resultado = json.decode(res.body);
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinicaGanadora = _resultado?['clinicaSeleccionada'];
    final todasClinicas = (_resultado?['todasClinicasCalculadas'] as List? ?? []);

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        title: Text("Optimización de Clínicas", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _auroraBase),
                  SizedBox(height: 16),
                  Text("Calculando modelo PLEB + Haversine...", style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _ejecutarOptimizacion,
              color: _auroraBase,
              backgroundColor: _surfaceDark,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  _buildAlgorithmBanner(),
                  const SizedBox(height: 24),
                  if (clinicaGanadora != null) ...[
                    Text("Clínica Óptima Recomendada", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 14),
                    _buildWinnerCard(clinicaGanadora),
                    const SizedBox(height: 28),
                  ],
                  Text("Todas las Clínicas Evaluadas (${todasClinicas.length})", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 14),
                  if (todasClinicas.isEmpty)
                    _buildEmptyState()
                  else
                    ...todasClinicas.map((c) => _buildClinicEvaluationCard(c)),
                ],
              ),
            ),
    );
  }

  Widget _buildAlgorithmBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _auroraBase.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _auroraBase.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.calculate_rounded, color: _auroraBase, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Investigación de Operaciones", style: GoogleFonts.outfit(color: _auroraBase, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  "Programación Lineal Entera Binaria (PLEB) con distancias calculadas por fórmula de Haversine.",
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(Map<String, dynamic> c) {
    final nombre = c['nombre'] ?? 'Clínica Veterinaria';
    final direccion = c['direccion'] ?? '';
    final distancia = (c['distanciaKm'] ?? 0.0).toStringAsFixed(2);
    final id = c['id'] ?? '';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withOpacity(0.2), _surfaceDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                    SizedBox(width: 4),
                    Text("SOLUCIÓN ÓPTIMA", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
              Text("📍 $distancia km", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          Text(nombre, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(direccion, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const BookAppointmentPage()),
                );
              },
              icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
              label: Text("Agendar Cita Aquí", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicEvaluationCard(Map<String, dynamic> c) {
    final nombre = c['nombre'] ?? '';
    final direccion = c['direccion'] ?? '';
    final distancia = (c['distanciaKm'] ?? 0.0).toStringAsFixed(2);
    final factible = c['factible'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: factible ? Colors.blue.withOpacity(0.15) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              factible ? Icons.local_hospital_rounded : Icons.location_off_rounded,
              color: factible ? _auroraBase : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(direccion, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            "$distancia km",
            style: GoogleFonts.outfit(color: factible ? Colors.white70 : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text("No se encontraron clínicas en el radio establecido.", style: GoogleFonts.outfit(color: Colors.white38)),
      ),
    );
  }
}

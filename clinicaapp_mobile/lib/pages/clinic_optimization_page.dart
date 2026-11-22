import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
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

  final double _lat = 10.3910;
  final double _lng = -75.4794;

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
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinicaGanadora = _resultado?['clinicaSeleccionada'];
    final todasClinicas = (_resultado?['todasClinicasCalculadas'] as List? ?? []);

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Clínica Óptima (PLEB)"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppleTheme.blue),
                  const SizedBox(height: 16),
                  Text(
                    "Calculando ruta óptima Haversine...",
                    style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _ejecutarOptimizacion,
              color: AppleTheme.blue,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                children: [
                  // Banner Modelo PLEB
                  AppleCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const AppleIconBox(icon: Icons.calculate_rounded, color: AppleTheme.blue),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppleBadge(text: "Investigación de Operaciones", color: AppleTheme.blue),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Modelo PLEB + Haversine",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppleTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Radio máximo (D_max): ${_radio.toInt()} km",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppleTheme.textPrimary,
                              ),
                            ),
                            Text(
                              "Cartagena GPS",
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppleTheme.textSecondary),
                            ),
                          ],
                        ),
                        Slider(
                          value: _radio,
                          min: 5,
                          max: 30,
                          divisions: 5,
                          activeColor: AppleTheme.blue,
                          onChanged: (v) => setState(() => _radio = v),
                          onChangeEnd: (_) => _ejecutarOptimizacion(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (clinicaGanadora != null) ...[
                    const AppleSectionHeader(title: "Sede Óptima Recomendada"),
                    const SizedBox(height: 10),
                    AppleCard(
                      padding: const EdgeInsets.all(18),
                      border: Border.all(color: AppleTheme.green.withValues(alpha: 0.45), width: 1.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppleBadge(text: "ÓPTIMA • ABIERTA", color: AppleTheme.green),
                              Text(
                                "${(clinicaGanadora['distanciaKm'] ?? 0).toStringAsFixed(2)} km",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppleTheme.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            clinicaGanadora['nombre'] ?? 'Clínica Recomendada',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppleTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            clinicaGanadora['direccion'] ?? '',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppleTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          AppleButton(
                            text: "Agendar Cita Aquí",
                            icon: Icons.calendar_today_rounded,
                            backgroundColor: AppleTheme.green,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  AppleSectionHeader(title: "Sedes Evaluadas (${todasClinicas.length})"),
                  const SizedBox(height: 10),
                  if (todasClinicas.isEmpty)
                    AppleCard(
                      child: Text(
                        "No hay clínicas factibles dentro de ${_radio.toInt()} km. Prueba ampliar el radio.",
                        style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                      ),
                    )
                  else
                    ...todasClinicas.map((c) {
                      final disponible = c['abierta'] == true || c['disponible'] == true;
                      final dist = (c['distanciaKm'] ?? 0).toDouble();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppleCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              AppleIconBox(
                                icon: Icons.local_hospital_rounded,
                                color: disponible ? AppleTheme.blue : AppleTheme.textTertiary,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c['nombre'] ?? 'Clínica',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppleTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      c['direccion'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppleTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${dist.toStringAsFixed(2)} km",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppleTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AppleBadge(
                                    text: disponible ? "Disponible" : "Cerrada",
                                    color: disponible ? AppleTheme.green : AppleTheme.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/cita.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'appointment_detail_page.dart';
import 'book_appointment_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<Cita> _citas = [];
  bool _isLoading = true;
  String _selectedFilter = "Todas";
  final List<String> _filters = ["Todas", "Pendiente", "Completada", "Cancelada"];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}/citas/usuario/${AppConfig.userEmail}"),
      );
      if (mounted) {
        setState(() {
          if (res.statusCode == 200) {
            _citas = (json.decode(res.body) as List)
                .map((e) => Cita.fromJson(e))
                .toList();
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Cita> get _filteredCitas {
    if (_selectedFilter == "Todas") return _citas;
    return _citas
        .where((c) => c.estado.toUpperCase() == _selectedFilter.toUpperCase())
        .toList();
  }

  Color _getStatusColor(String estado) {
    final upper = estado.toUpperCase();
    if (upper == 'COMPLETADA') return AppleTheme.green;
    if (upper == 'CANCELADA') return AppleTheme.red;
    return AppleTheme.orange;
  }

  @override
  Widget build(BuildContext context) {
    final citas = _filteredCitas;

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetch,
          color: AppleTheme.blue,
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mis Citas",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppleTheme.textPrimary,
                      letterSpacing: -0.7,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
                      );
                      _fetch();
                    },
                    icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                    label: Text(
                      "Agendar",
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppleTheme.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Filtros estilo Apple Segmented / Pills
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final f = _filters[idx];
                    final selected = _selectedFilter == f;
                    return ChoiceChip(
                      label: Text(
                        f,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppleTheme.textSecondary,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppleTheme.blue,
                      backgroundColor: AppleTheme.surface,
                      side: BorderSide(color: selected ? AppleTheme.blue : AppleTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) => setState(() => _selectedFilter = f),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppleTheme.blue)))
              else if (citas.isEmpty)
                AppleCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No hay citas en esta categoría.",
                        style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                      ),
                    ),
                  ),
                )
              else
                ...citas.map((cita) {
                  final color = _getStatusColor(cita.estado);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppleCard(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AppointmentDetailPage(cita: cita)),
                        );
                        _fetch();
                      },
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AppleIconBox(icon: Icons.calendar_today_rounded, color: color, size: 48),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cita.motivo.isNotEmpty ? cita.motivo : "Consulta Veterinaria",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppleTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${cita.mascotaNombre ?? 'Mascota'} • ${cita.clinicaNombre ?? 'Clínica'}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppleTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cita.fechaHora,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppleTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppleBadge(text: cita.estado, color: color),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

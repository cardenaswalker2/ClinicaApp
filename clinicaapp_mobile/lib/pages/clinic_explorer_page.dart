import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/clinica.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'clinic_detail_page.dart';
import 'clinic_optimization_page.dart';

class ClinicExplorerPage extends StatefulWidget {
  const ClinicExplorerPage({super.key});

  @override
  State<ClinicExplorerPage> createState() => _ClinicExplorerPageState();
}

class _ClinicExplorerPageState extends State<ClinicExplorerPage> {
  List<Clinica> _clinicas = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/clinicas"));
      if (mounted) {
        setState(() {
          if (res.statusCode == 200) {
            _clinicas = (json.decode(res.body) as List)
                .map((e) => Clinica.fromJson(e))
                .toList();
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Clinica> get _filteredClinicas {
    if (_searchQuery.isEmpty) return _clinicas;
    final q = _searchQuery.toLowerCase();
    return _clinicas.where((cl) {
      return cl.nombre.toLowerCase().contains(q) ||
          cl.direccion.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredClinicas;

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
                    "Clínicas",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppleTheme.textPrimary,
                      letterSpacing: -0.7,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ClinicOptimizationPage()),
                    ),
                    icon: const Icon(Icons.near_me_rounded, size: 18, color: AppleTheme.blue),
                    label: Text(
                      "Más cercana",
                      style: GoogleFonts.plusJakartaSans(
                        color: AppleTheme.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Buscador estilo iOS Spotlight
              Container(
                decoration: BoxDecoration(
                  color: AppleTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppleTheme.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.plusJakartaSans(color: AppleTheme.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Buscar clínica o barrio...",
                    hintStyle: GoogleFonts.plusJakartaSans(color: AppleTheme.textTertiary),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppleTheme.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppleTheme.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppleTheme.blue)))
              else if (list.isEmpty)
                AppleCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No se encontraron clínicas.",
                        style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                      ),
                    ),
                  ),
                )
              else
                ...list.map((cl) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppleCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ClinicDetailPage(clinica: cl)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const AppleIconBox(
                            icon: Icons.local_hospital_rounded,
                            color: AppleTheme.green,
                            size: 50,
                            iconSize: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cl.nombre,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppleTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  cl.direccion,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppleTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const AppleBadge(text: "Verificada", color: AppleTheme.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      cl.telefono,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppleTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppleTheme.textTertiary),
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

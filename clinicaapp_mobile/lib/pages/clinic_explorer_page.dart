import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import '../config/app_config.dart';
import '../models/clinica.dart';
import 'clinic_detail_page.dart';

// ============================================================
// CLINIC EXPLORER PAGE - LUXURY AURORA EDITION
// Lógica de fetch y navegación 100% preservada
// ============================================================

class ClinicExplorerPage extends StatefulWidget {
  const ClinicExplorerPage({super.key});

  @override
  State<ClinicExplorerPage> createState() => _ClinicExplorerPageState();
}

class _ClinicExplorerPageState extends State<ClinicExplorerPage>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════
  // CONTROLLERS & STATE - LÓGICA ORIGINAL PRESERVADA
  // ═══════════════════════════════════════════════════════════
  List<Clinica> _clinicas = [];
  bool _loading = true;

  // ── Animaciones ──
  late AnimationController _aurora;
  late AnimationController _floatController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  // ── Búsqueda y filtros ──
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "Todas";

  // ── Colores Luxury Aurora ──
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

  final List<String> _filters = ["Todas", "24h", "Especializada", "Cerca"];

  @override
  void initState() {
    super.initState();
    // ── Lógica original preservada ──
    _fetch();

    // ── Nuevas animaciones ──
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH - LÓGICA ORIGINAL 100% PRESERVADA
  // ═══════════════════════════════════════════════════════════

  Future<void> _fetch() async {
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}/clinicas"),
      );
      if (mounted) {
        setState(() {
          _clinicas = (json.decode(res.body) as List)
              .map((e) => Clinica.fromJson(e))
              .toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _aurora.dispose();
    _floatController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // FILTRADO LOCAL
  // ═══════════════════════════════════════════════════════════

  List<Clinica> get _filteredClinicas {
    return _clinicas.where((cl) {
      final matchesSearch = _searchQuery.isEmpty ||
          cl.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cl.direccion.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // ── Fondo Aurora Animado ──
          _buildBackground(),
          // ── Orbes flotantes ──
          _buildFloatingOrbs(),
          // ── Contenido Principal ──
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetch,
              color: _auroraBase,
              backgroundColor: _surfaceDark,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Header con título ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _buildHeader(),
                    ),
                  ),
                  // ── Barra de búsqueda ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _buildSearchBar(),
                    ),
                  ),
                  // ── Filtros horizontales ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: _buildFilters(),
                    ),
                  ),
                  // ── Estadísticas ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _buildStatsBar(),
                    ),
                  ),
                  // ── Lista de clínicas ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    sliver: _loading
                        ? const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _auroraBase,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : _filteredClinicas.isEmpty
                            ? SliverFillRemaining(
                                child: _buildEmptyState(),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return _buildClinicCard(
                                      _filteredClinicas[index],
                                      index,
                                    );
                                  },
                                  childCount: _filteredClinicas.length,
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FONDO AURORA ANIMADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _aurora,
      builder: (context, child) {
        final hue = (_aurora.value * 360) % 360;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_aurora.value * math.pi * 2) * 0.3,
                math.cos(_aurora.value * math.pi * 2) * 0.3,
              ),
              radius: 1.8,
              colors: [
                HSLColor.fromAHSL(1.0, hue, 0.6, 0.12).toColor(),
                HSLColor.fromAHSL(1.0, (hue + 30) % 360, 0.5, 0.08).toColor(),
                _bgDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ORBES FLOTANTES
  // ═══════════════════════════════════════════════════════════

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        _buildOrb(
          top: -100,
          left: -80,
          size: 400,
          color: _auroraBase.withOpacity(0.03),
          blur: 80,
        ),
        _buildOrb(
          bottom: 200,
          right: -100,
          size: 350,
          color: const Color(0xFF818CF8).withOpacity(0.02),
          blur: 100,
        ),
        _buildOrb(
          top: 400,
          right: -60,
          size: 200,
          color: _auroraGlow.withOpacity(0.02),
          blur: 60,
        ),
      ],
    );
  }

  Widget _buildOrb({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    required double blur,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              math.sin(_floatController.value * math.pi) * 15,
              math.cos(_floatController.value * math.pi) * 20,
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color, color.withOpacity(0.0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color,
                    blurRadius: blur,
                    spreadRadius: size * 0.1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER CON TÍTULO Y SUBTÍTULO
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_auroraBase, _auroraGlow],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Explorar Clínicas",
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Encuentra las mejores clínicas veterinarias cerca de ti",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.40),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BARRA DE BÚSQUEDA PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: Colors.white30,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: "Buscar clínica o dirección...",
                        hintStyle: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white30,
                          size: 20,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FILTROS HORIZONTALES
  // ═══════════════════════════════════════════════════════════

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedFilter = filter),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [_auroraBase, _auroraDeep],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? _auroraBase.withOpacity(0.5)
                            : Colors.white.withOpacity(0.06),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _auroraBase.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      filter,
                      style: GoogleFonts.outfit(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.50),
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BARRA DE ESTADÍSTICAS
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatsBar() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Row(
              children: [
                _buildStatItem(
                  icon: Icons.local_hospital_rounded,
                  value: "${_clinicas.length}",
                  label: "Clínicas",
                  color: _auroraBase,
                ),
                const SizedBox(width: 12),
                _buildStatItem(
                  icon: Icons.star_rounded,
                  value: "4.8",
                  label: "Promedio",
                  color: Colors.amber,
                ),
                const SizedBox(width: 12),
                _buildStatItem(
                  icon: Icons.location_on_rounded,
                  value: "2.5km",
                  label: "Más cercana",
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: Colors.white.withOpacity(0.40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE CLÍNICA PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildClinicCard(Clinica cl, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + index * 100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ClinicDetailPage(clinica: cl),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(28),
                  splashColor: _auroraBase.withOpacity(0.1),
                  highlightColor: _auroraBase.withOpacity(0.05),
                  child: _buildGlassContainer(
                    width: double.infinity,
                    borderRadius: 28,
                    borderColor: Colors.white.withOpacity(0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Imagen de la clínica ──
                        SizedBox(
                          height: 160,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Imagen o placeholder
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                                child: cl.imagenUrl.isNotEmpty
                                    ? Image.network(
                                        cl.imagenUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return _buildImagePlaceholder();
                                        },
                                      )
                                    : _buildImagePlaceholder(),
                              ),
                              // ── Gradient overlay ──
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(28),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      _bgDark.withOpacity(0.7),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                              // ── Badge de rating ──
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "4.9",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // ── Badge de abierto ──
                              Positioned(
                                top: 16,
                                left: 16,
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(
                                            0.3 + _pulseController.value * 0.2,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.greenAccent
                                                      .withOpacity(0.5),
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Abierto",
                                            style: GoogleFonts.outfit(
                                              color: Colors.greenAccent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ── Info de la clínica ──
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cl.nombre,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _auroraBase.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: _auroraBase,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cl.direccion,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.60),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // ── Footer con distancia y flecha ──
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.directions_walk_rounded,
                                        size: 14,
                                        color: Colors.white30,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "1.2 km",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white.withOpacity(0.40),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: Colors.white30,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "24h",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white.withOpacity(0.40),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          _auroraBase,
                                          _auroraDeep,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _auroraBase.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.02),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_rounded,
              size: 50,
              color: Colors.white10,
            ),
            const SizedBox(height: 8),
            Text(
              "Sin imagen",
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.15),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ESTADO VACÍO
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60,
            color: Colors.white10,
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty
                ? "No hay clínicas disponibles"
                : "No se encontraron resultados",
            style: GoogleFonts.outfit(
              color: Colors.white30,
              fontSize: 16,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = "");
              },
              child: Text(
                "Limpiar búsqueda",
                style: GoogleFonts.outfit(
                  color: _auroraBase,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UTILIDADES: Glassmorphism
  // ═══════════════════════════════════════════════════════════

  Widget _buildGlassContainer({
    required Widget child,
    double? width,
    double? height,
    required double borderRadius,
    Color borderColor = Colors.white10,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

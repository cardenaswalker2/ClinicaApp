import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import '../config/app_config.dart';
import '../models/cita.dart';
import 'appointment_detail_page.dart';
import 'book_appointment_page.dart';

// ============================================================
// APPOINTMENTS PAGE - LUXURY AURORA EDITION
// Lógica de fetch, filtros de estado y navegación 100% preservada
// ============================================================

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════
  // CONTROLLERS & STATE - LÓGICA ORIGINAL PRESERVADA
  // ═══════════════════════════════════════════════════════════
  List<Cita> _citas = [];
  bool _isLoading = true;

  // ── Filtros de estado (lógica original preservada) ──
  String _selectedFilter = "Todas";
  final List<String> _filters = ["Todas", "Pendiente", "Completada", "Cancelada"];

  // ── Animaciones ──
  late AnimationController _aurora;
  late AnimationController _floatController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  // ── Colores Luxury Aurora ──
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

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
        Uri.parse("${AppConfig.baseUrl}/citas/usuario/${AppConfig.userEmail}"),
      );
      if (mounted) {
        setState(() {
          _citas = (json.decode(res.body) as List)
              .map((e) => Cita.fromJson(e))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _aurora.dispose();
    _floatController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // FILTRADO LOCAL (basado en lógica original de estado)
  // ═══════════════════════════════════════════════════════════

  List<Cita> get _filteredCitas {
    if (_selectedFilter == "Todas") return _citas;
    return _citas
        .where((c) => c.estado.toUpperCase() == _selectedFilter.toUpperCase())
        .toList();
  }

  // ═══════════════════════════════════════════════════════════
  // COLOR DE ESTADO - LÓGICA ORIGINAL PRESERVADA
  // ═══════════════════════════════════════════════════════════

  Color _getStatusColor(String estado) {
    final upper = estado.toUpperCase();
    if (upper == 'COMPLETADA') return Colors.greenAccent;
    if (upper == 'CANCELADA') return Colors.redAccent;
    return _auroraBase;
  }

  String _getStatusLabel(String estado) {
    final upper = estado.toUpperCase();
    if (upper == 'COMPLETADA') return "Completada";
    if (upper == 'CANCELADA') return "Cancelada";
    return "Pendiente";
  }

  IconData _getStatusIcon(String estado) {
    final upper = estado.toUpperCase();
    if (upper == 'COMPLETADA') return Icons.check_circle_rounded;
    if (upper == 'CANCELADA') return Icons.cancel_rounded;
    return Icons.schedule_rounded;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _buildHeader(),
                ),
                const SizedBox(height: 24),
                // ── Stats bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildStatsBar(),
                ),
                const SizedBox(height: 24),
                // ── Filtros ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildFilters(),
                ),
                const SizedBox(height: 20),
                // ── Lista de citas ──
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: _auroraBase,
                            strokeWidth: 2.5,
                          ),
                        )
                      : _filteredCitas.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _fetch,
                              color: _auroraBase,
                              backgroundColor: _surfaceDark,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                itemCount: _filteredCitas.length,
                                itemBuilder: (context, index) =>
                                    _buildCitaCard(_filteredCitas[index], index),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      // ── FAB para agregar cita ──
      floatingActionButton: _buildFAB(),
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
  // HEADER
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
                    Text(
                      "Mis Citas",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Gestiona tus visitas veterinarias",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.40),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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
  // STATS BAR
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatsBar() {
    final pendientes = _citas
        .where((c) => c.estado.toUpperCase() != 'COMPLETADA' &&
            c.estado.toUpperCase() != 'CANCELADA')
        .length;
    final completadas =
        _citas.where((c) => c.estado.toUpperCase() == 'COMPLETADA').length;
    final canceladas =
        _citas.where((c) => c.estado.toUpperCase() == 'CANCELADA').length;

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
                  value: "${_citas.length}",
                  label: "Total",
                  color: _auroraBase,
                  icon: Icons.calendar_month_rounded,
                ),
                const SizedBox(width: 10),
                _buildStatItem(
                  value: "$pendientes",
                  label: "Pendientes",
                  color: Colors.orangeAccent,
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(width: 10),
                _buildStatItem(
                  value: "$completadas",
                  label: "Completadas",
                  color: Colors.greenAccent,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: _buildGlassContainer(
        height: 90,
        borderRadius: 20,
        borderColor: Colors.white.withOpacity(0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
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
  // FILTROS
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
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
  // CARD DE CITA PREMIUM (LÓGICA ORIGINAL PRESERVADA)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCitaCard(Cita cita, int index) {
    final statusColor = _getStatusColor(cita.estado);
    final statusLabel = _getStatusLabel(cita.estado);
    final statusIcon = _getStatusIcon(cita.estado);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentDetailPage(cita: cita),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(28),
                  splashColor: statusColor.withOpacity(0.1),
                  highlightColor: statusColor.withOpacity(0.05),
                  child: _buildGlassContainer(
                    width: double.infinity,
                    height: 150,
                    borderRadius: 28,
                    borderColor: statusColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          // ── Icono con fondo ──
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withOpacity(0.15),
                                  statusColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: statusColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 18),
                          // ── Info ──
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  cita.motivo.isEmpty
                                      ? "Consulta General"
                                      : cita.motivo,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 13,
                                      color: Colors.white.withOpacity(0.40),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cita.fechaHora.split('T')[0],
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.50),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: Colors.white.withOpacity(0.40),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(cita.fechaHora),
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.50),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    statusLabel.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ── Flecha ──
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withOpacity(0.20),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
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

  String _formatTime(String fechaHora) {
    try {
      final parts = fechaHora.split('T');
      if (parts.length > 1) {
        final timeParts = parts[1].split(':');
        return "${timeParts[0]}:${timeParts[1]}";
      }
      return "--:--";
    } catch (e) {
      return "--:--";
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ESTADO VACÍO (LÓGICA ORIGINAL PRESERVADA)
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  -8 * math.sin(_floatController.value * math.pi),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 80,
                  color: Colors.white10,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            "No tienes citas programadas",
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.30),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Toca el botón + para agendar una nueva cita",
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.20),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FAB PARA AGREGAR CITA
  // ═══════════════════════════════════════════════════════════

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _auroraBase.withOpacity(
                  0.3 + _glowController.value * 0.2,
                ),
                blurRadius: 20 + _glowController.value * 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookAppointmentPage()),
              );
              if (result == true) {
                _fetch(); // Recargar citas si se agendó una nueva
              }
            },
            backgroundColor: _auroraBase,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
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

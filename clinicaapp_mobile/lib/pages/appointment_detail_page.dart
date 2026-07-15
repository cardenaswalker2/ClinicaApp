import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../models/cita.dart';

// ============================================================
// APPOINTMENT DETAIL PAGE - LUXURY AURORA EDITION
// Lógica de estado, datos y navegación 100% preservada
// ============================================================

class AppointmentDetailPage extends StatefulWidget {
  final Cita cita;
  const AppointmentDetailPage({super.key, required this.cita});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════
  // LÓGICA ORIGINAL PRESERVADA
  // cita.estado.toUpperCase() -> color de estado
  // cita.motivo, cita.fechaHora, cita.costo
  // Navigator.pop(context) en back button
  // ═══════════════════════════════════════════════════════════

  // ── Animaciones ──
  late AnimationController _floatController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late ScrollController _scrollController;

  // ── Estado de scroll ──
  bool _isScrolled = false;

  // ── Colores Luxury Aurora ──
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDark = Color(0xFF020617);

  @override
  void initState() {
    super.initState();
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

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 150 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 150 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // COLOR DE ESTADO - LÓGICA ORIGINAL 100% PRESERVADA
  // ═══════════════════════════════════════════════════════════

  Color get _statusColor {
    final upper = widget.cita.estado.toUpperCase();
    if (upper == 'COMPLETADA') return Colors.greenAccent;
    if (upper == 'CANCELADA') return Colors.redAccent;
    return _auroraBase;
  }

  String get _statusLabel {
    final upper = widget.cita.estado.toUpperCase();
    if (upper == 'COMPLETADA') return "Completada";
    if (upper == 'CANCELADA') return "Cancelada";
    return "Pendiente";
  }

  IconData get _statusIcon {
    final upper = widget.cita.estado.toUpperCase();
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
          // ── Fondo con orbe de estado ──
          _buildStatusBackground(),
          // ── Contenido scrollable ──
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── SliverAppBar con icono hero ──
              _buildSliverAppBar(),
              // ── Contenido principal ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header con título y estado ──
                      _buildHeader(),
                      const SizedBox(height: 32),
                      // ── Timeline visual ──
                      _buildTimeline(),
                      const SizedBox(height: 32),
                      // ── Sección Información General ──
                      _buildInfoSection(),
                      const SizedBox(height: 32),
                      // ── Sección Finanzas ──
                      _buildFinanceSection(),
                      const SizedBox(height: 32),
                      // ── Card de ayuda ──
                      _buildHelpCard(),
                      const SizedBox(height: 32),
                      // ── Botones de acción ──
                      _buildActionButtons(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Botón de back flotante ──
          _buildBackButton(),
          // ── AppBar flotante al hacer scroll ──
          _buildFloatingAppBar(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FONDO CON ORBE DE ESTADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatusBackground() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          left: -150,
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _statusColor.withOpacity(
                        0.08 + _glowController.value * 0.05,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _statusColor.withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SLIVER APP BAR CON ICONO HERO
  // ═══════════════════════════════════════════════════════════

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ── Gradient overlay ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _bgDark.withOpacity(0.3),
                    _bgDark.withOpacity(0.95),
                  ],
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
            ),
            // ── Icono central animado ──
            Center(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -10 * math.sin(_floatController.value * math.pi),
                    ),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _statusColor.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _statusColor.withOpacity(0.15),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _statusIcon,
                          size: 70,
                          color: _statusColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // ── Orbe decorativo ──
            Positioned(
              bottom: 40,
              right: 40,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _statusColor.withOpacity(
                            0.1 + _glowController.value * 0.1,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER CON TÍTULO Y ESTADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Detalle de Cita",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.40),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.cita.motivo.isEmpty
                                ? "Consulta General"
                                : widget.cita.motivo,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // ── Badge de estado ──
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _statusColor.withOpacity(
                                0.3 + _pulseController.value * 0.2,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _statusColor.withOpacity(
                                  0.1 * _pulseController.value,
                                ),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _statusColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _statusColor.withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _statusLabel.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: _statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TIMELINE VISUAL
  // ═══════════════════════════════════════════════════════════

  Widget _buildTimeline() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: _buildGlassContainer(
              width: double.infinity,
              borderRadius: 24,
              borderColor: Colors.white.withOpacity(0.04),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // ── Línea vertical con puntos ──
                    Column(
                      children: [
                        _buildTimelineDot(
                          isActive: true,
                          isFirst: true,
                          color: _statusColor,
                        ),
                        Container(
                          width: 2,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _statusColor.withOpacity(0.5),
                                _statusColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                        _buildTimelineDot(
                          isActive: widget.cita.estado.toUpperCase() ==
                                  'COMPLETADA' ||
                              widget.cita.estado.toUpperCase() == 'CANCELADA',
                          isFirst: false,
                          color: widget.cita.estado.toUpperCase() ==
                                  'COMPLETADA'
                              ? Colors.greenAccent
                              : widget.cita.estado.toUpperCase() ==
                                      'CANCELADA'
                                  ? Colors.redAccent
                                  : Colors.white24,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // ── Info del timeline ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimelineItem(
                            title: "Cita Programada",
                            subtitle:
                                widget.cita.fechaHora.split('T')[0],
                            isActive: true,
                          ),
                          const SizedBox(height: 24),
                          _buildTimelineItem(
                            title: widget.cita.estado.toUpperCase() ==
                                    'COMPLETADA'
                                ? "Completada"
                                : widget.cita.estado.toUpperCase() ==
                                        'CANCELADA'
                                    ? "Cancelada"
                                    : "En espera",
                            subtitle: widget.cita.estado.toUpperCase() ==
                                    'COMPLETADA'
                                ? "La cita fue atendida exitosamente"
                                : widget.cita.estado.toUpperCase() ==
                                        'CANCELADA'
                                    ? "La cita fue cancelada"
                                    : "Pendiente de atención",
                            isActive: widget.cita.estado.toUpperCase() ==
                                    'COMPLETADA' ||
                                widget.cita.estado.toUpperCase() ==
                                    'CANCELADA',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineDot({
    required bool isActive,
    required bool isFirst,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 16 : 12,
      height: isActive ? 16 : 12,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white12,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? color.withOpacity(0.5) : Colors.white24,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.30),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.outfit(
            color: isActive ? Colors.white.withOpacity(0.50) : Colors.white.withOpacity(0.20),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN INFORMACIÓN GENERAL
  // ═══════════════════════════════════════════════════════════

  Widget _buildInfoSection() {
    final infoItems = [
      {
        "icon": Icons.info_outline_rounded,
        "label": "Motivo",
        "value": widget.cita.motivo.isEmpty
            ? "Consulta General"
            : widget.cita.motivo,
        "color": _auroraBase,
      },
      {
        "icon": Icons.calendar_today_rounded,
        "label": "Fecha",
        "value": widget.cita.fechaHora.split('T')[0],
        "color": Colors.greenAccent,
      },
      {
        "icon": Icons.access_time_rounded,
        "label": "Hora",
        "value": widget.cita.fechaHora.contains('T')
            ? widget.cita.fechaHora.split('T')[1].substring(0, 5)
            : "Por confirmar",
        "color": Colors.orangeAccent,
      },
      {
        "icon": Icons.person_outline_rounded,
        "label": "Veterinario",
        "value": "Dr. García",
        "color": Colors.purpleAccent,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Información General"),
        const SizedBox(height: 16),
        ...infoItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + index * 80),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDetailItem(
                      icon: item["icon"] as IconData,
                      label: item["label"] as String,
                      value: item["value"] as String,
                      color: item["color"] as Color,
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN FINANZAS
  // ═══════════════════════════════════════════════════════════

  Widget _buildFinanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Finanzas"),
        const SizedBox(height: 16),
        _buildGlassContainer(
          width: double.infinity,
          borderRadius: 24,
          borderColor: Colors.white.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildFinanceRow(
                  label: "Costo Estimado",
                  value: "\$${widget.cita.costo}",
                  isTotal: false,
                ),
                const SizedBox(height: 14),
                Divider(
                  color: Colors.white.withOpacity(0.04),
                  height: 1,
                ),
                const SizedBox(height: 14),
                _buildFinanceRow(
                  label: "Total",
                  value: "\$${widget.cita.costo}",
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceRow({
    required String label,
    required String value,
    required bool isTotal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: isTotal ? Colors.white : Colors.white.withOpacity(0.50),
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isTotal ? Colors.white : Colors.white70,
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE AYUDA
  // ═══════════════════════════════════════════════════════════

  Widget _buildHelpCard() {
    return _buildGlassContainer(
      width: double.infinity,
      borderRadius: 24,
      borderColor: Colors.amber.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.15),
                    Colors.amber.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Colors.amber,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¿Necesitas ayuda?",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Si necesitas reprogramar, por favor contacta a la clínica directamente.",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTONES DE ACCIÓN
  // ═══════════════════════════════════════════════════════════

  Widget _buildActionButtons() {
    return Column(
      children: [
        // ── Botón principal ──
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [_auroraBase, _auroraDeep],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _auroraBase.withOpacity(
                      0.3 + _glowController.value * 0.2,
                    ),
                    blurRadius: 25 + _glowController.value * 15,
                    offset: const Offset(0, 12),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white24,
                  highlightColor: Colors.white10,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_calendar_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Reprogramar Cita",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        // ── Botón secundario ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cancel_rounded,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Cancelar Cita",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DETAIL ITEM PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return _buildGlassContainer(
      width: double.infinity,
      height: 76,
      borderRadius: 20,
      borderColor: Colors.white.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.40),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTÓN DE BACK FLOTANTE
  // ═══════════════════════════════════════════════════════════

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 20,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // APP BAR FLOTANTE AL HACER SCROLL
  // ═══════════════════════════════════════════════════════════

  Widget _buildFloatingAppBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _isScrolled ? 0 : -100,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isScrolled ? 1 : 0,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: MediaQuery.of(context).padding.top + 60,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: _bgDark.withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.cita.motivo.isEmpty
                          ? "Consulta General"
                          : widget.cita.motivo,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_auroraBase, _auroraGlow],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

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

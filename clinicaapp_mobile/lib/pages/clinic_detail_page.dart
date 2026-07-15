import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../models/clinica.dart';

// ============================================================
// CLINIC DETAIL PAGE - LUXURY AURORA EDITION
// Lógica de navegación y datos 100% preservada
// ============================================================

class ClinicDetailPage extends StatefulWidget {
  final Clinica clinica;
  const ClinicDetailPage({super.key, required this.clinica});

  @override
  State<ClinicDetailPage> createState() => _ClinicDetailPageState();
}

class _ClinicDetailPageState extends State<ClinicDetailPage>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════
  // CONTROLLERS & STATE - LÓGICA ORIGINAL PRESERVADA
  // ═══════════════════════════════════════════════════════════
  // clinica viene via widget.clinica (nombre, direccion, telefono, email, descripcion, imagenUrl)

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
  static const Color _surfaceDark = Color(0xFF0F172A);

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
    if (_scrollController.offset > 200 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 200 && _isScrolled) {
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
  // BUILD PRINCIPAL
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // ── Contenido scrollable ──
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── SliverAppBar con imagen hero ──
              _buildSliverAppBar(),
              // ── Contenido principal ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header con nombre y rating ──
                      _buildClinicHeader(),
                      const SizedBox(height: 24),
                      // ── Badges de estado ──
                      _buildStatusBadges(),
                      const SizedBox(height: 28),
                      // ── Info cards ──
                      _buildInfoCards(),
                      const SizedBox(height: 32),
                      // ── Sección "Sobre la clínica" ──
                      _buildAboutSection(),
                      const SizedBox(height: 32),
                      // ── Servicios ──
                      _buildServicesSection(),
                      const SizedBox(height: 32),
                      // ── Horarios ──
                      _buildScheduleSection(),
                      const SizedBox(height: 40),
                      // ── Botón CTA ──
                      _buildCTAButton(),
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
  // SLIVER APP BAR CON IMAGEN HERO
  // ═══════════════════════════════════════════════════════════

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ── Imagen de fondo ──
            widget.clinica.imagenUrl.isNotEmpty
                ? Image.network(
                    widget.clinica.imagenUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
            // ── Gradient overlay ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _bgDark.withOpacity(0.3),
                    _bgDark.withOpacity(0.9),
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
            ),
            // ── Gradient lateral para legibilidad ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _bgDark.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // ── Orbe decorativo ──
            Positioned(
              bottom: 40,
              right: 24,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _auroraBase.withOpacity(
                            0.15 + _glowController.value * 0.1,
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.02),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_rounded,
              size: 60,
              color: Colors.white10,
            ),
            const SizedBox(height: 12),
            Text(
              "Sin imagen disponible",
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.15),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER DE CLÍNICA CON RATING
  // ═══════════════════════════════════════════════════════════

  Widget _buildClinicHeader() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.clinica.nombre,
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.2),
                                width: 1,
                              ),
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
                                    color: Colors.amber,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "(128 reseñas)",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.40),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BADGES DE ESTADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatusBadges() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildStatusBadge(
                  icon: Icons.circle,
                  label: "Abierto ahora",
                  color: Colors.greenAccent,
                  isPulsing: true,
                ),
                _buildStatusBadge(
                  icon: Icons.access_time_rounded,
                  label: "24 horas",
                  color: _auroraBase,
                ),
                _buildStatusBadge(
                  icon: Icons.verified_rounded,
                  label: "Verificada",
                  color: Colors.purpleAccent,
                ),
                _buildStatusBadge(
                  icon: Icons.local_hospital_rounded,
                  label: "Especializada",
                  color: Colors.orangeAccent,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required Color color,
    bool isPulsing = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isPulsing
              ? AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(
                              0.4 + _pulseController.value * 0.4,
                            ),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // INFO CARDS CON GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════

  Widget _buildInfoCards() {
    final infoItems = [
      {
        "icon": Icons.location_on_rounded,
        "label": "Dirección",
        "value": widget.clinica.direccion,
        "color": _auroraBase,
      },
      {
        "icon": Icons.phone_rounded,
        "label": "Teléfono",
        "value": widget.clinica.telefono,
        "color": Colors.greenAccent,
      },
      {
        "icon": Icons.email_rounded,
        "label": "Email",
        "value": widget.clinica.email,
        "color": Colors.purpleAccent,
      },
    ];

    return Column(
      children: infoItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + index * 100),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(20 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildGlassContainer(
                    width: double.infinity,
                    borderRadius: 20,
                    borderColor: Colors.white.withOpacity(0.04),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      (item["color"] as Color)
                                          .withOpacity(0.15),
                                      (item["color"] as Color)
                                          .withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  item["icon"] as IconData,
                                  color: item["color"] as Color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["label"] as String,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.40),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["value"] as String,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white10,
                                size: 20,
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
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN "SOBRE LA CLÍNICA"
  // ═══════════════════════════════════════════════════════════

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Sobre la clínica"),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 15 * (1 - _slideController.value)),
              child: Opacity(
                opacity: _slideController.value,
                child: _buildGlassContainer(
                  width: double.infinity,
                  borderRadius: 24,
                  borderColor: Colors.white.withOpacity(0.04),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Text(
                      widget.clinica.descripcion.isEmpty
                          ? "No hay descripción disponible."
                          : widget.clinica.descripcion,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN SERVICIOS
  // ═══════════════════════════════════════════════════════════

  Widget _buildServicesSection() {
    final services = [
      {"icon": Icons.vaccines_rounded, "label": "Vacunación", "color": Colors.greenAccent},
      {"icon": Icons.medical_services_rounded, "label": "Cirugía", "color": Colors.redAccent},
      {"icon": Icons.pets_rounded, "label": "Consulta", "color": _auroraBase},
      {"icon": Icons.local_pharmacy_rounded, "label": "Farmacia", "color": Colors.purpleAccent},
      {"icon": Icons.emergency_rounded, "label": "Urgencias", "color": Colors.orangeAccent},
      {"icon": Icons.biotech_rounded, "label": "Laboratorio", "color": Colors.tealAccent},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Servicios"),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
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
                        padding: const EdgeInsets.only(right: 14),
                        child: Column(
                          children: [
                            _buildGlassContainer(
                              width: 68,
                              height: 68,
                              borderRadius: 20,
                              borderColor: (service["color"] as Color)
                                  .withOpacity(0.15),
                              child: AnimatedBuilder(
                                animation: _floatController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      -2 * math.sin(
                                        _floatController.value * math.pi,
                                      ),
                                    ),
                                    child: Icon(
                                      service["icon"] as IconData,
                                      color: service["color"] as Color,
                                      size: 28,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              service["label"] as String,
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.60),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN HORARIOS
  // ═══════════════════════════════════════════════════════════

  Widget _buildScheduleSection() {
    final schedule = [
      {"day": "Lunes - Viernes", "hours": "08:00 - 20:00"},
      {"day": "Sábado", "hours": "09:00 - 14:00"},
      {"day": "Domingo", "hours": "Urgencias 24h"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Horarios"),
        const SizedBox(height: 16),
        _buildGlassContainer(
          width: double.infinity,
          borderRadius: 24,
          borderColor: Colors.white.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: schedule.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < schedule.length - 1 ? 14 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item["day"]!,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: index == 2
                              ? Colors.green.withOpacity(0.1)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: index == 2
                                ? Colors.green.withOpacity(0.2)
                                : Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item["hours"]!,
                          style: GoogleFonts.outfit(
                            color: index == 2
                                ? Colors.greenAccent
                                : Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTÓN CTA PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildCTAButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [_auroraBase, _auroraDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
              BoxShadow(
                color: _auroraBase.withOpacity(0.1),
                blurRadius: 60,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(22),
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Agendar Cita",
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            4 * math.sin(_floatController.value * math.pi),
                            0,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
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

  // ═══════════════════════════════════════════════════════════
  // BOTÓN DE BACK FLOTANTE
  // ═══════════════════════════════════════════════════════════

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 20,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
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
          );
        },
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
                      widget.clinica.nombre,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

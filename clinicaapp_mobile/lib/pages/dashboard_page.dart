import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import '../config/app_config.dart';
import '../models/recordatorio.dart';
import '../models/mascota.dart';
import '../models/cita.dart';
import 'pet_detail_page.dart';
import 'add_reminder_page.dart';
import 'appointment_detail_page.dart';
import 'notifications_page.dart';
import 'appointments_page.dart';
import 'clinic_explorer_page.dart';
import 'sos_page.dart';
import 'reminder_detail_page.dart';
import 'shop_page.dart';
import '../models/notificacion.dart';

// ============================================================
// DASHBOARD PAGE - LUXURY AURORA EDITION
// Lógica de fetch y navegación 100% preservada
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════
  // CONTROLLERS & STATE - LÓGICA ORIGINAL PRESERVADA
  // ═══════════════════════════════════════════════════════════
  late AnimationController _aurora;
  List<Recordatorio> _recs = [];
  List<Mascota> _pets = [];
  List<Cita> _citas = [];
  int _unreadNotifs = 0;
  bool _loading = true;

  // ── Animaciones adicionales ──
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
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
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // ── Nuevas animaciones ──
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fetch();
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH - LÓGICA ORIGINAL 100% PRESERVADA
  // ═══════════════════════════════════════════════════════════

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final rRes = await http.get(
        Uri.parse("${AppConfig.baseUrl}/recordatorios/usuario/${AppConfig.userEmail}"),
      );
      final pRes = await http.get(
        Uri.parse("${AppConfig.baseUrl}/mascotas/usuario/${AppConfig.userEmail}"),
      );
      final cRes = await http.get(
        Uri.parse("${AppConfig.baseUrl}/citas/usuario/${AppConfig.userEmail}"),
      );

      if (mounted) {
        int unreadCount = 0;
        try {
          final nRes = await http.get(Uri.parse("${AppConfig.baseUrl}/notificaciones/usuario/${AppConfig.userEmail}/count"));
          unreadCount = int.parse(nRes.body);
        } catch (_) {}

        setState(() {
          _recs = (json.decode(rRes.body) as List)
              .map((e) => Recordatorio.fromJson(e))
              .toList();
          _pets = (json.decode(pRes.body) as List)
              .map((e) => Mascota.fromJson(e))
              .toList();
          _citas = (json.decode(cRes.body) as List)
              .map((e) => Cita.fromJson(e))
              .toList();
          
          _unreadNotifs = unreadCount;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _aurora.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _glowController.dispose();
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 16),
                  // ── Header con perfil ──
                  _buildHeader(),
                  const SizedBox(height: 28),
                  // ── Banner de bienvenida ──
                  _buildWelcomeBanner(),
                  const SizedBox(height: 32),
                  // ── Acciones rápidas ──
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  // ── Sección Mis Mascotas ──
                  _buildSectionHeader("Mis Mascotas", "${_pets.length}"),
                  const SizedBox(height: 16),
                  _buildPetsList(),
                  const SizedBox(height: 32),
                  // ── Próxima Cita ──
                  if (_citas.isNotEmpty) ...[
                    _buildSectionHeader("Próxima Cita", ""),
                    const SizedBox(height: 16),
                    _buildNextAppointment(_citas.first),
                    const SizedBox(height: 32),
                  ],
                  // ── Avisos Recientes ──
                  _buildSectionHeader("Avisos Recientes", "${_recs.length}"),
                  const SizedBox(height: 16),
                  ..._recs.take(3).map((r) => _recItem(r)),
                  const SizedBox(height: 32),
                  // ── Tip de Salud ──
                  _buildHealthTip(),
                  const SizedBox(height: 120),
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
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _aurora,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F172A),
                    HSLColor.fromAHSL(
                      1.0,
                      (_aurora.value * 360),
                      0.6,
                      0.15,
                    ).toColor(),
                    const Color(0xFF020617),
                  ],
                ),
              ),
            );
          },
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
      ],
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
          bottom: 100,
          right: -100,
          size: 350,
          color: const Color(0xFF818CF8).withOpacity(0.02),
          blur: 100,
        ),
        _buildOrb(
          top: 300,
          right: -80,
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
  // HEADER CON PERFIL Y NOTIFICACIONES
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Saludo y nombre ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola de nuevo,",
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConfig.userName ?? "Usuario",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                // ── Botón notificaciones con badge ──
                Stack(
                  children: [
                    _buildGlassButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const NotificationsPage()),
                        ).then((_) => _fetch());
                      },
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (_unreadNotifs > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 12,
                              height: 12,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(
                                      0.4 + _pulseController.value * 0.4,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                _unreadNotifs > 9 ? "9+" : "$_unreadNotifs",
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
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
  // BANNER DE BIENVENIDA CON GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════

  Widget _buildWelcomeBanner() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: _buildGlassContainer(
              width: double.infinity,
              borderRadius: 28,
              borderColor: Colors.white.withOpacity(0.06),
              child: Stack(
                children: [
                  // ── Icono decorativo de fondo ──
                  Positioned(
                    right: -30,
                    bottom: -30,
                    child: Icon(
                      Icons.pets_rounded,
                      size: 160,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                  // ── Orbe decorativo ──
                  Positioned(
                    right: 20,
                    top: 20,
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
                                _auroraBase.withOpacity(
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
                  // ── Contenido ──
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_auroraBase, _auroraGlow],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "NOVA AI",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "¡Nova te saluda! 🤖",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Hoy es un gran día para cuidar a tus peluditos. Revisa tus pendientes abajo.",
                          style: GoogleFonts.outfit(
                            color: Colors.white60,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ACCIONES RÁPIDAS CON ANIMACIONES
  // ═══════════════════════════════════════════════════════════

  Widget _buildQuickActions() {
    final actions = [
      {
        "icon": Icons.add_alert_rounded,
        "label": "Aviso",
        "color": Colors.orangeAccent,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const AddReminderPage()),
        ).then((_) => _fetch()),
      },
      {
        "icon": Icons.calendar_month_rounded,
        "label": "Cita",
        "color": Colors.blueAccent,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const AppointmentsPage()),
        ).then((_) => _fetch()),
      },
      {
        "icon": Icons.emergency_rounded,
        "label": "SOS",
        "color": Colors.redAccent,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const SOSPage()),
        ),
      },
      {
        "icon": Icons.local_hospital_rounded,
        "label": "Clínicas",
        "color": Colors.greenAccent,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const ClinicExplorerPage()),
        ),
      },
      {
        "icon": Icons.shopping_bag_rounded,
        "label": "Tienda",
        "color": Colors.purpleAccent,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const ShopPage()),
        ),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return _buildActionButton(
          icon: action["icon"] as IconData,
          label: action["label"] as String,
          color: action["color"] as Color,
          onTap: action["onTap"] as VoidCallback,
          delay: index * 100,
        );
      }).toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(22),
                    splashColor: color.withOpacity(0.2),
                    highlightColor: color.withOpacity(0.1),
                    child: _buildGlassContainer(
                      width: 68,
                      height: 68,
                      borderRadius: 22,
                      borderColor: color.withOpacity(0.25),
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              -2 * math.sin(_floatController.value * math.pi),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
  // HEADER DE SECCIÓN
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
        ),
        if (count.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Text(
              count,
              style: GoogleFonts.outfit(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LISTA DE MASCOTAS CON ANIMACIONES
  // ═══════════════════════════════════════════════════════════

  Widget _buildPetsList() {
    if (_loading) {
      return SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: _auroraBase,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_pets.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pets_rounded,
        message: "No tienes mascotas registradas",
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _pets.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + index * 100),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: _petItem(_pets[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _petItem(Mascota m) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => PetDetailPage(mascota: m),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -3 * math.sin(_floatController.value * math.pi),
                    ),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _auroraBase.withOpacity(0.4),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _auroraBase.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        image: m.fotoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(m.fotoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: m.fotoUrl.isEmpty
                          ? const Icon(
                              Icons.pets_rounded,
                              color: Colors.white24,
                              size: 32,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                m.nombre,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PRÓXIMA CITA CON DISEÑO PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildNextAppointment(Cita cita) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => AppointmentDetailPage(cita: cita),
          ),
        ),
        borderRadius: BorderRadius.circular(28),
        child: _buildGlassContainer(
          width: double.infinity,
          borderRadius: 28,
          borderColor: _auroraBase.withOpacity(0.15),
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
                        _auroraBase.withOpacity(0.15),
                        _auroraBase.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _auroraBase.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: _auroraBase,
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
                        cita.motivo.isEmpty ? "Cita Médica" : cita.motivo,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
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
                        ],
                      ),
                    ],
                  ),
                ),
                // ── Flecha ──
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white30,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ITEM DE RECORDATORIO CON ANIMACIÓN
  // ═══════════════════════════════════════════════════════════

  Widget _recItem(Recordatorio r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _buildGlassContainer(
        width: double.infinity,
        borderRadius: 24,
        borderColor: Colors.white.withOpacity(0.04),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => ReminderDetailPage(recordatorio: r),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // ── Avatar con icono ──
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getReminderColor(r.tipo).withOpacity(0.15),
                          _getReminderColor(r.tipo).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      r.tipo == 'SMS'
                          ? Icons.sms_rounded
                          : Icons.email_rounded,
                      color: _getReminderColor(r.tipo),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ── Texto ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          r.titulo,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.descripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.40),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Flecha ──
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getReminderColor(String tipo) {
    switch (tipo) {
      case 'SMS':
        return Colors.indigoAccent;
      case 'EMAIL':
        return Colors.blueAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // TIP DE SALUD CON DISEÑO PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildHealthTip() {
    return _buildGlassContainer(
      width: double.infinity,
      borderRadius: 28,
      borderColor: Colors.greenAccent.withOpacity(0.15),
      child: Stack(
        children: [
          // ── Decoración de fondo ──
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 120,
              color: Colors.greenAccent.withOpacity(0.03),
            ),
          ),
          // ── Contenido ──
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent.withOpacity(0.15),
                        Colors.greenAccent.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.greenAccent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Colors.greenAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Tip del día",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Mantén siempre agua fresca disponible para evitar deshidratación.",
                        style: TextStyle(
                          color: Colors.white70,
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
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ESTADO VACÍO
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white12, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.outfit(
                color: Colors.white30,
                fontSize: 14,
              ),
            ),
          ],
        ),
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

  Widget _buildGlassButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

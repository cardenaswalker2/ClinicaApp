import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import '../config/app_config.dart';
import 'login_page.dart';

// ============================================================
// PROFILE PAGE - LUXURY AURORA EDITION
// Lógica de datos y navegación 100% preservada
// ============================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════
  // LÓGICA ORIGINAL PRESERVADA
  // AppConfig.userName, AppConfig.userEmail
  // Navigator.pushReplacement -> LoginPage
  // ═══════════════════════════════════════════════════════════

  // ── Datos reales ──
  int _petCount = 0;
  int _appointmentCount = 0;
  bool _loading = true;

  // ── Animaciones ──
  late AnimationController _aurora;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _glowController;

  // ── Colores Luxury Aurora ──
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDark = Color(0xFF020617);

  // ── Datos del menú ──
  final List<Map<String, dynamic>> _menuItems = [
    {"icon": Icons.person_outline_rounded, "title": "Editar Perfil", "subtitle": "Actualiza tu información personal", "color": _auroraBase},
    {"icon": Icons.security_rounded, "title": "Seguridad", "subtitle": "Contraseña y autenticación", "color": Colors.purpleAccent},
    {"icon": Icons.notifications_outlined, "title": "Notificaciones", "subtitle": "Configura tus alertas", "color": Colors.orangeAccent},
    {"icon": Icons.help_outline_rounded, "title": "Soporte Técnico", "subtitle": "Centro de ayuda y contacto", "color": Colors.greenAccent},
    {"icon": Icons.info_outline_rounded, "title": "Sobre Clínica App", "subtitle": "Versión 1.0.0", "color": Colors.tealAccent},
  ];

  @override
  void initState() {
    super.initState();
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

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

    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (AppConfig.userEmail == null) return;
    try {
      final petsRes = await http.get(
        Uri.parse("${AppConfig.baseUrl}/mascotas/usuario/${AppConfig.userEmail}"),
      );
      final citasRes = await http.get(
        Uri.parse("${AppConfig.baseUrl}/citas/usuario/${AppConfig.userEmail}"),
      );

      if (mounted) {
        setState(() {
          _petCount = (json.decode(petsRes.body) as List).length;
          _appointmentCount = (json.decode(citasRes.body) as List).length;
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // ── Header con avatar ──
                  _buildHeader(),
                  const SizedBox(height: 32),
                  // ── Stats cards ──
                  _buildStatsSection(),
                  const SizedBox(height: 32),
                  // ── Sección de menú ──
                  _buildMenuSection(context),
                  const SizedBox(height: 32),
                  // ── Botón logout ──
                  _buildLogoutButton(context),
                  const SizedBox(height: 50),
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
          top: -80,
          left: -60,
          size: 350,
          color: _auroraBase.withOpacity(0.04),
          blur: 80,
        ),
        _buildOrb(
          bottom: -80,
          right: -60,
          size: 400,
          color: const Color(0xFF818CF8).withOpacity(0.03),
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
  // HEADER CON AVATAR ANIMADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Center(
              child: Column(
                children: [
                  // ── Avatar con halo ──
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Halo exterior pulsante
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _auroraBase.withOpacity(
                                  0.15 + _pulseController.value * 0.15,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _auroraBase.withOpacity(
                                    0.1 * _pulseController.value,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Halo intermedio
                      Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _auroraBase.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      // Avatar principal
                      _buildGlassContainer(
                        width: 110,
                        height: 110,
                        borderRadius: 55,
                        borderColor: Colors.white.withOpacity(0.1),
                        child: Center(
                          child: Text(
                            AppConfig.userName != null
                                ? AppConfig.userName![0].toUpperCase()
                                : "U",
                            style: GoogleFonts.outfit(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Badge de verificado
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_auroraBase, _auroraGlow],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _bgDark,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _auroraBase.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // ── Nombre ──
                  Text(
                    AppConfig.userName ?? "Usuario",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ── Email ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      AppConfig.userEmail ?? "email@clinicaapp.com",
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.50),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ── Badge de plan ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_auroraBase, _auroraGlow],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "PLAN PREMIUM",
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
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
  // SECCIÓN DE STATS
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.pets_rounded,
                    label: "Mascotas",
                    value: _loading ? "..." : "$_petCount",
                    color: _auroraBase,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.notifications_active_rounded,
                    label: "Avisos",
                    value: "0", // Avisos aún no implementados en backend
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_month_rounded,
                    label: "Citas",
                    value: _loading ? "..." : "$_appointmentCount",
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return _buildGlassContainer(
      height: 100,
      borderRadius: 22,
      borderColor: Colors.white.withOpacity(0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.40),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN DE MENÚ
  // ═══════════════════════════════════════════════════════════

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Configuración"),
        const SizedBox(height: 16),
        ..._menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + index * 80),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMenuItem(
                      icon: item["icon"] as IconData,
                      title: item["title"] as String,
                      subtitle: item["subtitle"] as String,
                      color: item["color"] as Color,
                      onTap: () {},
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _buildGlassContainer(
      width: double.infinity,
      height: 76,
      borderRadius: 20,
      borderColor: Colors.white.withOpacity(0.04),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
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
                        title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.20),
                    size: 18,
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
  // BOTÓN LOGOUT PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildLogoutButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                Colors.redAccent.withOpacity(0.8),
                Colors.redAccent.withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(
                  0.2 + _glowController.value * 0.15,
                ),
                blurRadius: 20 + _glowController.value * 10,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const LoginPage()),
              ),
              borderRadius: BorderRadius.circular(22),
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Cerrar Sesión",
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

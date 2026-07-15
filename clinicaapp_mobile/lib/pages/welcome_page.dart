import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'login_page.dart';
import 'info_detail_page.dart';

// ============================================================
// WELCOME PAGE - LUXURY AURORA EDITION
// ============================================================

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Colores Luxury Aurora ──
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _surfaceDark = Color(0xFF0F172A);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _glassWhite = Color(0x0DFFFFFF);

  // ── Datos del Onboarding ──
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Cuidado\nExcepcional",
      "subtitle": "Salud de Élite",
      "desc": "Conectamos a tu mascota con la red más prestigiosa de especialistas médicos y tecnología de punta.",
      "icon": Icons.auto_awesome_rounded,
      "color": Color(0xFF0EA5E9),
      "gradient": [Color(0xFF0EA5E9), Color(0xFF2563EB)],
    },
    {
      "title": "Guido:\nInteligencia AI",
      "subtitle": "Asistente 24/7",
      "desc": "Recibe diagnósticos preliminares y consejos expertos impulsados por nuestra IA avanzada.",
      "icon": Icons.psychology_alt_rounded,
      "color": Color(0xFF818CF8),
      "gradient": [Color(0xFF818CF8), Color(0xFF6366F1)],
    },
    {
      "title": "Bienestar sin\nFronteras",
      "subtitle": "Red Global",
      "desc": "Gestiona historiales médicos, vacunas y citas en las mejores clínicas del mundo desde un solo lugar.",
      "icon": Icons.public_rounded,
      "color": Color(0xFF34D399),
      "gradient": [Color(0xFF34D399), Color(0xFF10B981)],
    },
  ];

  // ── Datos de Estadísticas ──
  final List<Map<String, dynamic>> _statsData = [
    {"value": "+500", "label": "Clínicas", "icon": Icons.local_hospital_rounded},
    {"value": "24/7", "label": "Soporte AI", "icon": Icons.headset_mic_rounded},
    {"value": "4.9★", "label": "Rating", "icon": Icons.star_rounded},
  ];

  // ── Datos de "Por qué elegirnos" ──
  final List<Map<String, dynamic>> _whyChooseUs = [
    {
      "title": "Gestión de Mascotas",
      "desc": "Perfiles completos con historial médico, vacunas y preferencias.",
      "icon": Icons.pets_rounded,
      "color": Color(0xFF0EA5E9),
    },
    {
      "title": "Clínicas Cercanas",
      "desc": "Encuentra las mejores clínicas veterinarias en tu zona con geolocalización.",
      "icon": Icons.location_on_rounded,
      "color": Color(0xFF818CF8),
    },
    {
      "title": "Recordatorios Inteligentes",
      "desc": "Notificaciones personalizadas para vacunas, citas y medicamentos.",
      "icon": Icons.notifications_active_rounded,
      "color": Color(0xFF34D399),
    },
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
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
          // ── Fondo Aurora ──
          _buildLuxuryBackground(),
          // ── Orbes flotantes ──
          _buildFloatingOrbs(),
          // ── Contenido Principal ──
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header fijo
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                    child: _buildTopBar(),
                  ),
                ),
                // Sección de Onboarding
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: _buildOnboardingSection(),
                  ),
                ),
                // Sección de Estadísticas
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: _buildStatsSection(),
                  ),
                ),
                // Sección "Por qué elegirnos"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: _buildWhyChooseUsSection(),
                  ),
                ),
                // Botón CTA
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    child: _buildBottomSection(),
                  ),
                ),
                // Espacio inferior
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FONDO AURORA ANIMADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildLuxuryBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final hue = (_bgController.value * 360) % 360;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_bgController.value * math.pi * 2) * 0.3,
                math.cos(_bgController.value * math.pi * 2) * 0.3,
              ),
              radius: 1.8,
              colors: [
                HSLColor.fromAHSL(1.0, hue, 0.6, 0.15).toColor(),
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
  // ORBES FLOTANTES CON GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        _buildOrb(
          top: -120,
          left: -80,
          size: 450,
          color: _onboardingData[_currentPage]["color"].withOpacity(0.06),
          blur: 80,
        ),
        _buildOrb(
          bottom: 100,
          right: -100,
          size: 380,
          color: _auroraBase.withOpacity(0.04),
          blur: 100,
        ),
        _buildOrb(
          top: 300,
          right: -120,
          size: 250,
          color: _onboardingData[_currentPage]["color"].withOpacity(0.03),
          blur: 60,
        ),
        _buildOrb(
          bottom: -80,
          left: 100,
          size: 300,
          color: const Color(0xFF818CF8).withOpacity(0.03),
          blur: 90,
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
                  colors: [
                    color,
                    color.withOpacity(0.0),
                  ],
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
  // TOP BAR CON GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo animado
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _auroraBase.withOpacity(0.2 + _pulseController.value * 0.1),
                        _auroraBase.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _auroraBase.withOpacity(0.3 + _pulseController.value * 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _auroraBase.withOpacity(0.2 * _pulseController.value),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: _auroraBase,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CLÍNICA",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      "APP MOBILE",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.white38,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        // Botón Saltar con Glassmorphism
        _buildGlassButton(
          onTap: _toLogin,
          child: Text(
            "Saltar",
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN ONBOARDING CON PAGEVIEW
  // ═══════════════════════════════════════════════════════════

  Widget _buildOnboardingSection() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) => _buildSlide(index),
          ),
        ),
        const SizedBox(height: 20),
        // Indicadores de página
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _onboardingData.length,
            (index) => _buildPageIndicator(index),
          ),
        ),
      ],
    );
  }

  Widget _buildSlide(int index) {
    final data = _onboardingData[index];
    final List<Color> gradient = List<Color>.from(data["gradient"]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icono animado con halo ──
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  -12 * math.sin(_floatController.value * math.pi),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Halo exterior pulsante
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: data["color"].withOpacity(
                                0.1 + _glowController.value * 0.1,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: data["color"].withOpacity(
                                  0.05 + _glowController.value * 0.05,
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
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: data["color"].withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    // Contenedor principal con glassmorphism
                    _buildGlassContainer(
                      width: 170,
                      height: 170,
                      borderRadius: 85,
                      borderColor: Colors.white.withOpacity(0.20),
                      child: Icon(
                        data["icon"],
                        size: 80,
                        color: data["color"],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 45),
          // ── Badge de subtítulo ──
          _buildAnimatedBadge(data),
          const SizedBox(height: 24),
          // ── Título principal ──
          Text(
            data["title"]!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          // ── Descripción ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              data["desc"]!,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
                height: 1.6,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBadge(Map<String, dynamic> data) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                data["color"].withOpacity(0.08 + _glowController.value * 0.05),
                data["color"].withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: data["color"].withOpacity(0.2 + _glowController.value * 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: data["color"].withOpacity(0.05 * _glowController.value),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            data["subtitle"]!.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: data["color"],
              letterSpacing: 2.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: _currentPage == index ? 36 : 8,
      decoration: BoxDecoration(
        gradient: _currentPage == index
            ? const LinearGradient(
                colors: [_auroraBase, _auroraGlow],
              )
            : null,
        color: _currentPage == index ? null : Colors.white12,
        borderRadius: BorderRadius.circular(4),
        boxShadow: _currentPage == index
            ? [
                BoxShadow(
                  color: _auroraBase.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN DE ESTADÍSTICAS CON GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatsSection() {
    return _buildGlassContainer(
      width: double.infinity,
      height: 90,
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _statsData.map((stat) => _buildStatItem(stat)).toList(),
      ),
    );
  }

  Widget _buildStatItem(Map<String, dynamic> stat) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat["icon"],
                size: 14,
                color: _auroraBase.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                stat["value"]!,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stat["label"]!,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white38,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECCIÓN "POR QUÉ ELEGIRNOS"
  // ═══════════════════════════════════════════════════════════

  Widget _buildWhyChooseUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_auroraBase, _auroraGlow],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "¿Por qué elegirnos?",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        // Cards de características
        ..._whyChooseUs.asMap().entries.map((entry) {
          return _buildFeatureCard(entry.value, entry.key);
        }).toList(),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> data, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + index * 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGlassContainer(
                width: double.infinity,
                borderRadius: 24,
                borderColor: Colors.white.withOpacity(0.06),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Icono con fondo degradado
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              data["color"].withOpacity(0.2),
                              data["color"].withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: data["color"].withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          data["icon"],
                          size: 28,
                          color: data["color"],
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Texto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["title"]!,
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data["desc"]!,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.45),
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Flecha decorativa
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: data["color"].withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTÓN CTA CON EFECTOS DE BRILLO
  // ═══════════════════════════════════════════════════════════

  Widget _buildBottomSection() {
    return Column(
      children: [
        // Botón principal con gradiente y sombra
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 68,
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
                  onTap: _currentPage == _onboardingData.length - 1
                      ? _toLogin
                      : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOutQuart,
                          ),
                  borderRadius: BorderRadius.circular(22),
                  splashColor: Colors.white24,
                  highlightColor: Colors.white10,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _onboardingData.length - 1
                              ? "COMENZAR AHORA"
                              : "CONTINUAR",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
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
                                size: 22,
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
        ),
        const SizedBox(height: 14),
        // Botón Explorar
        _buildGlassButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InfoDetailPage()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded, color: _auroraGlow, size: 18),
              const SizedBox(width: 8),
              Text(
                "Explorar el ecosistema digital",
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Texto secundario
        TextButton(
          onPressed: _toLogin,
          child: Text(
            "¿Ya tienes cuenta? Inicia sesión",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white38,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
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
            color: _glassWhite,
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
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white10,
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NAVEGACIÓN
  // ═══════════════════════════════════════════════════════════

  void _toLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

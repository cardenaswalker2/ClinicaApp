import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';

class InfoDetailPage extends StatefulWidget {
  const InfoDetailPage({super.key});

  @override
  State<InfoDetailPage> createState() => _InfoDetailPageState();
}

class _InfoDetailPageState extends State<InfoDetailPage> with TickerProviderStateMixin {
  late AnimationController _scrollEffectController;
  late AnimationController _bgAnimationController;

  // Colores Premium
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);
  static const Color _glassWhite = Color(0x0DFFFFFF);

  @override
  void initState() {
    super.initState();
    _scrollEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _scrollEffectController.forward();
  }

  @override
  void dispose() {
    _scrollEffectController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Fondo Aurora Animado de Lujo
          _buildAnimatedBackground(),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Fijo / Navigation
                SliverToBoxAdapter(child: _buildHeader(context)),

                // 1. Hero Principal
                SliverToBoxAdapter(child: _buildHeroSection()),

                // 2. Nuestra Misión
                SliverToBoxAdapter(child: _buildMissionSection()),

                // 3. ¿Por qué ClinicaApp? (Grid de características grandes)
                SliverToBoxAdapter(child: _buildWhyClinicaAppSection()),

                // 4. Ecosistema ClinicaApp (Diagrama Visual)
                SliverToBoxAdapter(child: _buildEcosystemSection()),

                // 5. Tecnologías Utilizadas
                SliverToBoxAdapter(child: _buildTechnologiesSection()),

                // 6. Seguridad
                SliverToBoxAdapter(child: _buildSecuritySection()),

                // 7. Estadísticas
                SliverToBoxAdapter(child: _buildStatsSection()),

                // 8. Línea de Tiempo (Cómo funciona)
                SliverToBoxAdapter(child: _buildTimelineSection()),

                // 9. Beneficios
                SliverToBoxAdapter(child: _buildBenefitsSection()),

                // 10. Footer Elegante
                SliverToBoxAdapter(child: _buildFooterSection()),

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
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgAnimationController,
      builder: (context, child) {
        final double angle = _bgAnimationController.value * 2 * math.pi;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.4 * math.sin(angle),
                0.4 * math.cos(angle) - 0.2,
              ),
              radius: 2.0,
              colors: const [
                Color(0x1F0EA5E9),
                Color(0x0C38BDF8),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: _glassWhite,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          Text(
            "DESCUBRIR",
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _auroraGlow,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 1. HERO PRINCIPAL
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _auroraBase.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _auroraBase.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pets_rounded, color: _auroraGlow, size: 14),
                const SizedBox(width: 8),
                Text(
                  "Ecosistema ClinicaApp",
                  style: GoogleFonts.outfit(
                    color: _auroraGlow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "La plataforma veterinaria\nmás inteligente de\nLatinoamérica",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Conecta veterinarios, dueños de mascotas e Inteligencia Artificial en una sola aplicación móvil.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white54,
                height: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Ilustración de Mascota de Lujo con Orbe Flotante
          Stack(
            alignment: Alignment.center,
            children: [
              // Orbe brillante posterior
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _auroraBase.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: _auroraBase.withOpacity(0.2),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Icono Ilustración
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white70,
                    size: 70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 2. NUESTRA MISIÓN
  // ═══════════════════════════════════════════════════════════
  Widget _buildMissionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: _buildGlassContainer(
        borderRadius: 28,
        borderColor: Colors.white.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.pink, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Nuestra misión",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Queremos que cada mascota reciba atención médica más rápida, inteligente y accesible.",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Combinamos Inteligencia Artificial, telemedicina y tecnología para mejorar la calidad de vida de millones de mascotas en todo el continente.",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white38,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3. ¿POR QUÉ CLINICAAPP?
  // ═══════════════════════════════════════════════════════════
  Widget _buildWhyClinicaAppSection() {
    final List<Map<String, dynamic>> features = [
      {
        "title": "Atención 24/7",
        "desc": "La IA responde consultas de salud incluso cuando la clínica física está cerrada.",
        "icon": Icons.support_agent_rounded,
        "color": const Color(0xFF0EA5E9),
      },
      {
        "title": "Agenda Inteligente",
        "desc": "Programa tus citas en segundos y recibe recordatorios automáticos al instante.",
        "icon": Icons.calendar_today_rounded,
        "color": const Color(0xFF818CF8),
      },
      {
        "title": "Clínicas Cercanas",
        "desc": "Encuentra clínicas veterinarias en tu zona usando geolocalización en tiempo real.",
        "icon": Icons.map_rounded,
        "color": const Color(0xFF34D399),
      },
      {
        "title": "Historial Médico",
        "desc": "Toda la información clínica, vacunas y recetas organizada de forma segura en la nube.",
        "icon": Icons.cloud_done_rounded,
        "color": const Color(0xFFFBBF24),
      },
      {
        "title": "Pagos Seguros",
        "desc": "Realiza el pago de consultas y servicios de forma segura integrada con Stripe.",
        "icon": Icons.credit_card_rounded,
        "color": const Color(0xFFEC4899),
      },
      {
        "title": "Predicciones con IA",
        "desc": "Modelos predictivos que te ayudan a evaluar el riesgo articular y predecir inasistencias.",
        "icon": Icons.auto_graph_rounded,
        "color": const Color(0xFFA855F7),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¿Qué hace diferente a ClinicaApp?",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final f = features[index];
              return _buildGlassContainer(
                borderRadius: 20,
                borderColor: Colors.white.withOpacity(0.06),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(f["icon"], color: f["color"], size: 28),
                      const SizedBox(height: 12),
                      Text(
                        f["title"]!,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        f["desc"]!,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white38,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 4. ECOSISTEMA CLINICAAPP (DIAGRAMA)
  // ═══════════════════════════════════════════════════════════
  Widget _buildEcosystemSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ecosistema ClinicaApp",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildGlassContainer(
            borderRadius: 28,
            borderColor: Colors.white.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
              child: Column(
                children: [
                  // Centro
                  _buildEcosystemNode("🐾 Mascotas", _auroraBase, isRoot: true),
                  const SizedBox(height: 12),
                  // Líneas conectores
                  Container(width: 2, height: 20, color: Colors.white12),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          _buildEcosystemNode("🤖 Guido AI", const Color(0xFF818CF8)),
                          const SizedBox(height: 10),
                          _buildEcosystemNode("🏥 Clínicas", const Color(0xFF34D399)),
                          const SizedBox(height: 10),
                          _buildEcosystemNode("📅 Agenda", const Color(0xFFFBBF24)),
                        ],
                      ),
                      Column(
                        children: [
                          _buildEcosystemNode("📊 Weka ML", const Color(0xFFA855F7)),
                          const SizedBox(height: 10),
                          _buildEcosystemNode("💳 Pagos Stripe", const Color(0xFFEC4899)),
                          const SizedBox(height: 10),
                          _buildEcosystemNode("☁️ Cloud Sync", const Color(0xFF0EA5E9)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcosystemNode(String text, Color color, {bool isRoot = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isRoot ? 24 : 16, vertical: isRoot ? 12 : 10),
      decoration: BoxDecoration(
        color: isRoot ? color.withOpacity(0.2) : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isRoot ? 0.6 : 0.25),
          width: isRoot ? 1.5 : 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: isRoot ? 15 : 13,
          fontWeight: isRoot ? FontWeight.bold : FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 5. TECNOLOGÍAS UTILIZADAS
  // ═══════════════════════════════════════════════════════════
  Widget _buildTechnologiesSection() {
    final List<String> techList = [
      "Flutter",
      "Spring Boot",
      "MongoDB",
      "Stripe SDK",
      "Twilio SMS",
      "Groq AI",
      "Weka ML",
      "Java 17",
      "Docker",
      "Render Cloud"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Construido con tecnología moderna",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: techList.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Text(
                  tech,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 6. SEGURIDAD
  // ═══════════════════════════════════════════════════════════
  Widget _buildSecuritySection() {
    final List<String> securityItems = [
      "Información clínica cifrada",
      "Historial de vacunas seguro",
      "Autenticación OAuth2 moderna",
      "Base de datos blindada en la nube",
      "Privacidad de datos garantizada"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: _buildGlassContainer(
        borderRadius: 28,
        borderColor: _auroraBase.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tus datos están protegidos",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...securityItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: _auroraGlow, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _auroraBase.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded, color: _auroraGlow, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 7. ESTADÍSTICAS
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsSection() {
    final List<Map<String, String>> stats = [
      {"value": "+25", "label": "Servicios"},
      {"value": "+10", "label": "Módulos"},
      {"value": "24/7", "label": "Guido AI"},
      {"value": "100%", "label": "Sincronizado"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
        ),
        itemBuilder: (context, index) {
          final s = stats[index];
          return _buildGlassContainer(
            borderRadius: 20,
            borderColor: Colors.white.withOpacity(0.06),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s["value"]!,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s["label"]!,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 8. LÍNEA DE TIEMPO (CÓMO FUNCIONA)
  // ═══════════════════════════════════════════════════════════
  Widget _buildTimelineSection() {
    final List<Map<String, String>> steps = [
      {"num": "1", "title": "Registra a tu mascota", "desc": "Crea su perfil clínico con sus datos básicos, vacunas y raza."},
      {"num": "2", "title": "Encuentra una clínica", "desc": "Usa la búsqueda y mapas integrados para localizar centros médicos."},
      {"num": "3", "title": "Agenda tu cita", "desc": "Elige fecha, hora y realiza el pago de forma segura con Stripe."},
      {"num": "4", "title": "Recibe consejos de Guido AI", "desc": "Consulta con nuestro asistente clínico inteligente para un triaje preliminar."},
      {"num": "5", "title": "Todo se sincroniza", "desc": "Los historiales, recetas y vacunas se guardan de forma permanente en la nube."}
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Así funciona ClinicaApp",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ...steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [_auroraBase, _auroraDeep]),
                  ),
                  child: Center(
                    child: Text(
                      step["num"]!,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step["title"]!,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step["desc"]!,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white38,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 9. BENEFICIOS
  // ═══════════════════════════════════════════════════════════
  Widget _buildBenefitsSection() {
    final List<String> benefits = [
      "Todo el control clínico en tu bolsillo",
      "Evita largas esperas para consultas",
      "Atención primaria de Guido AI disponible 24 horas",
      "Recordatorios automáticos de vacunas y desparasitantes",
      "Acceso inmediato a recetas en formato PDF",
      "Predicción inteligente del cuidado de salud de tus mascotas"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Beneficios para ti y tu mascota",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    b,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 10. FOOTER ELEGANTE
  // ═══════════════════════════════════════════════════════════
  Widget _buildFooterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          Text(
            "🐾 ClinicaApp",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Innovando el cuidado veterinario con Inteligencia Artificial.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Versión 1.0 • Flutter • Spring Boot • Cloud Sync",
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "© 2026 Todos los derechos reservados.",
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GLASS CONTAINER BUILDER
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
}

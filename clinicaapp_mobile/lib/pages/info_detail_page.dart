import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';

class InfoDetailPage extends StatefulWidget {
  const InfoDetailPage({super.key});

  @override
  State<InfoDetailPage> createState() => _InfoDetailPageState();
}

class _InfoDetailPageState extends State<InfoDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Fondo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.6),
                radius: 1.5,
                colors: [
                  Color(0x1F0EA5E9),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  
                  // Ecosistema AI (Guido & Modelos de Predicción)
                  SliverToBoxAdapter(child: _buildAISec()),
                  
                  // Ecosistema de Servicios
                  SliverToBoxAdapter(child: _buildServicesSec()),

                  // Planes de Suscripción
                  SliverToBoxAdapter(child: _buildPlansSec()),

                  // Footer info
                  SliverToBoxAdapter(child: _buildFooter()),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
            style: IconButton.styleFrom(
              backgroundColor: _glassWhite,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          Text(
            "DESCUBRIR MÁS",
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _auroraGlow,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 48), // Espacio para balancear el botón de atrás
        ],
      ),
    );
  }

  Widget _buildAISec() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: _auroraBase, size: 28),
              const SizedBox(width: 12),
              Text(
                "Ecosistema de Inteligencia Artificial",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Integramos algoritmos de Machine Learning y procesamiento de lenguaje para el cuidado inteligente de tu mascota.",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Cards de IA
          _buildAICard(
            "Guido: Asistente Clínico",
            "Nuestra IA principal responde preguntas médicas de tu mascota las 24 horas y evalúa síntomas de manera experta.",
            Icons.chat_bubble_outline_rounded,
            const Color(0xFF818CF8),
          ),
          const SizedBox(height: 12),
          _buildAICard(
            "Weka: Diagnóstico Articular",
            "Modelo predictivo avanzado que calcula el riesgo de problemas articulares basándose en raza, peso y edad.",
            Icons.query_stats_rounded,
            const Color(0xFF34D399),
          ),
          const SizedBox(height: 12),
          _buildAICard(
            "Weka: Predicción de Citas",
            "Algoritmo preventivo que calcula la probabilidad de inasistencia (No-Show) en clínicas para optimizar los horarios.",
            Icons.event_busy_rounded,
            const Color(0xFFFBBF24),
          ),
        ],
      ),
    );
  }

  Widget _buildAICard(String title, String desc, IconData icon, Color color) {
    return _buildGlassContainer(
      borderRadius: 24,
      borderColor: Colors.white.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.white38,
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

  Widget _buildServicesSec() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: _auroraBase, size: 28),
              const SizedBox(width: 12),
              Text(
                "Servicios Médicos de Vanguardia",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildServiceGridItem("Telemedicina", Icons.videocam_rounded, "Videoconsultas en vivo con especialistas."),
              _buildServiceGridItem("Receta Digital", Icons.description_rounded, "Generación automática de PDFs con firma médica."),
              _buildServiceGridItem("Pago Seguro", Icons.credit_card_rounded, "Pasarela Stripe protegida y pagos en un toque."),
              _buildServiceGridItem("Vacunación", Icons.vaccines_rounded, "Control inteligente e historial completo."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGridItem(String title, IconData icon, String desc) {
    return _buildGlassContainer(
      borderRadius: 20,
      borderColor: Colors.white.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _auroraGlow, size: 26),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.white38,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansSec() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: _auroraBase, size: 28),
              const SizedBox(width: 12),
              Text(
                "Planes de Cuidado a Medida",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPlanCard(
            "Plan Bronce",
            "$19.99 / mes",
            ["Atención 24/7 de Guido AI", "Historial clínico en la nube", "Buscador de clínicas"],
            Colors.brown.shade300,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            "Plan Plata",
            "$39.99 / mes",
            ["Todo lo de Bronce", "Telemedicina ilimitada", "Prioridad en agendamiento", "Recordatorios inteligentes"],
            Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            "Plan Oro",
            "$59.99 / mes",
            ["Todo lo de Plata", "Acceso premium a especialistas", "Weka Predictivo ilimitado", "Soporte VIP inmediato"],
            const Color(0xFFFBBF24),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String name, String price, List<String> features, Color color) {
    return _buildGlassContainer(
      borderRadius: 24,
      borderColor: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: color.withOpacity(0.7), size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
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
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.pets, color: Colors.white12, size: 40),
            const SizedBox(height: 10),
            Text(
              "ClinicaApp Mobile • Ecosistema Digital VetZone\n© 2026 Todos los derechos reservados.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.white24,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
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

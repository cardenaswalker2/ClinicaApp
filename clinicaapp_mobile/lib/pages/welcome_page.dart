import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'info_detail_page.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Cuidado\nExcepcional",
      "subtitle": "Salud Veterinaria",
      "desc": "Centraliza historiales clínicos, vacunas, recetas y citas de tus mascotas en un solo lugar.",
      "icon": Icons.favorite_rounded,
      "color": AppleTheme.blue,
    },
    {
      "title": "Nova AI:\nAsistente 24/7",
      "subtitle": "Inteligencia Clínica",
      "desc": "Resuelve dudas sobre síntomas, consulta servicios y agenda citas en segundos con nuestra IA.",
      "icon": Icons.auto_awesome_rounded,
      "color": AppleTheme.purple,
    },
    {
      "title": "Clínica Óptima\nal Instante",
      "subtitle": "Geolocalización PLEB",
      "desc": "Calculamos automáticamente la clínica abierta más cercana en Cartagena desde tu ubicación.",
      "icon": Icons.near_me_rounded,
      "color": AppleTheme.green,
    },
  ];

  final List<Map<String, dynamic>> _whyChooseUs = [
    {
      "title": "Gestión de Mascotas",
      "desc": "Perfiles completos con historial médico, álbum de fotos y evaluación Weka.",
      "icon": Icons.pets_rounded,
      "color": AppleTheme.blue,
    },
    {
      "title": "Clínicas Verificadas",
      "desc": "Directorio completo con horarios, urgencias 24h y reseñas de tutores.",
      "icon": Icons.local_hospital_rounded,
      "color": AppleTheme.green,
    },
    {
      "title": "Pagos y Facturas PDF",
      "desc": "Pagos seguros en línea con Stripe y descarga inmediata de comprobantes.",
      "icon": Icons.receipt_long_rounded,
      "color": AppleTheme.indigo,
    },
  ];

  final List<Map<String, String>> _steps = [
    {"num": "1", "title": "Crea tu perfil", "desc": "Registra tus datos y el carnet digital de cada mascota."},
    {"num": "2", "title": "Encuentra sede", "desc": "Usa el optimizador PLEB para hallar la clínica abierta más cercana."},
    {"num": "3", "title": "Gestiona todo", "desc": "Agenda citas, recibe alertas y consulta con Nova AI 24/7."},
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {
      "name": "María Fernanda R.",
      "zone": "Manga, Cartagena",
      "text": "Encontré una clínica abierta a las 11 p.m. en menos de 2 minutos. Súper fácil de usar.",
    },
    {
      "name": "Carlos Andrés V.",
      "zone": "Bocagrande",
      "text": "Tener todas las vacunas e historial de Max en el celular nos salvó en el viaje.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header limpio estilo Apple
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppleTheme.blue, AppleTheme.indigo],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppleTheme.blue.withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.pets_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ClinicaApp",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppleTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Salud Animal • Cartagena",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppleTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _goToLogin,
                      style: TextButton.styleFrom(
                        backgroundColor: AppleTheme.blue.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(
                        "Entrar",
                        style: GoogleFonts.plusJakartaSans(
                          color: AppleTheme.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Banner Fotográfico Editorial estilo Apple App Store
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
                child: AppleCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 190,
                              width: double.infinity,
                              child: Image.network(
                                "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=900&q=80",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.pets_rounded, color: Colors.white, size: 64),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              top: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded, color: AppleTheme.blue, size: 15),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Plataforma Veterinaria #1",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppleTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "El amor por ellos nos une",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: AppleTheme.textPrimary,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Todo el historial médico, citas, urgencias y asistencia con inteligencia artificial en la palma de tu mano.",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppleTheme.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Carrusel Onboarding
            SliverToBoxAdapter(
              child: SizedBox(
                height: 270,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final item = _onboardingData[index];
                    final color = item["color"] as Color;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
                      child: AppleCard(
                        padding: const EdgeInsets.all(22),
                        borderRadius: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppleBadge(text: item["subtitle"], color: color),
                                AppleIconBox(
                                  icon: item["icon"] as IconData,
                                  color: color,
                                  size: 46,
                                  iconSize: 23,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppleTheme.textPrimary,
                                    height: 1.15,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item["desc"],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    color: AppleTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Indicadores de página estilo iOS
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_onboardingData.length, (index) {
                  final active = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? AppleTheme.blue : AppleTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Cómo funciona en 3 pasos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppleSectionHeader(title: "¿Cómo funciona?"),
                    const SizedBox(height: 12),
                    AppleCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _steps.asMap().entries.map((entry) {
                          final i = entry.key;
                          final s = entry.value;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppleTheme.blue.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      s["num"]!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        color: AppleTheme.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s["title"]!, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                                        Text(s["desc"]!, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppleTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (i < _steps.length - 1) const Divider(height: 20),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Servicios clave
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppleSectionHeader(title: "Todo en un solo lugar"),
                    const SizedBox(height: 12),
                    ..._whyChooseUs.map((item) {
                      final color = item["color"] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppleCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InfoDetailPage(
                                  title: item["title"],
                                  description: item["desc"],
                                  icon: item["icon"] as IconData,
                                  color: color,
                                ),
                              ),
                            );
                          },
                          padding: const EdgeInsets.all(14),
                          borderRadius: 18,
                          child: Row(
                            children: [
                              AppleIconBox(icon: item["icon"] as IconData, color: color),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["title"],
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppleTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item["desc"],
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        color: AppleTheme.textSecondary,
                                      ),
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

            // Testimonios reales
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppleSectionHeader(title: "Tutores en Cartagena"),
                    const SizedBox(height: 12),
                    ..._testimonials.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppleCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(t["name"]!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (_) => const Icon(Icons.star_rounded, color: AppleTheme.orange, size: 15),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(t["zone"]!, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppleTheme.blue, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text(t["text"]!, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppleTheme.textSecondary, height: 1.4)),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Botón principal CTA
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                child: AppleButton(
                  text: "Comenzar ahora",
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _goToLogin,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

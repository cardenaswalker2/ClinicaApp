import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'login_page.dart';
import 'info_detail_page.dart';

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
      "desc": "Conectamos a tu mascota con una red de especialistas médicos, historiales digitales y atención de primer nivel.",
      "icon": Icons.favorite_rounded,
      "color": AppleTheme.blue,
    },
    {
      "title": "Nova AI:\nAsistente 24/7",
      "subtitle": "Inteligencia Clínica",
      "desc": "Recibe orientación inmediata, resuelve dudas sobre síntomas y consulta horarios con nuestro asistente inteligente.",
      "icon": Icons.auto_awesome_rounded,
      "color": AppleTheme.purple,
    },
    {
      "title": "Clínica Óptima\nal Instante",
      "subtitle": "Geolocalización PLEB",
      "desc": "Encuentra la clínica abierta más cercana en Cartagena con cálculo exacto de distancia y agendamiento directo.",
      "icon": Icons.location_on_rounded,
      "color": AppleTheme.green,
    },
  ];

  final List<Map<String, dynamic>> _statsData = [
    {"value": "+15", "label": "Clínicas", "icon": Icons.local_hospital_rounded, "color": AppleTheme.blue},
    {"value": "24/7", "label": "Nova AI", "icon": Icons.smart_toy_rounded, "color": AppleTheme.purple},
    {"value": "4.9★", "label": "Valoración", "icon": Icons.star_rounded, "color": AppleTheme.orange},
  ];

  final List<Map<String, dynamic>> _whyChooseUs = [
    {
      "title": "Gestión de Mascotas",
      "desc": "Perfiles completos con historial médico, vacunas y recordatorios.",
      "icon": Icons.pets_rounded,
      "color": AppleTheme.blue,
    },
    {
      "title": "Clínicas Cercanas",
      "desc": "Encuentra las clínicas veterinarias disponibles con optimización PLEB.",
      "icon": Icons.near_me_rounded,
      "color": AppleTheme.green,
    },
    {
      "title": "Recordatorios Inteligentes",
      "desc": "Alertas personalizadas para vacunas, citas y tratamientos.",
      "icon": Icons.notifications_active_rounded,
      "color": AppleTheme.orange,
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppleTheme.blue,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "ClinicaApp",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppleTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        "Iniciar sesión",
                        style: GoogleFonts.plusJakartaSans(
                          color: AppleTheme.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Carrusel Onboarding
            SliverToBoxAdapter(
              child: SizedBox(
                height: 390,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final item = _onboardingData[index];
                    final color = item["color"] as Color;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      child: AppleCard(
                        padding: const EdgeInsets.all(28),
                        borderRadius: 28,
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
                                  size: 52,
                                  iconSize: 26,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: AppleTheme.textPrimary,
                                    height: 1.12,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item["desc"],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    color: AppleTheme.textSecondary,
                                    height: 1.45,
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

            // Estadísticas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: _statsData.map((s) {
                    final color = s["color"] as Color;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AppleCard(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                          borderRadius: 18,
                          child: Column(
                            children: [
                              Icon(s["icon"] as IconData, color: color, size: 22),
                              const SizedBox(height: 8),
                              Text(
                                s["value"],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppleTheme.textPrimary,
                                ),
                              ),
                              Text(
                                s["label"],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppleTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Por qué elegirnos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
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
                                        fontSize: 13,
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

            // Botón principal CTA
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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

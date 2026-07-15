import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dashboard_page.dart';
import 'clinic_explorer_page.dart';
import 'appointments_page.dart';
import 'profile_page.dart';
import 'ai_chat_page.dart';
import 'shop_page.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// MAIN NAVIGATION PAGE - LUXURY AURORA EDITION
// Lógica de navegación 100% funcional y diseño Premium restaurado
// ============================================================

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _index = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ClinicExplorerPage(),
    const AIChatPage(),
    const AppointmentsPage(),
    const ProfilePage(),
  ];

  late AnimationController _aurora;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late PageController _pageController;

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _bgDark = Color(0xFF020617);

  final List<Map<String, dynamic>> _navItems = [
    {"icon": Icons.home_filled, "label": "Inicio", "color": Color(0xFF0EA5E9)},
    {"icon": Icons.local_hospital_rounded, "label": "Clínicas", "color": Colors.greenAccent},
    {"icon": Icons.smart_toy_rounded, "label": "Guido AI", "color": Colors.purpleAccent},
    {"icon": Icons.calendar_month_rounded, "label": "Citas", "color": Colors.orangeAccent},
    {"icon": Icons.person_rounded, "label": "Perfil", "color": Colors.pinkAccent},
  ];

  @override
  void initState() {
    super.initState();
    _aurora = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _aurora.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int idx) {
    setState(() => _index = idx);
  }

  void _onNavTap(int idx) {
    if (_index == idx) return;
    setState(() => _index = idx);
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          _buildBackground(),
          _buildFloatingOrbs(),
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

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

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        _buildOrb(top: -100, left: -80, size: 400, color: _auroraBase.withOpacity(0.03), blur: 80),
        _buildOrb(bottom: 200, right: -100, size: 350, color: const Color(0xFF818CF8).withOpacity(0.02), blur: 100),
      ],
    );
  }

  Widget _buildOrb({double? top, double? left, double? right, double? bottom, required double size, required Color color, required double blur}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              math.sin(_floatController.value * math.pi) * 15,
              math.cos(_floatController.value * math.pi) * 20,
            ),
            child: Container(
              width: size, height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [color, color.withOpacity(0.0)]),
                boxShadow: [BoxShadow(color: color, blurRadius: blur, spreadRadius: size * 0.1)],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45),
                boxShadow: [
                  BoxShadow(
                    color: _auroraBase.withOpacity(0.05 + _glowController.value * 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(45),
                      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _navItems.asMap().entries.map((entry) {
                        return _buildNavItem(
                          icon: entry.value["icon"] as IconData,
                          idx: entry.key,
                          label: entry.value["label"] as String,
                          color: entry.value["color"] as Color,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int idx, required String label, required Color color}) {
    final isSelected = _index == idx;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNavTap(idx),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(isSelected ? 10 : 0),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
                      blurRadius: isSelected ? 15 : 0,
                      spreadRadius: isSelected ? 2 : 0,
                    )
                  ],
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : Colors.white.withOpacity(0.35),
                  size: isSelected ? 26 : 22,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isSelected ? 16 : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      label,
                      style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              // ── Indicador de punto Premium ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 2),
                width: isSelected ? 4 : 0,
                height: isSelected ? 4 : 0,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
                      blurRadius: isSelected ? 4 : 0,
                      spreadRadius: isSelected ? 1 : 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

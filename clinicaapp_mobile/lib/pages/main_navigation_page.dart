import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/apple_theme.dart';
import 'dashboard_page.dart';
import 'clinic_explorer_page.dart';
import 'appointments_page.dart';
import 'profile_page.dart';
import 'ai_chat_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _index = 0;
  late final PageController _pageController;

  final List<Widget> _pages = const [
    DashboardPage(),
    ClinicExplorerPage(),
    AIChatPage(),
    AppointmentsPage(),
    ProfilePage(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {"icon": Icons.home_rounded, "label": "Inicio", "color": AppleTheme.blue},
    {"icon": Icons.local_hospital_rounded, "label": "Clínicas", "color": AppleTheme.green},
    {"icon": Icons.auto_awesome_rounded, "label": "Nova AI", "color": AppleTheme.purple},
    {"icon": Icons.calendar_month_rounded, "label": "Citas", "color": AppleTheme.orange},
    {"icon": Icons.person_rounded, "label": "Perfil", "color": AppleTheme.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int idx) {
    if (_index == idx) return;
    setState(() => _index = idx);
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppleTheme.bg,
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) => setState(() => _index = idx),
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _buildAppleBottomBar(),
    );
  }

  Widget _buildAppleBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppleTheme.border, width: 0.9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_navItems.length, (idx) {
                    final item = _navItems[idx];
                    final isSelected = _index == idx;
                    final color = item["color"] as Color;
                    return Expanded(
                      child: InkWell(
                        onTap: () => _onNavTap(idx),
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                item["icon"] as IconData,
                                color: isSelected ? color : AppleTheme.textTertiary,
                                size: 23,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["label"] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? color : AppleTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

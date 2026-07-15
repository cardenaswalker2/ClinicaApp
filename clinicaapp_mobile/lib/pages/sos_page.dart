import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage>
    with SingleTickerProviderStateMixin {
  // ─── Luxury Aurora Palette ───
  static const Color _emergencyRed = Color(0xFFEF4444);
  static const Color _emergencyGlow = Color(0xFFF87171);
  static const Color _bgDeep = Color(0xFF020617);
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraAccent = Color(0xFF22D3EE);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ─── Números actualizados ───
  static const String _urgenciasVet = "3005722844";
  static const String _ambulanciaAnimal = "3135677740";

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Lógica original preservada ───
  Future<void> _makeCall(String number) async {
    HapticFeedback.vibrate();
    final Uri url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDeep,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ─── Emergency Aurora Orbs ───
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _emergencyRed.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _emergencyRed.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ─── Pulsing Emergency Glow ───
          Positioned(
            top: 60,
            right: 40,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _emergencyRed.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: _emergencyRed.withOpacity(0.4),
                          blurRadius: 30 * value,
                          spreadRadius: 10 * value,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // ─── Main Content ───
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildAppBar(context),
                      const SizedBox(height: 40),
                      _buildEmergencyHeader(),
                      const SizedBox(height: 32),
                      Text(
                        "Contactos de emergencia",
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildEmergencyContact(
                        "Urgencias Veterinarias 24h",
                        "Clínica San Francisco",
                        _urgenciasVet,
                        Icons.local_hospital_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildEmergencyContact(
                        "Ambulancia Animal",
                        "Servicio de Rescate",
                        _ambulanciaAnimal,
                        Icons.emergency_rounded,
                      ),
                      const Spacer(),
                      _buildMainCallButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widgets Luxury ───

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        _buildGlassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _emergencyRed.withOpacity(0.2),
                _emergencyRed.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _emergencyRed.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _emergencyRed,
                  boxShadow: [
                    BoxShadow(
                      color: _emergencyRed.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "EN VIVO",
                style: GoogleFonts.outfit(
                  color: _emergencyRed,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Animated Emergency Icon ───
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _emergencyRed.withOpacity(0.3),
                      _emergencyRed.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _emergencyRed.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _emergencyRed.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.emergency_rounded,
                  color: _emergencyRed,
                  size: 48,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        // ─── Title with Glow ───
        Text(
          "Centro de Emergencias",
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_emergencyRed, _emergencyGlow],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: _emergencyRed.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Si tu mascota está en peligro crítico, contacta de inmediato con una clínica de urgencias 24h.",
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.white.withOpacity(0.5),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContact(
    String type,
    String name,
    String phone,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _makeCall(phone),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _emergencyRed.withOpacity(0.2),
                          _emergencyRed.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _emergencyRed.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: _emergencyRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: GoogleFonts.outfit(
                            color: _emergencyRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phone,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.vibrate();
                      _makeCall(phone);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _emergencyRed.withOpacity(0.3),
                            _emergencyRed.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _emergencyRed.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _emergencyRed.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.call_rounded,
                        color: _emergencyRed,
                        size: 20,
                      ),
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

  Widget _buildMainCallButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        _makeCall("123");
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_emergencyRed, _emergencyGlow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _emergencyRed.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 4,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: _emergencyGlow.withOpacity(0.3),
              blurRadius: 50,
              spreadRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                _makeCall("123");
              },
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "LLAMAR A URGENCIAS",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
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
      ),
    );
  }
}
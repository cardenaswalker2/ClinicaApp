import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import '../config/app_config.dart';
import 'main_navigation_page.dart';
import 'register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ============================================================
// LOGIN PAGE - LUXURY AURORA EDITION
// Lógica de autenticación 100% preservada
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════
  // CONTROLLERS & STATE - LÓGICA ORIGINAL PRESERVADA
  // ═══════════════════════════════════════════════════════════
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // ── Animaciones ──
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  // ── FocusNodes para efectos de campo ──
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _emailFocused = false;
  bool _passFocused = false;

  // ── Colores Luxury Aurora ──
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);
  static const Color _glassWhite = Color(0x0DFFFFFF);

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

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Listeners para efectos de focus
    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passFocus.addListener(() => setState(() => _passFocused = _passFocus.hasFocus));
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _bgController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // LÓGICA DE LOGIN - 100% ORIGINAL, SIN MODIFICACIONES
  // ═══════════════════════════════════════════════════════════

  Future<void> _login() async {
    // Validación de campos vacíos
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      _showSnackBar("Por favor completa todos los campos");
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": _email.text.trim(),
          "password": _pass.text,
        }),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 200 && data['success']) {
        AppConfig.userEmail = data['email'];
        AppConfig.userName = data['nombre'];
        AppConfig.userId = data['id'];
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationPage(),
            ),
          );
        }
      } else {
        if (mounted) {
          _showSnackBar(data['message'] ?? "Error de autenticación");
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error de conexión");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    try {
      // Forzar que Google siempre muestre el selector de cuentas
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Ignorar si no había sesión iniciada
      }
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": googleUser.email,
          "nombre": googleUser.displayName ?? "Usuario Google",
        }),
      );

      final data = json.decode(res.body);
      if (res.statusCode == 200 && data['success']) {
        AppConfig.userEmail = data['email'];
        AppConfig.userName = data['nombre'];
        AppConfig.userId = data['id'];
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationPage(),
            ),
          );
        }
      } else {
        if (mounted) {
          _showSnackBar(data['message'] ?? "Error de autenticación con Google");
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error al conectar con Google: $e");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          softWrap: true,
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: _surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Fondo Aurora Animado ──
          _buildLuxuryBackground(),
          // ── Orbes flotantes ──
          _buildFloatingOrbs(),
          // ── Contenido Principal ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // ── Logo Animado ──
                    _buildAnimatedLogo(),
                    const SizedBox(height: 50),
                    // ── Card de Login con Glassmorphism ──
                    _buildLoginCard(),
                    const SizedBox(height: 60),
                  ],
                ),
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
          top: -150,
          left: -100,
          size: 500,
          color: _auroraBase.withOpacity(0.04),
          blur: 100,
        ),
        _buildOrb(
          bottom: -100,
          right: -150,
          size: 450,
          color: const Color(0xFF818CF8).withOpacity(0.03),
          blur: 120,
        ),
        _buildOrb(
          top: 200,
          right: -80,
          size: 280,
          color: _auroraGlow.withOpacity(0.03),
          blur: 80,
        ),
        _buildOrb(
          bottom: 200,
          left: -60,
          size: 320,
          color: _auroraBase.withOpacity(0.02),
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
              math.sin(_floatController.value * math.pi) * 20,
              math.cos(_floatController.value * math.pi) * 25,
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
                    spreadRadius: size * 0.08,
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
  // LOGO ANIMADO CON HALO
  // ═══════════════════════════════════════════════════════════

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Column(
          children: [
            // Halo exterior pulsante
            Container(
              width: 120,
              height: 120,
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
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _auroraBase.withOpacity(0.2 + _pulseController.value * 0.1),
                        _auroraBase.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _auroraBase.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: _auroraBase,
                    size: 45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Título
            Text(
              "Clínica App",
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Bienvenido de nuevo",
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE LOGIN CON GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════

  Widget _buildLoginCard() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _auroraBase.withOpacity(0.05),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Campo Email ──
                          _buildTextField(
                            controller: _email,
                            hint: "Email",
                            icon: Icons.email_outlined,
                            focusNode: _emailFocus,
                            isFocused: _emailFocused,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (val) => _passFocus.requestFocus(),
                          ),
                          const SizedBox(height: 20),
                          // ── Campo Password ──
                          _buildTextField(
                            controller: _pass,
                            hint: "Contraseña",
                            icon: Icons.lock_outline,
                            focusNode: _passFocus,
                            isFocused: _passFocused,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (val) => _login(),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white38,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ── Remember Me & Forgot Password ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildRememberMe(),
                              Flexible(
                                child: _buildTextButton("¿Olvidaste tu contraseña?", () {}),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // ── Botón Login ──
                          _buildLoginButton(),
                          const SizedBox(height: 24),
                          // ── Divider ──
                          _buildDivider(),
                          const SizedBox(height: 24),
                          // ── Google Login ──
                          _buildGoogleButton(),
                          const SizedBox(height: 24),
                          const SizedBox(height: 24),
                          // ── Registro ──
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "¿No tienes cuenta? ",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white38,
                                    fontSize: 14,
                                  ),
                                ),
                                _buildTextButton("Regístrate", () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
  // TEXTFIELD PREMIUM CON EFECTOS
  // ═══════════════════════════════════════════════════════════

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required FocusNode focusNode,
    required bool isFocused,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    Widget? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: isFocused
            ? LinearGradient(
                colors: [
                  _auroraBase.withOpacity(0.08),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFocused
              ? _auroraBase.withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: _auroraBase.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              color: isFocused ? _auroraBase : Colors.white38,
              size: 22,
            ),
          ),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
            color: Colors.white24,
            fontSize: 15,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // REMEMBER ME
  // ═══════════════════════════════════════════════════════════

  Widget _buildRememberMe() {
    return GestureDetector(
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: _rememberMe
                  ? const LinearGradient(
                      colors: [_auroraBase, _auroraGlow],
                    )
                  : null,
              color: _rememberMe ? null : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: _rememberMe
                    ? _auroraBase
                    : Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: _rememberMe
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            "Recordarme",
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.50),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTÓN LOGIN PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
              onTap: _loading ? null : _login,
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              child: Center(
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Entrar",
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
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
                                  size: 20,
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
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DIVIDER CON EFECTO
  // ═══════════════════════════════════════════════════════════

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "o",
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.20),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TEXT BUTTON ESTILIZADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildTextButton(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _auroraBase,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _loading ? null : _loginWithGoogle,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Image.network(
                  'https://www.gstatic.com/images/branding/product/1x/googleg_48dp.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Ingresar con Gmail",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'main_navigation_page.dart';
import 'register_page.dart';
import 'welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _backToWelcome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    }
  }

  Future<void> _login() async {
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
      if (res.statusCode == 200 && data['success'] == true) {
        AppConfig.userEmail = data['email'];
        AppConfig.userName = data['nombre'];
        AppConfig.userId = data['id'];
        AppConfig.userRole = data['role'] ?? "ROLE_USER";
        await AppConfig.saveSession();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          );
        }
      } else {
        if (mounted) _showSnackBar(data['message'] ?? "Error de autenticación");
      }
    } catch (_) {
      if (mounted) _showSnackBar("Error de conexión con el servidor");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    try {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _loading = false);
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
      if (res.statusCode == 200 && data['success'] == true) {
        AppConfig.userEmail = data['email'];
        AppConfig.userName = data['nombre'];
        AppConfig.userId = data['id'];
        AppConfig.userRole = data['role'] ?? "ROLE_USER";
        await AppConfig.saveSession();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          );
        }
      } else {
        if (mounted) _showSnackBar(data['message'] ?? "Error de autenticación con Google");
      }
    } catch (_) {
      if (mounted) _showSnackBar("Error al conectar con Google");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Botón para volver a WelcomePage
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _backToWelcome,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: AppleTheme.blue),
                  label: Text(
                    "Inicio",
                    style: GoogleFonts.plusJakartaSans(
                      color: AppleTheme.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Logo 3D suave estilo Apple App Icon
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppleTheme.blue, AppleTheme.indigo],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppleTheme.blue.withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.pets_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 18),
              Text(
                "Bienvenido de vuelta",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: AppleTheme.textPrimary,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Inicia sesión en ClinicaApp para cuidar de tu mascota",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  color: AppleTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 26),

              // Tarjeta blanca de formulario
              AppleCard(
                padding: const EdgeInsets.all(22),
                borderRadius: 26,
                child: Column(
                  children: [
                    AppleTextField(
                      controller: _email,
                      label: "Correo electrónico",
                      hint: "ejemplo@correo.com",
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    AppleTextField(
                      controller: _pass,
                      label: "Contraseña",
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppleTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse("${AppConfig.webBaseUrl}/forgot-password");
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          "¿Olvidaste tu contraseña?",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppleTheme.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppleButton(
                      text: "Iniciar sesión",
                      isLoading: _loading,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppleTheme.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "o continúa con",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppleTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppleTheme.divider)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppleButton(
                      text: "Continuar con Google",
                      icon: Icons.g_mobiledata_rounded,
                      outlined: true,
                      backgroundColor: AppleTheme.textPrimary,
                      onPressed: _loading ? null : _loginWithGoogle,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿No tienes cuenta? ",
                    style: GoogleFonts.plusJakartaSans(
                      color: AppleTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: Text(
                      "Regístrate gratis",
                      style: GoogleFonts.plusJakartaSans(
                        color: AppleTheme.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

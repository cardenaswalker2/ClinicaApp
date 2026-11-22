import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'main_navigation_page.dart';
import 'register_page.dart';

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
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          );
        }
      } else {
        if (mounted) _showSnackBar(data['message'] ?? "Error de autenticación");
      }
    } catch (e) {
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
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          );
        }
      } else {
        if (mounted) _showSnackBar(data['message'] ?? "Error de autenticación con Google");
      }
    } catch (e) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Logo estilo App Icon de Apple
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppleTheme.blue,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppleTheme.blue.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.pets_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 20),
              Text(
                "Bienvenido a ClinicaApp",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppleTheme.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Inicia sesión para gestionar la salud de tu mascota",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppleTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Tarjeta blanca de formulario
              AppleCard(
                padding: const EdgeInsets.all(22),
                borderRadius: 24,
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
                    const SizedBox(height: 22),
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

              const SizedBox(height: 24),
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
                      "Regístrate aquí",
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

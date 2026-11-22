import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty || _name.text.trim().isEmpty) {
      _showSnackBar("Por favor completa los campos obligatorios");
      return;
    }

    if (_pass.text != _confirmPass.text) {
      _showSnackBar("Las contraseñas no coinciden");
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nombre": _name.text.trim(),
          "apellido": _lastName.text.trim(),
          "email": _email.text.trim(),
          "telefono": _phone.text.trim(),
          "password": _pass.text,
        }),
      );

      final data = json.decode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        _showSnackBar("¡Registro exitoso! Ahora puedes iniciar sesión.");
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showSnackBar(data['message'] ?? "Error al registrar");
      }
    } catch (e) {
      _showSnackBar("Error de conexión");
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
      appBar: AppBar(
        title: const Text("Crear cuenta"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Únete a ClinicaApp",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppleTheme.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Crea tu perfil para cuidar mejor de tus mascotas.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppleTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              AppleCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Column(
                  children: [
                    AppleTextField(
                      controller: _name,
                      label: "Nombre *",
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    AppleTextField(
                      controller: _lastName,
                      label: "Apellido",
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppleTextField(
                      controller: _email,
                      label: "Correo electrónico *",
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    AppleTextField(
                      controller: _phone,
                      label: "Teléfono",
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    AppleTextField(
                      controller: _pass,
                      label: "Contraseña *",
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
                    const SizedBox(height: 14),
                    AppleTextField(
                      controller: _confirmPass,
                      label: "Confirmar contraseña *",
                      prefixIcon: Icons.lock_reset_rounded,
                      obscureText: _obscurePassword,
                    ),
                    const SizedBox(height: 22),
                    AppleButton(
                      text: "Registrarme",
                      isLoading: _loading,
                      onPressed: _register,
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

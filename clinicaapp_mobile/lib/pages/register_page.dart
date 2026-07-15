import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import '../config/app_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  // Animaciones
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _slideController;

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _bgDark = Color(0xFF020617);

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

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _name.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    _confirmPass.dispose();
    _bgController.dispose();
    _floatController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty || _name.text.isEmpty) {
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
      if (res.statusCode == 200 && data['success']) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, softWrap: true, style: GoogleFonts.outfit()),
        backgroundColor: _bgDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          _buildBackground(),
          _buildFloatingOrbs(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Crea tu cuenta",
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Únete a nuestra familia veterinaria",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildForm(),
                  const SizedBox(height: 30),
                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
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
                HSLColor.fromAHSL(1.0, hue, 0.6, 0.1).toColor(),
                _bgDark,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        _buildOrb(top: -100, right: -50, size: 300, color: _auroraBase.withOpacity(0.05)),
        _buildOrb(bottom: 100, left: -80, size: 400, color: _auroraDeep.withOpacity(0.03)),
      ],
    );
  }

  Widget _buildOrb({double? top, double? left, double? right, double? bottom, required double size, required Color color}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * math.sin(_floatController.value * math.pi)),
            child: Container(
              width: size, height: size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(_name, "Nombre", Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(_lastName, "Apellido", Icons.badge_outlined),
        const SizedBox(height: 16),
        _buildTextField(_email, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildTextField(_phone, "Teléfono", Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField(_pass, "Contraseña", Icons.lock_outline, obscureText: true),
        const SizedBox(height: 16),
        _buildTextField(_confirmPass, "Confirmar Contraseña", Icons.lock_clock_outlined, obscureText: true),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscureText = false, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText && _obscurePassword,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _auroraBase, size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [_auroraBase, _auroraDeep]),
        boxShadow: [BoxShadow(color: _auroraBase.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _loading ? null : _register,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Registrarse",
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}

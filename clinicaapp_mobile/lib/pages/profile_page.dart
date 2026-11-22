import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'admin_dashboard_page.dart';
import 'appointments_page.dart';
import 'clinic_optimization_page.dart';
import 'community_page.dart';
import 'login_page.dart';
import 'my_pets_page.dart';
import 'notifications_page.dart';
import 'payments_page.dart';
import 'pet_quiz_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _petCount = 0;
  int _appointmentCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (AppConfig.userEmail == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final petsRes = await http.get(Uri.parse("${AppConfig.baseUrl}/mascotas/usuario/${AppConfig.userEmail}"));
      final citasRes = await http.get(Uri.parse("${AppConfig.baseUrl}/citas/usuario/${AppConfig.userEmail}"));
      if (mounted) {
        setState(() {
          if (petsRes.statusCode == 200) {
            _petCount = (json.decode(petsRes.body) as List).length;
          }
          if (citasRes.statusCode == 200) {
            _appointmentCount = (json.decode(citasRes.body) as List).length;
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AppConfig.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _editProfileDialog() async {
    final nameCtrl = TextEditingController(text: AppConfig.userName ?? '');
    final lastCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final dirCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/auth/perfil/${AppConfig.userEmail}"));
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        nameCtrl.text = d['nombre'] ?? nameCtrl.text;
        lastCtrl.text = d['apellido'] ?? '';
        phoneCtrl.text = d['telefono'] ?? '';
        dirCtrl.text = d['direccion'] ?? '';
      }
    } catch (_) {}

    if (!mounted) return;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppleTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(22, 20, 22, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Editar Perfil", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                AppleTextField(controller: nameCtrl, label: "Nombre *", prefixIcon: Icons.person_outline_rounded),
                const SizedBox(height: 10),
                AppleTextField(controller: lastCtrl, label: "Apellido", prefixIcon: Icons.badge_outlined),
                const SizedBox(height: 10),
                AppleTextField(controller: phoneCtrl, label: "Teléfono", prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                AppleTextField(controller: dirCtrl, label: "Dirección", prefixIcon: Icons.location_on_outlined),
                const SizedBox(height: 10),
                AppleTextField(controller: passCtrl, label: "Nueva contraseña (opcional)", prefixIcon: Icons.lock_outline_rounded, obscureText: true),
                const SizedBox(height: 18),
                AppleButton(
                  text: "Guardar en Servidor",
                  isLoading: saving,
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    setModal(() => saving = true);
                    try {
                      final res = await http.put(
                        Uri.parse("${AppConfig.baseUrl}/auth/perfil/${AppConfig.userEmail}"),
                        headers: {"Content-Type": "application/json"},
                        body: json.encode({
                          "nombre": nameCtrl.text.trim(),
                          "apellido": lastCtrl.text.trim(),
                          "telefono": phoneCtrl.text.trim(),
                          "direccion": dirCtrl.text.trim(),
                          if (passCtrl.text.isNotEmpty) "password": passCtrl.text,
                        }),
                      );
                      if (res.statusCode == 200) {
                        setState(() => AppConfig.userName = nameCtrl.text.trim());
                        await AppConfig.saveSession();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil actualizado en MongoDB")));
                        }
                      }
                    } catch (_) {}
                    if (ctx.mounted) setModal(() => saving = false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = AppConfig.userName ?? "Usuario";
    final email = AppConfig.userEmail ?? "correo@clinicaapp.com";
    final isAdmin = (AppConfig.userRole ?? "").toUpperCase().contains("ADMIN");
    final initials = name.isNotEmpty ? name.trim()[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Perfil",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppleTheme.textPrimary,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 16),

              // Tarjeta de usuario estilo Apple ID
              AppleCard(
                padding: const EdgeInsets.all(18),
                borderRadius: 22,
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppleTheme.blue.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppleTheme.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppleTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: AppleTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AppleBadge(
                            text: isAdmin ? "Administrador" : "Tutor Activo",
                            color: isAdmin ? AppleTheme.purple : AppleTheme.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: AppleCard(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPetsPage())),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            _loading ? "-" : "$_petCount",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppleTheme.blue,
                            ),
                          ),
                          Text(
                            "Mascotas",
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppleTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppleCard(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsPage())),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            _loading ? "-" : "$_appointmentCount",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppleTheme.orange,
                            ),
                          ),
                          Text(
                            "Citas",
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppleTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lista agrupada estilo iOS Settings
              const AppleSectionHeader(title: "Mi Cuenta y Servicios"),
              const SizedBox(height: 10),
              AppleCard(
                padding: EdgeInsets.zero,
                borderRadius: 20,
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.person_outline_rounded,
                      color: AppleTheme.blue,
                      title: "Editar Perfil",
                      onTap: _editProfileDialog,
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsRow(
                      icon: Icons.pets_rounded,
                      color: AppleTheme.blue,
                      title: "Mis Mascotas",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPetsPage())),
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsRow(
                      icon: Icons.favorite_rounded,
                      color: AppleTheme.red,
                      title: "Comunidad Pet & Adopciones",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityPage())),
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsRow(
                      icon: Icons.sports_esports_rounded,
                      color: AppleTheme.teal,
                      title: "Mascota Virtual & Quiz",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PetQuizPage())),
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsRow(
                      icon: Icons.receipt_long_rounded,
                      color: AppleTheme.indigo,
                      title: "Historial de Pagos y Facturas",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsPage())),
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsRow(
                      icon: Icons.near_me_rounded,
                      color: AppleTheme.green,
                      title: "Optimizador de Clínicas (PLEB)",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicOptimizationPage())),
                    ),
                    const Divider(height: 1, indent: 64),
                    _SettingsRow(
                      icon: Icons.notifications_rounded,
                      color: AppleTheme.orange,
                      title: "Notificaciones",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
                    ),
                    if (isAdmin) ...[
                      const Divider(height: 1, indent: 64),
                      _SettingsRow(
                        icon: Icons.admin_panel_settings_rounded,
                        color: AppleTheme.purple,
                        title: "Panel de Administración",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage())),
                      ),
                      const Divider(height: 1, indent: 64),
                      _SettingsRow(
                        icon: Icons.bar_chart_rounded,
                        color: AppleTheme.blue,
                        title: "Dashboard Power BI en Vivo",
                        onTap: () async {
                          final uri = Uri.parse("https://app.powerbi.com/view?r=eyJrIjoiMDliOWRjMWItNGFlMy00MDVjLTg2ZTUtZDFjZWE1MWU3OGYzIiwidCI6IjlkMTJiZjNmLWU0ZjYtNDdhYi05MTJmLTFhMmYwZmM0OGFhNCIsImMiOjR9");
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppleButton(
                text: "Cerrar sesión",
                icon: Icons.logout_rounded,
                backgroundColor: AppleTheme.red,
                outlined: true,
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            AppleIconBox(icon: icon, color: color, size: 36, iconSize: 19),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppleTheme.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppleTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}

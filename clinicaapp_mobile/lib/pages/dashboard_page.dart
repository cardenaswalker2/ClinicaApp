import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/cita.dart';
import '../models/mascota.dart';
import '../models/recordatorio.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'admin_dashboard_page.dart';
import 'add_reminder_page.dart';
import 'appointment_detail_page.dart';
import 'appointments_page.dart';
import 'clinic_explorer_page.dart';
import 'clinic_optimization_page.dart';
import 'my_pets_page.dart';
import 'notifications_page.dart';
import 'payments_page.dart';
import 'pet_detail_page.dart';
import 'reminder_detail_page.dart';
import 'shop_page.dart';
import 'sos_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Recordatorio> _recs = [];
  List<Mascota> _pets = [];
  List<Cita> _citas = [];
  int _unreadNotifs = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final email = AppConfig.userEmail ?? '';
      final rRes = await http.get(Uri.parse("${AppConfig.baseUrl}/recordatorios/usuario/$email"));
      final pRes = await http.get(Uri.parse("${AppConfig.baseUrl}/mascotas/usuario/$email"));
      final cRes = await http.get(Uri.parse("${AppConfig.baseUrl}/citas/usuario/$email"));

      int unreadCount = 0;
      try {
        final nRes = await http.get(Uri.parse("${AppConfig.baseUrl}/notificaciones/usuario/$email/count"));
        unreadCount = int.tryParse(nRes.body) ?? 0;
      } catch (_) {}

      if (mounted) {
        setState(() {
          if (rRes.statusCode == 200) {
            _recs = (json.decode(rRes.body) as List).map((e) => Recordatorio.fromJson(e)).toList();
          }
          if (pRes.statusCode == 200) {
            _pets = (json.decode(pRes.body) as List).map((e) => Mascota.fromJson(e)).toList();
          }
          if (cRes.statusCode == 200) {
            _citas = (json.decode(cRes.body) as List).map((e) => Cita.fromJson(e)).toList();
          }
          _unreadNotifs = unreadCount;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = (AppConfig.userName ?? 'Usuario').split(' ').first;

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetch,
          color: AppleTheme.blue,
          backgroundColor: AppleTheme.surface,
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
            children: [
              // Header estilo Apple Health
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hola, $userName",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppleTheme.textPrimary,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Resumen de bienestar animal",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppleTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _HeaderIconBtn(
                        icon: Icons.sos_rounded,
                        color: AppleTheme.red,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SOSPage())),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _HeaderIconBtn(
                            icon: Icons.notifications_none_rounded,
                            color: AppleTheme.textPrimary,
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                              _fetch();
                            },
                          ),
                          if (_unreadNotifs > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppleTheme.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "$_unreadNotifs",
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if ((AppConfig.userRole ?? '').toUpperCase().contains('ADMIN')) ...[
                AppleCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage())),
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppleTheme.indigo, AppleTheme.purple],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hub Central Super Admin",
                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            Text(
                              "KPIs, clínicas, usuarios, supervisión y control",
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Resumen en tarjetas blancas Apple
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: "Mascotas",
                      value: "${_pets.length}",
                      icon: Icons.pets_rounded,
                      color: AppleTheme.blue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPetsPage())).then((_) => _fetch()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: "Citas",
                      value: "${_citas.length}",
                      icon: Icons.calendar_month_rounded,
                      color: AppleTheme.orange,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsPage())).then((_) => _fetch()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: "Alertas",
                      value: "${_recs.length}",
                      icon: Icons.notifications_active_rounded,
                      color: AppleTheme.green,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReminderPage())).then((_) => _fetch()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Banner Optimizador PLEB estilo Apple
              AppleCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicOptimizationPage())),
                padding: const EdgeInsets.all(18),
                borderRadius: 22,
                child: Row(
                  children: [
                    const AppleIconBox(icon: Icons.near_me_rounded, color: AppleTheme.blue, size: 50, iconSize: 25),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppleBadge(text: "Optimización PLEB", color: AppleTheme.blue),
                          const SizedBox(height: 6),
                          Text(
                            "Clínica más cercana",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppleTheme.textPrimary,
                            ),
                          ),
                          Text(
                            "Calcula la sede abierta óptima desde tu GPS",
                            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppleTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppleTheme.textTertiary),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Accesos Rápidos
              const AppleSectionHeader(title: "Accesos Rápidos"),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _QuickActionTile(
                    title: "Mis Mascotas",
                    subtitle: "Perfiles e historial",
                    icon: Icons.pets_rounded,
                    color: AppleTheme.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPetsPage())).then((_) => _fetch()),
                  ),
                  _QuickActionTile(
                    title: "Explorar Clínicas",
                    subtitle: "Red veterinaria",
                    icon: Icons.local_hospital_rounded,
                    color: AppleTheme.green,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicExplorerPage())),
                  ),
                  _QuickActionTile(
                    title: "Mis Pagos",
                    subtitle: "Facturas y Stripe",
                    icon: Icons.receipt_long_rounded,
                    color: AppleTheme.indigo,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsPage())),
                  ),
                  _QuickActionTile(
                    title: "Tienda Pet",
                    subtitle: "Productos y salud",
                    icon: Icons.shopping_bag_rounded,
                    color: AppleTheme.purple,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopPage())),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mis Mascotas
              AppleSectionHeader(
                title: "Mis Mascotas",
                actionText: "Ver todas",
                onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPetsPage())).then((_) => _fetch()),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppleTheme.blue)))
              else if (_pets.isEmpty)
                AppleCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPetsPage())).then((_) => _fetch()),
                  child: Row(
                    children: [
                      const AppleIconBox(icon: Icons.add_circle_outline_rounded, color: AppleTheme.blue),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "Aún no tienes mascotas registradas. Toca para agregar una.",
                          style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppleTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _pets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final pet = _pets[index];
                      return SizedBox(
                        width: 160,
                        child: AppleCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PetDetailPage(mascota: pet)),
                          ).then((_) => _fetch()),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AppleAvatar(
                                    imageUrl: pet.fotoUrl,
                                    fallbackIcon: Icons.pets_rounded,
                                    color: AppleTheme.blue,
                                    size: 40,
                                  ),
                                  AppleBadge(text: pet.especie, color: AppleTheme.teal),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppleTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    pet.raza,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppleTheme.textSecondary,
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
              const SizedBox(height: 24),

              // Próximas Citas
              AppleSectionHeader(
                title: "Próximas Citas",
                actionText: "Ver todas",
                onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsPage())).then((_) => _fetch()),
              ),
              const SizedBox(height: 12),
              if (_citas.isEmpty && !_loading)
                AppleCard(
                  child: Text(
                    "No tienes citas programadas por ahora.",
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppleTheme.textSecondary),
                  ),
                )
              else
                ..._citas.take(3).map((cita) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppleCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AppointmentDetailPage(cita: cita)),
                      ).then((_) => _fetch()),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const AppleIconBox(icon: Icons.event_available_rounded, color: AppleTheme.orange),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cita.motivo.isNotEmpty ? cita.motivo : "Consulta Veterinaria",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppleTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${cita.mascotaNombre ?? 'Mascota'} • ${cita.fechaHora}",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: AppleTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppleBadge(
                            text: cita.estado,
                            color: cita.estado.toUpperCase().contains("COMP") ? AppleTheme.green : AppleTheme.blue,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 22),

              // Recordatorios
              AppleSectionHeader(
                title: "Recordatorios",
                actionText: "+ Nuevo",
                onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReminderPage())).then((_) => _fetch()),
              ),
              const SizedBox(height: 12),
              if (_recs.isEmpty && !_loading)
                AppleCard(
                  child: Text(
                    "Sin recordatorios pendientes.",
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppleTheme.textSecondary),
                  ),
                )
              else
                ..._recs.take(4).map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppleCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReminderDetailPage(recordatorio: rec)),
                      ).then((_) => _fetch()),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const AppleIconBox(icon: Icons.alarm_rounded, color: AppleTheme.green),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.titulo,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppleTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  rec.fechaHora,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppleTheme.textSecondary),
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
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderIconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      borderRadius: 14,
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppleCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppleIconBox(icon: icon, color: color, size: 34, iconSize: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppleTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppleTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppleIconBox(icon: icon, color: color, size: 38, iconSize: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppleTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppleTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _errorMessage;

  // ── Theme colors ──
  static const Color _bgDark = Color(0xFF030712);
  static const Color _cardDark = Color(0xFF0F172A);
  static const Color _accentCyan = Color(0xFF06B6D4);
  static const Color _accentBlue = Color(0xFF3B82F6);
  static const Color _accentPurple = Color(0xFF8B5CF6);
  static const Color _accentGold = Color(0xFFF59E0B);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _accentRed = Color(0xFFEF4444);

  // ── State data ──
  Map<String, dynamic> _metrics = {};
  Map<String, dynamic> _infraConfig = {};
  List<dynamic> _clinicas = [];
  List<dynamic> _usuarios = [];
  List<dynamic> _solicitudes = [];
  List<dynamic> _servicios = [];
  List<dynamic> _auditorias = [];
  Map<String, dynamic> _salud = {};
  List<dynamic> _adopciones = [];

  // Tech 1428 controllers
  final _emailToController = TextEditingController();
  final _emailMsgController = TextEditingController();
  final _smsToController = TextEditingController();
  final _smsMsgController = TextEditingController();
  final _aiPromptController = TextEditingController();
  String _aiResult = "";
  bool _techLoading = false;
  // PLEB Optimization State
  bool _plebLoading = false;
  Map<String, dynamic>? _plebResult;

  // Supervisión State
  List<dynamic> _supervisionUsers = [];
  Map<String, dynamic>? _selectedUserSupervision;
  bool _supervisionLoading = false;
  final _supervisionSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _loadAllAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailToController.dispose();
    _emailMsgController.dispose();
    _smsToController.dispose();
    _smsMsgController.dispose();
    _aiPromptController.dispose();
    _supervisionSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllAdminData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final email = AppConfig.userEmail ?? "";
    try {
      // 1. Dashboard metrics
      final resMetrics = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/dashboard?email=$email"));
      if (resMetrics.statusCode == 200) {
        _metrics = json.decode(resMetrics.body);
      }

      // 2. Control Center (Infra)
      final resInfra = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/centro-control?email=$email"));
      if (resInfra.statusCode == 200) {
        _infraConfig = json.decode(resInfra.body);
      }

      // 3. Clínicas
      final resClinicas = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/clinicas?email=$email"));
      if (resClinicas.statusCode == 200) {
        final list = json.decode(resClinicas.body) as List;
        _clinicas = list;
        _solicitudes = list.where((c) => (c['estado'] ?? '').toString().toUpperCase() == 'PENDIENTE').toList();
      }

      // 4. Usuarios
      final resUsuarios = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/usuarios?email=$email"));
      if (resUsuarios.statusCode == 200) {
        _usuarios = json.decode(resUsuarios.body);
      }

      // 5. Salud
      final resSalud = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/salud?email=$email"));
      if (resSalud.statusCode == 200) {
        _salud = json.decode(resSalud.body);
      }

      // 6. Auditoría
      final resAudit = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/auditoria?email=$email"));
      if (resAudit.statusCode == 200) {
        _auditorias = json.decode(resAudit.body);
      }

      // 7. Adopciones
      final resAdop = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/comunidad/pendientes?email=$email"));
      if (resAdop.statusCode == 200) {
        _adopciones = json.decode(resAdop.body);
      }

      // 8. Servicios
      final resServ = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/servicios?email=$email"));
      if (resServ.statusCode == 200) {
        _servicios = json.decode(resServ.body);
      }

      // 9. Supervisión de Usuarios
      final resSupervision = await http.get(Uri.parse("${AppConfig.baseUrl}/api/supervision/usuarios?email=$email"));
      if (resSupervision.statusCode == 200) {
        _supervisionUsers = json.decode(resSupervision.body);
      }
    } catch (e) {
      _errorMessage = "Error de sincronización con servidor administrativo: $e";
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? _accentRed : _accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UI BUILDER
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_accentCyan, _accentBlue]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "SUPER ADMIN",
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Hub Central",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
            Text(
              AppConfig.userName ?? "Super Administrador",
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _accentCyan),
            onPressed: _loadAllAdminData,
            tooltip: "Actualizar datos",
          ),
          IconButton(
            icon: const Icon(Icons.lock_reset_rounded, color: _accentGold),
            onPressed: () {
              Navigator.pop(context);
              _showSnack("Sesión administrativa cerrada");
            },
            tooltip: "Salir del Super Admin",
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: _accentCyan,
          indicatorWeight: 3,
          labelColor: _accentCyan,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded, size: 18), text: "KPIs & SaaS"),
            Tab(icon: Icon(Icons.person_pin_rounded, size: 18), text: "Supervisión"),
            Tab(icon: Icon(Icons.settings_input_component_rounded, size: 18), text: "Control Center"),
            Tab(icon: Icon(Icons.local_hospital_rounded, size: 18), text: "Clínicas & Solicitudes"),
            Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: "Usuarios"),
            Tab(icon: Icon(Icons.medical_services_rounded, size: 18), text: "Servicios"),
            Tab(icon: Icon(Icons.pets_rounded, size: 18), text: "Moderación"),
            Tab(icon: Icon(Icons.route_rounded, size: 18), text: "PLEB Global"),
            Tab(icon: Icon(Icons.monitor_heart_rounded, size: 18), text: "Salud & Auditoría"),
            Tab(icon: Icon(Icons.terminal_rounded, size: 18), text: "Tech 1428"),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accentCyan))
          : _errorMessage != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildKpisTab(),
                    _buildSupervisionTab(),
                    _buildControlCenterTab(),
                    _buildClinicasTab(),
                    _buildUsuariosTab(),
                    _buildServiciosTab(),
                    _buildModeracionTab(),
                    _buildPlebTab(),
                    _buildHealthAuditTab(),
                    _buildTech1428Tab(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: _accentRed, size: 64),
            const SizedBox(height: 16),
            Text(
              "Error de Carga",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllAdminData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Reintentar"),
              style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
            )
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 1. TAB: KPIS & SAAS
  // ═══════════════════════════════════════════════════════════
  Widget _buildKpisTab() {
    final mrr = _metrics['mrr'] ?? 0.0;
    final arr = _metrics['arr'] ?? 0.0;
    final totalIngresos = _metrics['totalIngresos'] ?? 0.0;
    final usuariosCount = _metrics['totalUsuarios'] ?? 0;
    final clinicasCount = _metrics['totalClinicas'] ?? 0;
    final citasCount = _metrics['totalCitas'] ?? 0;
    final solPend = _metrics['solicitudesPendientes'] ?? 0;
    final adopPend = _metrics['adopcionesPendientes'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadAllAdminData,
      color: _accentCyan,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGlassBanner(
            title: "Ingresos Totales en Plataforma",
            value: "\$${totalIngresos.toStringAsFixed(2)} USD",
            subtitle: "Facturación global consolidada",
            icon: Icons.account_balance_wallet_rounded,
            color: _accentGreen,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: "MRR Recurrente",
                  value: "\$${mrr.toStringAsFixed(0)}/mes",
                  icon: Icons.trending_up_rounded,
                  color: _accentCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: "ARR Proyectado",
                  value: "\$${arr.toStringAsFixed(0)}/año",
                  icon: Icons.auto_graph_rounded,
                  color: _accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: "Usuarios",
                  value: "$usuariosCount",
                  icon: Icons.people_rounded,
                  color: _accentBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: "Clínicas",
                  value: "$clinicasCount",
                  icon: Icons.business_rounded,
                  color: _accentGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: "Citas",
                  value: "$citasCount",
                  icon: Icons.calendar_today_rounded,
                  color: Colors.tealAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Distribución de Suscripciones SaaS",
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildPlanRow("Starter (\$49/mes)", _metrics['countStarter'] ?? 0, _accentCyan),
          const SizedBox(height: 8),
          _buildPlanRow("Professional (\$99/mes)", _metrics['countProfessional'] ?? 0, _accentPurple),
          const SizedBox(height: 8),
          _buildPlanRow("Enterprise (\$199/mes)", _metrics['countEnterprise'] ?? 0, _accentGold),
          const SizedBox(height: 20),
          Text(
            "Alertas y Moderación",
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildAlertCard("Solicitudes de Sedes Pendientes", "$solPend clínicas esperando revisión", Icons.domain_verification_rounded, solPend > 0 ? _accentGold : _accentGreen),
          const SizedBox(height: 8),
          _buildAlertCard("Adopciones por Moderar", "$adopPend mascotas esperando aprobación", Icons.pets_rounded, adopPend > 0 ? _accentGold : _accentGreen),
        ],
      ),
    );
  }

  Widget _buildPlanRow(String planName, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(planName, style: GoogleFonts.outfit(fontSize: 14, color: Colors.white)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text("$count activas", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          )
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 2. TAB: CONTROL CENTER (INFRAESTRUCTURA)
  // ═══════════════════════════════════════════════════════════
  Widget _buildControlCenterTab() {
    bool mantenimiento = _infraConfig['modoMantenimiento'] ?? false;
    bool sistemaActivo = _infraConfig['sistemaActivo'] ?? true;
    bool broadcastActivo = _infraConfig['broadcastActivo'] ?? false;
    String mensajeGlobal = _infraConfig['mensajeGlobal'] ?? "";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Infraestructura y Modos Globales", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: "Modo Mantenimiento",
          subtitle: "Cierra el acceso público de la plataforma temporalmente",
          value: mantenimiento,
          icon: Icons.build_circle_rounded,
          activeColor: _accentRed,
          onChanged: (val) => _updateInfraSetting('modoMantenimiento', val),
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: "Portal de Registro Activo",
          subtitle: "Permite a nuevos usuarios crear cuentas",
          value: sistemaActivo,
          icon: Icons.person_add_rounded,
          activeColor: _accentGreen,
          onChanged: (val) => _updateInfraSetting('sistemaActivo', val),
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: "Comunicado Global (Broadcast)",
          subtitle: "Emite una franja de aviso en la parte superior de la app",
          value: broadcastActivo,
          icon: Icons.campaign_rounded,
          activeColor: _accentCyan,
          onChanged: (val) => _updateInfraSetting('broadcastActivo', val),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mensaje de Notificación Broadcast", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: mensajeGlobal,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Escribe el comunicado global para todos los usuarios...",
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (v) => _infraConfig['mensajeGlobal'] = v,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateInfraSetting('mensajeGlobal', _infraConfig['mensajeGlobal']),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text("Actualizar Mensaje Global"),
                  style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateInfraSetting(String key, dynamic value) async {
    _infraConfig[key] = value;
    final email = AppConfig.userEmail ?? "";
    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/admin/centro-control?email=$email"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(_infraConfig),
      );
      if (res.statusCode == 200) {
        _showSnack("Infraestructura actualizada");
        setState(() {});
      } else {
        _showSnack("Error al actualizar infraestructura", isError: true);
      }
    } catch (e) {
      _showSnack("Fallo de conexión: $e", isError: true);
    }
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (value ? activeColor : Colors.white24).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: value ? activeColor : Colors.white60, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3. TAB: CLÍNICAS & SOLICITUDES (CRUD COMPLETO)
  // ═══════════════════════════════════════════════════════════
  Widget _buildClinicasTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                const Expanded(
                  child: TabBar(
                    indicatorColor: _accentCyan,
                    labelColor: _accentCyan,
                    unselectedLabelColor: Colors.white54,
                    tabs: [
                      Tab(text: "Todas las Clínicas"),
                      Tab(text: "Solicitudes Pendientes"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.add_business_rounded, color: _accentCyan),
                    tooltip: "Nueva Clínica",
                    onPressed: () => _showAddEditClinicaDialog(),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _clinicas.isEmpty
                    ? Center(child: Text("No hay clínicas registradas", style: GoogleFonts.outfit(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _clinicas.length,
                        itemBuilder: (context, i) {
                          final c = _clinicas[i];
                          final id = c['id'] ?? '';
                          final nombre = c['nombre'] ?? 'Sin Nombre';
                          final direccion = c['direccion'] ?? 'Sin Dirección';
                          final plan = c['planSaaS'] ?? 'Starter';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        nombre,
                                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _accentCyan.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(plan, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: _accentCyan)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(direccion, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _showPlanChangeDialog(id, nombre, plan),
                                      icon: const Icon(Icons.card_membership_rounded, size: 14),
                                      label: const Text("Plan SaaS", style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(backgroundColor: _accentPurple),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _showGrantFreeDaysDialog(id, nombre),
                                      icon: const Icon(Icons.more_time_rounded, size: 14, color: _accentGold),
                                      label: const Text("+ Días", style: TextStyle(fontSize: 12, color: _accentGold)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, color: _accentCyan, size: 20),
                                      tooltip: "Editar Sede",
                                      onPressed: () => _showAddEditClinicaDialog(clinica: c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: _accentRed, size: 20),
                                      tooltip: "Eliminar Sede",
                                      onPressed: () => _confirmAction(
                                        title: "Eliminar Clínica",
                                        content: "¿Confirmas la eliminación de la sede $nombre? Esta acción no se puede deshacer.",
                                        onConfirm: () async {
                                          final email = AppConfig.userEmail ?? "";
                                          final res = await http.delete(Uri.parse("${AppConfig.baseUrl}/admin/clinicas/$id?email=$email"));
                                          if (res.statusCode == 200) {
                                            _showSnack("Sede eliminada");
                                            _loadAllAdminData();
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),

                _solicitudes.isEmpty
                    ? Center(child: Text("No hay solicitudes pendientes", style: GoogleFonts.outfit(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _solicitudes.length,
                        itemBuilder: (context, i) {
                          final c = _solicitudes[i];
                          final id = c['id'] ?? '';
                          final nombre = c['nombre'] ?? 'Sin Nombre';
                          final email = c['email'] ?? 'Sin Email';
                          final telefono = c['telefono'] ?? 'Sin Teléfono';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _accentGold.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(nombre, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: _accentGold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                      child: Text("PENDIENTE", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: _accentGold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text("Email: $email • Tel: $telefono", style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _confirmAction(
                                          title: "Aprobar Clínica",
                                          content: "¿Deseas habilitar a $nombre en la red oficial?",
                                          onConfirm: () => _handleAprobarClinica(id),
                                        ),
                                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                                        label: const Text("Aprobar"),
                                        style: ElevatedButton.styleFrom(backgroundColor: _accentGreen),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _confirmAction(
                                          title: "Rechazar Clínica",
                                          content: "¿Deseas rechazar la solicitud de $nombre?",
                                          onConfirm: () => _handleRechazarClinica(id),
                                        ),
                                        icon: const Icon(Icons.cancel_rounded, size: 16),
                                        label: const Text("Rechazar"),
                                        style: ElevatedButton.styleFrom(backgroundColor: _accentRed),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showAddEditClinicaDialog({Map<String, dynamic>? clinica}) {
    final isEdit = clinica != null;
    final nombreCtrl = TextEditingController(text: isEdit ? clinica['nombre'] : '');
    final dirCtrl = TextEditingController(text: isEdit ? clinica['direccion'] : '');
    final telCtrl = TextEditingController(text: isEdit ? clinica['telefono'] : '');
    final emailCtrl = TextEditingController(text: isEdit ? clinica['email'] : '');
    final descCtrl = TextEditingController(text: isEdit ? clinica['descripcion'] : '');
    final latCtrl = TextEditingController(text: isEdit ? (clinica['latitud']?.toString() ?? '4.6097') : '4.6097');
    final lonCtrl = TextEditingController(text: isEdit ? (clinica['longitud']?.toString() ?? '-74.0817') : '-74.0817');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Text(isEdit ? "Editar Clínica" : "Nueva Clínica", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: dirCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Dirección")),
              TextField(controller: telCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Teléfono")),
              TextField(controller: emailCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Email de contacto")),
              TextField(controller: descCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Descripción")),
              Row(
                children: [
                  Expanded(child: TextField(controller: latCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Latitud"))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: lonCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Longitud"))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final adminEmail = AppConfig.userEmail ?? "";
              final payload = {
                "nombre": nombreCtrl.text.trim(),
                "direccion": dirCtrl.text.trim(),
                "telefono": telCtrl.text.trim(),
                "email": emailCtrl.text.trim(),
                "descripcion": descCtrl.text.trim(),
                "latitud": double.tryParse(latCtrl.text) ?? 4.6097,
                "longitud": double.tryParse(lonCtrl.text) ?? -74.0817,
              };

              final url = isEdit
                  ? "${AppConfig.baseUrl}/admin/clinicas/${clinica['id']}?email=$adminEmail"
                  : "${AppConfig.baseUrl}/admin/clinicas?email=$adminEmail";

              final res = isEdit
                  ? await http.put(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(payload))
                  : await http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(payload));

              if (res.statusCode == 200) {
                _showSnack(isEdit ? "Clínica actualizada" : "Clínica creada");
                _loadAllAdminData();
              } else {
                _showSnack("Error al procesar clínica", isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  Future<void> _handleAprobarClinica(String id) async {
    final email = AppConfig.userEmail ?? "";
    try {
      final res = await http.post(Uri.parse("${AppConfig.baseUrl}/admin/clinicas/$id/aprobar?email=$email"));
      if (res.statusCode == 200) {
        _showSnack("Clínica aprobada exitosamente");
        _loadAllAdminData();
      } else {
        _showSnack("Error al aprobar clínica", isError: true);
      }
    } catch (e) {
      _showSnack("Fallo de conexión: $e", isError: true);
    }
  }

  Future<void> _handleRechazarClinica(String id) async {
    final email = AppConfig.userEmail ?? "";
    try {
      final res = await http.post(Uri.parse("${AppConfig.baseUrl}/admin/clinicas/$id/rechazar?email=$email"));
      if (res.statusCode == 200) {
        _showSnack("Clínica rechazada");
        _loadAllAdminData();
      } else {
        _showSnack("Error al rechazar clínica", isError: true);
      }
    } catch (e) {
      _showSnack("Fallo de conexión: $e", isError: true);
    }
  }

  void _showPlanChangeDialog(String id, String nombre, String currentPlan) {
    String selected = currentPlan;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: _cardDark,
          title: Text("Modificar Plan SaaS: $nombre", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["Starter", "Professional", "Enterprise"].map((p) {
              return RadioListTile<String>(
                title: Text(p, style: GoogleFonts.outfit(color: Colors.white)),
                value: p,
                groupValue: selected,
                activeColor: _accentCyan,
                onChanged: (val) => setDState(() => selected = val!),
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final email = AppConfig.userEmail ?? "";
                final res = await http.post(
                  Uri.parse("${AppConfig.baseUrl}/admin/clinicas/$id/plan?email=$email"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({"plan": selected}),
                );
                if (res.statusCode == 200) {
                  _showSnack("Plan actualizado a $selected");
                  _loadAllAdminData();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
              child: const Text("Guardar"),
            )
          ],
        ),
      ),
    );
  }

  void _showGrantFreeDaysDialog(String id, String nombre) {
    final daysController = TextEditingController(text: "30");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Text("Otorgar Días Gratis: $nombre", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: daysController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: const InputDecoration(labelText: "Cantidad de días extra", labelStyle: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final email = AppConfig.userEmail ?? "";
              final res = await http.post(
                Uri.parse("${AppConfig.baseUrl}/admin/clinicas/$id/plan?email=$email"),
                headers: {"Content-Type": "application/json"},
                body: json.encode({"diasGratis": int.tryParse(daysController.text) ?? 30}),
              );
              if (res.statusCode == 200) {
                _showSnack("Se agregaron ${daysController.text} días");
                _loadAllAdminData();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accentGold),
            child: const Text("Extender"),
          )
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 4. TAB: USUARIOS (CRUD COMPLETO)
  // ═══════════════════════════════════════════════════════════
  Widget _buildUsuariosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Directorio de Cuentas (${_usuarios.length})", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddEditUserDialog(),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text("Nuevo Usuario"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
              )
            ],
          ),
        ),
        Expanded(
          child: _usuarios.isEmpty
              ? Center(child: Text("No hay usuarios registrados", style: GoogleFonts.outfit(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _usuarios.length,
                  itemBuilder: (context, i) {
                    final u = _usuarios[i];
                    final id = u['id'] ?? '';
                    final nombre = u['nombre'] ?? 'Sin Nombre';
                    final email = u['email'] ?? 'Sin Email';
                    final role = u['role'] ?? 'ROLE_USER';
                    final bool activo = u['activo'] ?? true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: activo ? _accentBlue.withOpacity(0.2) : _accentRed.withOpacity(0.2),
                            child: Icon(Icons.person_rounded, color: activo ? _accentBlue : _accentRed),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nombre, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(email, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                                  child: Text(role, style: GoogleFonts.outfit(fontSize: 10, color: _accentCyan, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: _accentCyan, size: 18),
                            tooltip: "Editar",
                            onPressed: () => _showAddEditUserDialog(user: u),
                          ),
                          IconButton(
                            icon: Icon(activo ? Icons.block_rounded : Icons.check_circle_outline_rounded, color: activo ? _accentGold : _accentGreen, size: 18),
                            tooltip: activo ? "Suspender" : "Reactivar",
                            onPressed: () => _confirmAction(
                              title: activo ? "Suspender Usuario" : "Reactivar Usuario",
                              content: "¿Deseas cambiar el estado de acceso de $nombre ($email)?",
                              onConfirm: () async {
                                final adminEmail = AppConfig.userEmail ?? "";
                                final res = await http.post(Uri.parse("${AppConfig.baseUrl}/admin/usuarios/$id/toggle-status?email=$adminEmail"));
                                if (res.statusCode == 200) {
                                  _showSnack("Estado de usuario actualizado");
                                  _loadAllAdminData();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: _accentRed, size: 18),
                            tooltip: "Eliminar",
                            onPressed: () => _confirmAction(
                              title: "Eliminar Usuario",
                              content: "¿Deseas eliminar permanentemente a $nombre?",
                              onConfirm: () async {
                                final adminEmail = AppConfig.userEmail ?? "";
                                final res = await http.delete(Uri.parse("${AppConfig.baseUrl}/admin/usuarios/$id?email=$adminEmail"));
                                if (res.statusCode == 200) {
                                  _showSnack("Usuario eliminado");
                                  _loadAllAdminData();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddEditUserDialog({Map<String, dynamic>? user}) {
    final isEdit = user != null;
    final nombreCtrl = TextEditingController(text: isEdit ? user['nombre'] : '');
    final apellidoCtrl = TextEditingController(text: isEdit ? user['apellido'] : '');
    final emailCtrl = TextEditingController(text: isEdit ? user['email'] : '');
    final telCtrl = TextEditingController(text: isEdit ? user['telefono'] : '');
    final dirCtrl = TextEditingController(text: isEdit ? user['direccion'] : '');
    String selectedRole = isEdit ? (user['role'] ?? 'ROLE_USER') : 'ROLE_USER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: _cardDark,
          title: Text(isEdit ? "Editar Usuario" : "Nuevo Usuario", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nombreCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Nombre")),
                TextField(controller: apellidoCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Apellido")),
                if (!isEdit) TextField(controller: emailCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Correo Electrónico")),
                TextField(controller: telCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Teléfono")),
                TextField(controller: dirCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Dirección")),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: _cardDark,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Rol del Sistema"),
                  items: const [
                    DropdownMenuItem(value: "ROLE_USER", child: Text("ROLE_USER (Paciente/Dueño)")),
                    DropdownMenuItem(value: "ROLE_ADMIN", child: Text("ROLE_ADMIN (Super Administrador)")),
                    DropdownMenuItem(value: "ROLE_CLINICA", child: Text("ROLE_CLINICA (Dueño Sede)")),
                    DropdownMenuItem(value: "ROLE_VETERINARIO", child: Text("ROLE_VETERINARIO (Doctor)")),
                    DropdownMenuItem(value: "ROLE_RECEPCIONISTA", child: Text("ROLE_RECEPCIONISTA")),
                  ],
                  onChanged: (val) => setDState(() => selectedRole = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final adminEmail = AppConfig.userEmail ?? "";
                final payload = {
                  "nombre": nombreCtrl.text.trim(),
                  "apellido": apellidoCtrl.text.trim(),
                  "email": isEdit ? (user['email'] ?? '') : emailCtrl.text.trim(),
                  "telefono": telCtrl.text.trim(),
                  "direccion": dirCtrl.text.trim(),
                  "role": selectedRole,
                };

                final url = isEdit
                    ? "${AppConfig.baseUrl}/admin/usuarios/${user['id']}?email=$adminEmail"
                    : "${AppConfig.baseUrl}/admin/usuarios?email=$adminEmail";

                final res = isEdit
                    ? await http.put(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(payload))
                    : await http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(payload));

                if (res.statusCode == 200) {
                  _showSnack(isEdit ? "Usuario actualizado" : "Usuario creado");
                  _loadAllAdminData();
                } else {
                  _showSnack("Error en la operación de usuario", isError: true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
              child: const Text("Guardar"),
            )
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 5. TAB: SERVICIOS MAESTROS (CRUD COMPLETO)
  // ═══════════════════════════════════════════════════════════
  Widget _buildServiciosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Catálogo de Servicios (${_servicios.length})", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddEditServicioDialog(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text("Nuevo Servicio"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentPurple),
              )
            ],
          ),
        ),
        Expanded(
          child: _servicios.isEmpty
              ? Center(child: Text("No hay servicios maestros creados", style: GoogleFonts.outfit(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _servicios.length,
                  itemBuilder: (context, i) {
                    final s = _servicios[i];
                    final id = s['id'] ?? '';
                    final nombre = s['nombre'] ?? 'Sin Nombre';
                    final desc = s['descripcion'] ?? 'Sin Descripción';
                    final precio = s['precio'] ?? 0.0;
                    final duracion = s['duracionMinutos'] ?? 30;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: _accentPurple.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.medical_services_rounded, color: _accentPurple, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nombre, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(desc, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text("\$$precio USD • $duracion min", style: GoogleFonts.outfit(fontSize: 12, color: _accentGreen, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: _accentCyan, size: 18),
                            onPressed: () => _showAddEditServicioDialog(servicio: s),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: _accentRed, size: 18),
                            onPressed: () => _confirmAction(
                              title: "Eliminar Servicio",
                              content: "¿Confirmas la eliminación del servicio maestro $nombre?",
                              onConfirm: () async {
                                final adminEmail = AppConfig.userEmail ?? "";
                                final res = await http.post(Uri.parse("${AppConfig.baseUrl}/admin/servicios/$id/eliminar?email=$adminEmail"));
                                if (res.statusCode == 200) {
                                  _showSnack("Servicio eliminado");
                                  _loadAllAdminData();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddEditServicioDialog({Map<String, dynamic>? servicio}) {
    final isEdit = servicio != null;
    final nombreCtrl = TextEditingController(text: isEdit ? servicio['nombre'] : '');
    final descCtrl = TextEditingController(text: isEdit ? servicio['descripcion'] : '');
    final precioCtrl = TextEditingController(text: isEdit ? (servicio['precio']?.toString() ?? '25.0') : '25.0');
    final durCtrl = TextEditingController(text: isEdit ? (servicio['duracionMinutos']?.toString() ?? '30') : '30');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Text(isEdit ? "Editar Servicio" : "Nuevo Servicio Maestro", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Nombre del Servicio")),
              TextField(controller: descCtrl, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Descripción")),
              TextField(controller: precioCtrl, keyboardType: TextInputType.number, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Precio sugerido (\$ USD)")),
              TextField(controller: durCtrl, keyboardType: TextInputType.number, style: GoogleFonts.outfit(color: Colors.white), decoration: const InputDecoration(labelText: "Duración en minutos")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final adminEmail = AppConfig.userEmail ?? "";
              final payload = {
                if (isEdit) "id": servicio['id'],
                "nombre": nombreCtrl.text.trim(),
                "descripcion": descCtrl.text.trim(),
                "precio": double.tryParse(precioCtrl.text) ?? 25.0,
                "duracionMinutos": int.tryParse(durCtrl.text) ?? 30,
              };

              final res = await http.post(
                Uri.parse("${AppConfig.baseUrl}/admin/servicios?email=$adminEmail"),
                headers: {"Content-Type": "application/json"},
                body: json.encode(payload),
              );

              if (res.statusCode == 200) {
                _showSnack(isEdit ? "Servicio actualizado" : "Servicio creado");
                _loadAllAdminData();
              } else {
                _showSnack("Error al procesar servicio maestro", isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accentPurple),
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 6. TAB: MODERACIÓN DE ADOPCIONES
  // ═══════════════════════════════════════════════════════════
  Widget _buildModeracionTab() {
    return _adopciones.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets_rounded, color: Colors.white24, size: 64),
                const SizedBox(height: 12),
                Text("No hay adopciones pendientes de moderación", style: GoogleFonts.outfit(color: Colors.white54)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _adopciones.length,
            itemBuilder: (context, i) {
              final a = _adopciones[i];
              final id = a['id'] ?? '';
              final titulo = a['titulo'] ?? a['nombreMascota'] ?? 'Mascota en Adopción';
              final desc = a['descripcion'] ?? 'Sin descripción';
              final usuario = a['usuarioNombre'] ?? 'Usuario Registrado';
              final ciudad = a['ciudad'] ?? 'Ciudad no especificada';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accentGold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(titulo, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _accentGold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text("POR MODERAR", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: _accentGold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Publicado por: $usuario • $ciudad", style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
                    const SizedBox(height: 8),
                    Text(desc, style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmAction(
                              title: "Aprobar Publicación",
                              content: "¿Deseas publicar este anuncio de adopción en la comunidad?",
                              onConfirm: () async {
                                final email = AppConfig.userEmail ?? "";
                                final res = await http.post(Uri.parse("${AppConfig.baseUrl}/admin/comunidad/$id/aprobar?email=$email"));
                                if (res.statusCode == 200) {
                                  _showSnack("Publicación aprobada");
                                  _loadAllAdminData();
                                }
                              },
                            ),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text("Aprobar"),
                            style: ElevatedButton.styleFrom(backgroundColor: _accentGreen),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmAction(
                              title: "Rechazar Publicación",
                              content: "¿Confirmas el rechazo de este anuncio?",
                              onConfirm: () async {
                                final email = AppConfig.userEmail ?? "";
                                final res = await http.post(Uri.parse("${AppConfig.baseUrl}/admin/comunidad/$id/rechazar?email=$email"));
                                if (res.statusCode == 200) {
                                  _showSnack("Publicación rechazada");
                                  _loadAllAdminData();
                                }
                              },
                            ),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text("Rechazar"),
                            style: ElevatedButton.styleFrom(backgroundColor: _accentRed),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
  }

  // ═══════════════════════════════════════════════════════════
  // 7. TAB: PLEB + HAVERSINE GLOBAL
  // ═══════════════════════════════════════════════════════════
  Widget _buildPlebTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGlassBanner(
          title: "Programación Lineal Entera Binaria (PLEB)",
          value: "OPTIMIZACIÓN GLOBAL",
          subtitle: "Cálculo geodésico Haversine de asignación de sedes",
          icon: Icons.hub_rounded,
          color: _accentCyan,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ejecución del Algoritmo Global", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                "Resuelve la matriz de cobertura binaria min Sum(di * Xi) sujeto a Xi in {0,1} y radio máximo de 50km.",
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _plebLoading ? null : _runPlebOptimization,
                  icon: _plebLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow_rounded),
                  label: const Text("Ejecutar Optimización PLEB"),
                  style: ElevatedButton.styleFrom(backgroundColor: _accentCyan, padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              )
            ],
          ),
        ),
        if (_plebResult != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accentGreen.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: _accentGreen, size: 20),
                    const SizedBox(width: 8),
                    Text("Resultado del Modelo Matemático", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Text("Clínica Óptima Seleccionada: ${_plebResult!['clinicaSeleccionada']?['nombre'] ?? 'Sede Principal'}", style: GoogleFonts.outfit(fontSize: 14, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Distancia Haversine: ${(_plebResult!['distanciaKm'] ?? 0.0).toStringAsFixed(2)} km", style: GoogleFonts.outfit(fontSize: 13, color: Colors.white)),
                Text("Estado de Factibilidad: ${_plebResult!['estadoFactibilidad'] ?? 'ÓPTIMO'}", style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70)),
                Text("Total Sedes Evaluadas: ${_plebResult!['totalClinicasEvaluadas'] ?? _clinicas.length}", style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70)),
              ],
            ),
          )
        ]
      ],
    );
  }

  Future<void> _runPlebOptimization() async {
    setState(() => _plebLoading = true);
    final email = AppConfig.userEmail ?? "";
    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/admin/optimizacion-global?email=$email"));
      if (res.statusCode == 200) {
        setState(() => _plebResult = json.decode(res.body));
        _showSnack("Optimización PLEB resuelta");
      } else {
        _showSnack("Error al ejecutar optimización", isError: true);
      }
    } catch (e) {
      _showSnack("Fallo de conexión: $e", isError: true);
    } finally {
      if (mounted) setState(() => _plebLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 8. TAB: SALUD & AUDITORÍA
  // ═══════════════════════════════════════════════════════════
  Widget _buildHealthAuditTab() {
    final cpu = _salud['cpuUsage'] ?? '5.4%';
    final usedRam = _salud['usedMemory'] ?? '1.2 GB';
    final totalRam = _salud['totalMemory'] ?? '4.0 GB';
    final mongoStatus = _salud['mongoStatus'] ?? 'OPERATIVO';
    final uptime = _salud['uptime'] ?? '00h 00m';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Telemetría y Estado de Infraestructura", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(title: "CPU Servidor", value: cpu, icon: Icons.memory_rounded, color: _accentCyan)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(title: "RAM JVM", value: "$usedRam / $totalRam", icon: Icons.storage_rounded, color: _accentPurple)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(title: "Base de Datos", value: mongoStatus, icon: Icons.dataset_rounded, color: mongoStatus == 'OPERATIVO' ? _accentGreen : _accentRed)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(title: "Uptime Real", value: uptime, icon: Icons.timer_rounded, color: _accentGold)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Registros de Auditoría", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            TextButton.icon(
              onPressed: () => _confirmAction(
                title: "Limpiar Auditoría",
                content: "Esta acción eliminará todos los registros de logs administrativos. ¿Deseas continuar?",
                onConfirm: () async {
                  final email = AppConfig.userEmail ?? "";
                  await http.post(Uri.parse("${AppConfig.baseUrl}/admin/auditoria/limpiar?email=$email"));
                  _showSnack("Auditoría vaciada");
                  _loadAllAdminData();
                },
              ),
              icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: _accentRed),
              label: const Text("Vaciar Logs", style: TextStyle(color: _accentRed, fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 8),
        _auditorias.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text("No hay registros recientes", style: GoogleFonts.outfit(color: Colors.white54))))
            : Column(
                children: _auditorias.map((log) {
                  final desc = log['descripcion'] ?? '';
                  final modulo = log['modulo'] ?? 'SISTEMA';
                  final tipo = log['tipo'] ?? 'INFO';
                  final fecha = log['fechaHoraFormateada'] ?? '';

                  Color badgeColor = _accentCyan;
                  if (tipo == 'SUCCESS') badgeColor = _accentGreen;
                  if (tipo == 'WARNING') badgeColor = _accentGold;
                  if (tipo == 'DANGER') badgeColor = _accentRed;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: badgeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(tipo, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(desc, style: GoogleFonts.outfit(fontSize: 13, color: Colors.white)),
                              Text("$modulo • $fecha", style: GoogleFonts.outfit(fontSize: 11, color: Colors.white38)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 9. TAB: TECH 1428 CONSOLE
  // ═══════════════════════════════════════════════════════════
  Widget _buildTech1428Tab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGlassBanner(
          title: "Consola de Pruebas Tech 1428",
          value: "MODO PRUEBA ACTIVO",
          subtitle: "Herramientas de telecomunicación y diagnóstico IA",
          icon: Icons.code_rounded,
          color: _accentCyan,
        ),
        const SizedBox(height: 16),
        _buildTechSection(
          title: "1. Enviar Email de Prueba",
          icon: Icons.email_rounded,
          color: _accentCyan,
          children: [
            TextField(
              controller: _emailToController,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Destinatario (email)", labelStyle: TextStyle(color: Colors.white60)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailMsgController,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Cuerpo del Mensaje", labelStyle: TextStyle(color: Colors.white60)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendTestEmail,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text("Enviar Correo Simulado"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTechSection(
          title: "2. Enviar SMS / WhatsApp",
          icon: Icons.sms_rounded,
          color: _accentGreen,
          children: [
            TextField(
              controller: _smsToController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Número telefónico (+57...)", labelStyle: TextStyle(color: Colors.white60)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _smsMsgController,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Texto del mensaje", labelStyle: TextStyle(color: Colors.white60)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendTestSms("sms"),
                    icon: const Icon(Icons.sms_rounded, size: 16),
                    label: const Text("SMS"),
                    style: ElevatedButton.styleFrom(backgroundColor: _accentGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendTestSms("whatsapp"),
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text("WhatsApp"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        _buildTechSection(
          title: "3. Diagnóstico Veterinario con IA",
          icon: Icons.psychology_rounded,
          color: _accentPurple,
          children: [
            TextField(
              controller: _aiPromptController,
              maxLines: 2,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: "Prompt / Síntomas clínicos",
                hintText: "Ej: Perro Golden de 3 años con tos persistente...",
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _techLoading ? null : _analyzeAi,
                icon: _techLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.bolt_rounded, size: 16),
                label: const Text("Consultar Motor IA 1428"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentPurple),
              ),
            ),
            if (_aiResult.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
                child: Text(_aiResult, style: GoogleFonts.outfit(fontSize: 12, color: Colors.cyanAccent)),
              )
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildTechSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Future<void> _sendTestEmail() async {
    final to = _emailToController.text.trim();
    final body = _emailMsgController.text.trim();
    if (to.isEmpty || body.isEmpty) {
      _showSnack("Completa destinatario y mensaje", isError: true);
      return;
    }
    _confirmAction(
      title: "Enviar Email Simulado",
      content: "¿Confirmas el envío de prueba hacia $to?",
      onConfirm: () async {
        try {
          final res = await http.post(
            Uri.parse("${AppConfig.baseUrl}/1428/send-email"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"to": to, "body": body}),
          );
          if (res.statusCode == 200) {
            _showSnack("Email enviado correctamente");
          } else {
            _showSnack("Error al enviar email", isError: true);
          }
        } catch (e) {
          _showSnack("Fallo de conexión: $e", isError: true);
        }
      },
    );
  }

  Future<void> _sendTestSms(String type) async {
    final to = _smsToController.text.trim();
    final msg = _smsMsgController.text.trim();
    if (to.isEmpty || msg.isEmpty) {
      _showSnack("Completa destinatario y mensaje", isError: true);
      return;
    }
    _confirmAction(
      title: "Enviar $type",
      content: "¿Confirmas el envío de prueba hacia $to?",
      onConfirm: () async {
        try {
          final res = await http.post(
            Uri.parse("${AppConfig.baseUrl}/1428/send-sms"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"to": to, "message": msg, "type": type}),
          );
          if (res.statusCode == 200) {
            _showSnack("$type enviado correctamente");
          } else {
            _showSnack("Error al enviar $type", isError: true);
          }
        } catch (e) {
          _showSnack("Fallo de conexión: $e", isError: true);
        }
      },
    );
  }

  Future<void> _analyzeAi() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) {
      _showSnack("Ingresa síntomas o pregunta clínica", isError: true);
      return;
    }
    setState(() => _techLoading = true);
    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/1428/analyze-ai"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"prompt": prompt}),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => _aiResult = data['analysis'] ?? 'Sin respuesta');
      } else {
        _showSnack("Error en respuesta de IA", isError: true);
      }
    } catch (e) {
      _showSnack("Fallo de conexión: $e", isError: true);
    } finally {
      if (mounted) setState(() => _techLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // TAB: SUPERVISIÓN INDIVIDUAL Y MENSAJERÍA DIRECTA
  // ═══════════════════════════════════════════════════════════
  Widget _buildSupervisionTab() {
    final query = _supervisionSearchController.text.toLowerCase().trim();
    final filteredUsers = _supervisionUsers.where((u) {
      final name = (u['nombre'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadAllAdminData,
      color: _accentCyan,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGlassBanner(
            title: "Supervisión Individual de Usuarios",
            value: "${_supervisionUsers.where((u) => u['online'] == true).length} Online / ${_supervisionUsers.length} Total",
            subtitle: "Monitoreo en vivo de presencia y canal directo",
            icon: Icons.person_pin_rounded,
            color: _accentCyan,
          ),
          const SizedBox(height: 16),

          // Search Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _supervisionSearchController,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Buscar usuario por nombre o correo...",
                      hintStyle: GoogleFonts.outfit(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                if (_supervisionSearchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                    onPressed: () {
                      _supervisionSearchController.clear();
                      setState(() {});
                    },
                  )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active User Live Detail (if selected)
          if (_selectedUserSupervision != null) ...[
            _buildSelectedUserSupervisionCard(),
            const SizedBox(height: 20),
          ],

          Text(
            "Seleccionar Usuario para Supervisión",
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 10),

          if (filteredUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text("No se encontraron usuarios coincidentes", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
            )
          else
            ...filteredUsers.map((u) {
              final id = u['id'] ?? '';
              final name = u['nombre'] ?? 'Usuario';
              final email = u['email'] ?? '';
              final online = u['online'] == true;
              final seccion = u['seccion'] ?? 'Inactivo';
              final isSelected = _selectedUserSupervision != null && _selectedUserSupervision!['id'] == id;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _accentBlue.withOpacity(0.15) : _cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _accentCyan : (online ? _accentGreen.withOpacity(0.4) : Colors.white.withOpacity(0.06)),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: isSelected ? _accentBlue : const Color(0xFF1E293B),
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                          style: GoogleFonts.outfit(color: _accentCyan, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: online ? _accentGreen : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: _cardDark, width: 2),
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text(name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    "$email • ${online ? '📍 $seccion' : 'Desconectado'}",
                    style: GoogleFonts.outfit(color: online ? _accentGreen : Colors.white54, fontSize: 11),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (online ? _accentGreen : Colors.grey).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      online ? "EN LÍNEA" : "OFFLINE",
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: online ? _accentGreen : Colors.grey),
                    ),
                  ),
                  onTap: () => _loadIndividualUserSupervision(id),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Future<void> _loadIndividualUserSupervision(String userIdOrEmail) async {
    setState(() => _supervisionLoading = true);
    final email = AppConfig.userEmail ?? "";
    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/api/supervision/usuario/$userIdOrEmail/estado?email=$email"));
      if (res.statusCode == 200) {
        setState(() {
          _selectedUserSupervision = json.decode(res.body);
        });
      }
    } catch (e) {
      _showSnack("Error al cargar estado del usuario: $e", isError: true);
    } finally {
      setState(() => _supervisionLoading = false);
    }
  }

  Widget _buildSelectedUserSupervisionCard() {
    final u = _selectedUserSupervision!;
    final name = u['nombre'] ?? 'Usuario';
    final email = u['email'] ?? '';
    final online = u['online'] == true;
    final seccion = u['seccionActual'] ?? 'Desconocida';
    final timeRel = u['tiempoRelativo'] ?? 'Reciente';
    final ip = u['ip'] ?? '127.0.0.1';
    final disp = u['dispositivo'] ?? 'Desktop';
    final eventos = (u['eventosRecientes'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentCyan.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: _accentCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: online ? _accentGreen : Colors.grey, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text("SUPERVISIÓN ACTIVA", style: GoogleFonts.outfit(color: _accentCyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                onPressed: () => setState(() => _selectedUserSupervision = null),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(email, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 14),

          // KPI indicators
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sección Actual", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                      Text("📍 $seccion", style: GoogleFonts.outfit(color: _accentCyan, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Última Actividad", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                      Text("⏱️ $timeRel", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text("IP: $ip • Dispositivo: $disp", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic)),
          const SizedBox(height: 14),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showDirectMessageDialog(u['id'] ?? '', name),
                icon: const Icon(Icons.chat_bubble_rounded, size: 14),
                label: const Text("Mensaje"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentPurple),
              ),
              ElevatedButton.icon(
                onPressed: () => _showSuspensionDialog(u['id'] ?? '', name),
                icon: const Icon(Icons.block_rounded, size: 14),
                label: const Text("Suspender"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentRed),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCloseSessionsConfirm(u['id'] ?? '', name),
                icon: const Icon(Icons.power_settings_new_rounded, size: 14),
                label: const Text("Cerrar Sesiones"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentGold),
              ),
              ElevatedButton.icon(
                onPressed: () => _reactivateUserAccount(u['id'] ?? '', name),
                icon: const Icon(Icons.lock_open_rounded, size: 14),
                label: const Text("Reactivar"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentGreen),
              ),
              ElevatedButton.icon(
                onPressed: () => _showEmailSendDialog(email, name),
                icon: const Icon(Icons.email_rounded, size: 14),
                label: const Text("Correo"),
                style: ElevatedButton.styleFrom(backgroundColor: _accentBlue),
              ),
              OutlinedButton.icon(
                onPressed: () => _showVirtualSessionDialog(name, seccion, u['urlActual'] ?? '/'),
                icon: const Icon(Icons.remove_red_eye_rounded, size: 14, color: _accentCyan),
                label: const Text("Ver Sesión", style: TextStyle(color: _accentCyan)),
              ),
            ],
          ),

          if (eventos.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("Línea de Tiempo Reciente:", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            ...eventos.take(5).map((ev) {
              final sec = ev['seccion'] ?? 'Sistema';
              final acc = ev['accion'] ?? 'Navegó';
              final time = ev['fechaHora'] != null ? ev['fechaHora'].toString().split('T').last.split('.').first : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record_rounded, size: 8, color: _accentCyan),
                    const SizedBox(width: 8),
                    Text("[$time] ", style: const TextStyle(color: _accentCyan, fontSize: 10, fontFamily: 'monospace')),
                    Expanded(
                      child: Text("$acc ($sec)", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }).toList(),
          ]
        ],
      ),
    );
  }

  void _showDirectMessageDialog(String userId, String userName) {
    final msgCtrl = TextEditingController();
    final subjectCtrl = TextEditingController(text: "Mensaje del Administrador del Sistema");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Text("Mensaje a $userName", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: subjectCtrl,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Asunto", labelStyle: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: msgCtrl,
              maxLines: 4,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Mensaje Directo", labelStyle: TextStyle(color: Colors.white70), hintText: "Escribe el contenido que recibirá en su pantalla..."),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (msgCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final adminEmail = AppConfig.userEmail ?? "";
              try {
                final res = await http.post(
                  Uri.parse("${AppConfig.baseUrl}/api/supervision/mensajeria/enviar?email=$adminEmail"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({
                    "destinatarioId": userId,
                    "asunto": subjectCtrl.text,
                    "contenido": msgCtrl.text,
                    "adminEmail": adminEmail
                  }),
                );
                if (res.statusCode == 200) {
                  _showSnack("Mensaje despachado y notificado al usuario.");
                } else {
                  _showSnack("Error al enviar mensaje.", isError: true);
                }
              } catch (e) {
                _showSnack("Error de conexión: $e", isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accentPurple),
            child: const Text("Enviar Mensaje"),
          )
        ],
      ),
    );
  }

  void _showEmailSendDialog(String userEmail, String userName) {
    final subCtrl = TextEditingController(text: "Notificación Oficial de ClínicaApp");
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Text("Despachar Correo a $userName", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Destinatario: $userEmail", style: GoogleFonts.outfit(color: _accentGreen, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: subCtrl,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Asunto del Correo", labelStyle: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: bodyCtrl,
              maxLines: 4,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Cuerpo del Correo", labelStyle: TextStyle(color: Colors.white70), hintText: "Escribe el comunicado oficial por correo..."),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (bodyCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final adminEmail = AppConfig.userEmail ?? "";
              try {
                final res = await http.post(
                  Uri.parse("${AppConfig.baseUrl}/api/supervision/email/enviar?email=$adminEmail"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({
                    "destinatarioEmail": userEmail,
                    "asunto": subCtrl.text,
                    "contenido": bodyCtrl.text,
                    "adminEmail": adminEmail
                  }),
                );
                if (res.statusCode == 200) {
                  _showSnack("Correo despachado exitosamente por la pasarela.");
                } else {
                  _showSnack("Error al despachar el correo.", isError: true);
                }
              } catch (e) {
                _showSnack("Error de pasarela: $e", isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accentGreen),
            child: const Text("Despachar Correo"),
          )
        ],
      ),
    );
  }

  void _showSuspensionDialog(String userId, String userName) {
    final reasonCtrl = TextEditingController();
    String tipo = "TEMPORAL";
    int minutes = 60;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: _cardDark,
          title: Text("Suspender Cuenta: $userName", style: GoogleFonts.outfit(color: _accentRed, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tipo de Sanción:", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: tipo,
                dropdownColor: _cardDark,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                items: const [
                  DropdownMenuItem(value: "TEMPORAL", child: Text("Temporal (Auto-reactivable)")),
                  DropdownMenuItem(value: "PERMANENTE", child: Text("Permanente (Indefinida)")),
                ],
                onChanged: (v) {
                  if (v != null) setModalState(() => tipo = v);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              if (tipo == "TEMPORAL") ...[
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: "60",
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: "Duración en Minutos", labelStyle: TextStyle(color: Colors.white70)),
                  onChanged: (val) {
                    final p = int.tryParse(val);
                    if (p != null) minutes = p;
                  },
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: reasonCtrl,
                maxLines: 3,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "Motivo Obligatorio",
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: "Describe la infracción o causa...",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (reasonCtrl.text.trim().isEmpty) {
                  _showSnack("El motivo es obligatorio.", isError: true);
                  return;
                }
                Navigator.pop(ctx);
                final adminEmail = AppConfig.userEmail ?? "";
                try {
                  final res = await http.post(
                    Uri.parse("${AppConfig.baseUrl}/api/supervision/usuario/$userId/suspender?email=$adminEmail"),
                    headers: {"Content-Type": "application/json"},
                    body: json.encode({
                      "tipo": tipo,
                      "minutos": minutes,
                      "motivo": reasonCtrl.text.trim(),
                      "adminEmail": adminEmail
                    }),
                  );
                  if (res.statusCode == 200) {
                    _showSnack("Usuario suspendido exitosamente.");
                    _loadAllAdminData();
                  } else {
                    _showSnack("Error al suspender usuario.", isError: true);
                  }
                } catch (e) {
                  _showSnack("Error de conexión: $e", isError: true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _accentRed),
              child: const Text("Confirmar Suspensión"),
            )
          ],
        ),
      ),
    );
  }

  void _showCloseSessionsConfirm(String userId, String userName) {
    final reasonCtrl = TextEditingController(text: "Cierre administrativo de seguridad");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Text("Cerrar Sesiones de $userName", style: GoogleFonts.outfit(color: _accentGold, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Esto desconectará al usuario de cualquier app o navegador de inmediato.", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            TextFormField(
              controller: reasonCtrl,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(labelText: "Motivo", labelStyle: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final adminEmail = AppConfig.userEmail ?? "";
              try {
                final res = await http.post(
                  Uri.parse("${AppConfig.baseUrl}/api/supervision/usuario/$userId/cerrar-sesiones?email=$adminEmail"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({"motivo": reasonCtrl.text.trim(), "adminEmail": adminEmail}),
                );
                if (res.statusCode == 200) {
                  _showSnack("Sesiones revocadas forzosamente en el sistema.");
                } else {
                  _showSnack("Error al revocar sesiones.", isError: true);
                }
              } catch (e) {
                _showSnack("Error de conexión: $e", isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accentGold),
            child: const Text("Cerrar Sesiones"),
          )
        ],
      ),
    );
  }

  void _reactivateUserAccount(String userId, String userName) {
    _confirmAction(
      title: "Reactivar Cuenta",
      content: "¿Estás seguro de reactivar el acceso de $userName inmediatamente?",
      onConfirm: () async {
        final adminEmail = AppConfig.userEmail ?? "";
        try {
          final res = await http.post(
            Uri.parse("${AppConfig.baseUrl}/api/supervision/usuario/$userId/reactivar?email=$adminEmail"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"motivo": "Reactivación desde panel móvil", "adminEmail": adminEmail}),
          );
          if (res.statusCode == 200) {
            _showSnack("Cuenta de $userName reactivada correctamente.");
            _loadAllAdminData();
          } else {
            _showSnack("Error al reactivar la cuenta.", isError: true);
          }
        } catch (e) {
          _showSnack("Error de conexión: $e", isError: true);
        }
      },
    );
  }

  void _showVirtualSessionDialog(String userName, String seccion, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Row(
          children: [
            const Icon(Icons.display_settings_rounded, color: _accentCyan),
            const SizedBox(width: 8),
            Text("Visor de Sesión: $userName", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14), border: Border.all(color: _accentCyan.withOpacity(0.3))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("URL: $url", style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace')),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _accentGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text("ACTIVO", style: TextStyle(color: _accentGreen, fontSize: 8, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Icon(Icons.dashboard_customize_rounded, color: _accentCyan, size: 48),
                  const SizedBox(height: 10),
                  Text("Módulo: $seccion", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text("El usuario se encuentra interactuando con esta sección dentro de la aplicación.", textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cerrar Visor")),
        ],
      ),
    );
  }

  Widget _buildGlassBanner({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
                Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54)),
        ],
      ),
    );
  }

  void _confirmAction({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(content, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
            child: const Text("Confirmar"),
          )
        ],
      ),
    );
  }
}


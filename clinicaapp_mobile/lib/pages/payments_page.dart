import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../models/pago_usuario.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<PagoUsuario> _pagos = [];
  bool _loading = true;
  String _selectedFilter = "Todos";
  final List<String> _filters = ["Todos", "COMPLETADO", "PENDIENTE"];

  @override
  void initState() {
    super.initState();
    _fetchPagos();
  }

  Future<void> _fetchPagos() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}/pagos/usuario/${AppConfig.userEmail}"),
      );
      if (res.statusCode == 200 && mounted) {
        final List list = json.decode(res.body);
        setState(() {
          _pagos = list.map((e) => PagoUsuario.fromJson(e)).toList();
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PagoUsuario> get _filteredPagos {
    if (_selectedFilter == "Todos") return _pagos;
    return _pagos.where((p) => p.estado.toUpperCase() == _selectedFilter.toUpperCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalPagado = _pagos
        .where((p) => p.estado.toUpperCase() == "COMPLETADO")
        .fold(0.0, (acc, p) => acc + p.monto);
    final fmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final list = _filteredPagos;

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Mis Pagos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppleTheme.blue))
          : RefreshIndicator(
              onRefresh: _fetchPagos,
              color: AppleTheme.blue,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                children: [
                  // Balance Card estilo Apple Wallet
                  AppleCard(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppleBadge(text: "Apple Pay / Stripe", color: AppleTheme.indigo),
                            const AppleIconBox(icon: Icons.account_balance_wallet_rounded, color: AppleTheme.indigo),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Total Pagado",
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppleTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fmt.format(totalPagado),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppleTheme.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Filtros
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final f = _filters[idx];
                        final selected = _selectedFilter == f;
                        return ChoiceChip(
                          label: Text(
                            f == "COMPLETADO" ? "Completados" : (f == "PENDIENTE" ? "Pendientes" : "Todos"),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppleTheme.textSecondary,
                            ),
                          ),
                          selected: selected,
                          selectedColor: AppleTheme.blue,
                          backgroundColor: AppleTheme.surface,
                          side: BorderSide(color: selected ? AppleTheme.blue : AppleTheme.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onSelected: (_) => setState(() => _selectedFilter = f),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  AppleSectionHeader(title: "Transacciones (${list.length})"),
                  const SizedBox(height: 12),

                  if (list.isEmpty)
                    AppleCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "No hay pagos registrados.",
                            style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                          ),
                        ),
                      ),
                    )
                  else
                    ...list.map((p) {
                      final isDone = p.estado.toUpperCase() == "COMPLETADO";
                      final color = isDone ? AppleTheme.green : AppleTheme.orange;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppleCard(
                          onTap: () async {
                            final path = isDone
                                ? "${AppConfig.webBaseUrl}/usuario/pagos/factura/${p.citaId}/pdf"
                                : "${AppConfig.webBaseUrl}/usuario/pagos/${p.citaId}";
                            final uri = Uri.parse(path);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              AppleIconBox(
                                icon: isDone ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                color: color,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nombreServicio ?? p.nombreClinica ?? "Consulta Veterinaria",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppleTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.fecha,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppleTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    fmt.format(p.monto),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppleTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AppleBadge(text: p.estado, color: color),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

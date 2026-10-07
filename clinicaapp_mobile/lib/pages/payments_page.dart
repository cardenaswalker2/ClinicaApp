import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/pago_usuario.dart';

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

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

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
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PagoUsuario> get _filteredPagos {
    if (_selectedFilter == "Todos") return _pagos;
    return _pagos.where((p) => p.estado.toUpperCase() == _selectedFilter.toUpperCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    double totalPagado = _pagos
        .where((p) => p.estado.toUpperCase() == "COMPLETADO")
        .fold(0.0, (acc, p) => acc + p.monto);

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        title: Text("Mis Pagos y Facturas", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _auroraBase))
          : RefreshIndicator(
              onRefresh: _fetchPagos,
              color: _auroraBase,
              backgroundColor: _surfaceDark,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  _buildBalanceCard(totalPagado),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Historial de Transacciones", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("${_filteredPagos.length} items", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_filteredPagos.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredPagos.map((p) => _buildPagoCard(p)),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_auroraBase.withOpacity(0.2), _surfaceDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _auroraBase.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Invertido en Salud Animal", style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            "\$${total.toStringAsFixed(0)} COP",
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.greenAccent, size: 16),
              const SizedBox(width: 6),
              Text("Pagos seguros cifrados con Stripe", style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = filter),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _auroraBase : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? _auroraBase : Colors.white10),
                ),
                child: Text(
                  filter == "COMPLETADO" ? "Completados" : (filter == "PENDIENTE" ? "Pendientes" : "Todos"),
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPagoCard(PagoUsuario p) {
    final isCompletado = p.estado.toUpperCase() == "COMPLETADO" || p.estado.toUpperCase() == "PAGADO";
    final color = isCompletado ? Colors.greenAccent : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCompletado ? Icons.check_circle_outline_rounded : Icons.pending_outlined,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nombreServicio ?? "Consulta Veterinaria",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  "${p.nombreMascota ?? 'Mascota'} • ${p.nombreClinica ?? 'Clínica'}",
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  p.fecha.isNotEmpty ? p.fecha.split('T')[0] : "Fecha pendiente",
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${p.monto.toStringAsFixed(0)}",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompletado ? "PAGADO" : "PENDIENTE",
                  style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              "No hay registros de pago",
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Tus facturas y recibos de pago aparecerán en esta sección.",
              style: GoogleFonts.outfit(color: Colors.white30, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

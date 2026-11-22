import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/clinica.dart';
import '../models/mascota.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _motivoController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  List<Clinica> _clinicas = [];
  List<Mascota> _mascotas = [];
  Clinica? _selectedClinica;
  Mascota? _selectedMascota;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final clinicasRes = await http.get(Uri.parse("${AppConfig.baseUrl}/clinicas"));
      final mascotasRes = await http.get(Uri.parse("${AppConfig.baseUrl}/mascotas/usuario/${AppConfig.userEmail}"));

      if (mounted) {
        setState(() {
          if (clinicasRes.statusCode == 200) {
            _clinicas = (json.decode(clinicasRes.body) as List).map((e) => Clinica.fromJson(e)).toList();
          }
          if (mascotasRes.statusCode == 200) {
            _mascotas = (json.decode(mascotasRes.body) as List).map((e) => Mascota.fromJson(e)).toList();
          }
          if (_clinicas.isNotEmpty) _selectedClinica = _clinicas.first;
          if (_mascotas.isNotEmpty) _selectedMascota = _mascotas.first;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedClinica == null || _selectedMascota == null || _motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor completa todos los campos")));
      return;
    }

    setState(() => _isSubmitting = true);
    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/citas"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "fechaHora": finalDateTime.toIso8601String(),
          "motivo": _motivoController.text.trim(),
          "usuarioId": AppConfig.userId,
          "clinicaId": _selectedClinica!.id,
          "mascotaId": _selectedMascota!.id,
          "estado": "Pendiente",
          "estadoPago": "PENDIENTE",
        }),
      );

      if (mounted) {
        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Cita agendada con éxito!")));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al agendar la cita")));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error de conexión")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Agendar Cita"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppleTheme.blue))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              child: AppleCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mascota", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppleTheme.textSecondary)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Mascota>(
                      value: _selectedMascota,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppleTheme.surfaceSecondary,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppleTheme.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppleTheme.border)),
                      ),
                      items: _mascotas.map((m) => DropdownMenuItem(value: m, child: Text("${m.nombre} (${m.especie})"))).toList(),
                      onChanged: (v) => setState(() => _selectedMascota = v),
                    ),
                    const SizedBox(height: 16),

                    Text("Clínica Veterinaria", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppleTheme.textSecondary)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Clinica>(
                      value: _selectedClinica,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppleTheme.surfaceSecondary,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppleTheme.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppleTheme.border)),
                      ),
                      items: _clinicas.map((c) => DropdownMenuItem(value: c, child: Text(c.nombre, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedClinica = v),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: AppleCard(
                            onTap: _selectDate,
                            color: AppleTheme.surfaceSecondary,
                            padding: const EdgeInsets.all(14),
                            borderRadius: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Fecha", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppleTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppleTheme.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppleCard(
                            onTap: _selectTime,
                            color: AppleTheme.surfaceSecondary,
                            padding: const EdgeInsets.all(14),
                            borderRadius: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Hora", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppleTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedTime.format(context),
                                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppleTheme.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    AppleTextField(
                      controller: _motivoController,
                      label: "Motivo de la consulta",
                      hint: "Ej. Vacunación anual, control general...",
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 22),

                    AppleButton(
                      text: "Confirmar Cita",
                      icon: Icons.check_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

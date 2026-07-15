import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/clinica.dart';
import '../models/mascota.dart';

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

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final clinicasRes = await http.get(Uri.parse("${AppConfig.baseUrl}/clinicas"));
      final mascotasRes = await http.get(Uri.parse("${AppConfig.baseUrl}/mascotas/usuario/${AppConfig.userEmail}"));

      if (mounted) {
        setState(() {
          _clinicas = (json.decode(clinicasRes.body) as List)
              .map((e) => Clinica.fromJson(e))
              .toList();
          _mascotas = (json.decode(mascotasRes.body) as List)
              .map((e) => Mascota.fromJson(e))
              .toList();
          if (_clinicas.isNotEmpty) _selectedClinica = _clinicas.first;
          if (_mascotas.isNotEmpty) _selectedMascota = _mascotas.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _auroraBase, onPrimary: Colors.white, surface: _surfaceDark),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedClinica == null || _selectedMascota == null || _motivoController.text.isEmpty) {
      _showSnackBar("Por favor completa todos los campos");
      return;
    }

    setState(() => _isSubmitting = true);

    final finalDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
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

      if (res.statusCode == 200) {
        _showSnackBar("¡Cita agendada con éxito!");
        Navigator.pop(context, true);
      } else {
        _showSnackBar("Error al agendar la cita");
      }
    } catch (e) {
      _showSnackBar("Error de conexión");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, softWrap: true),
        backgroundColor: _auroraBase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        title: Text("Agendar Cita", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _auroraBase))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Selecciona tu mascota"),
                  _buildMascotaSelector(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Selecciona la clínica"),
                  _buildClinicaSelector(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Fecha y Hora"),
                  _buildDateTimePicker(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Motivo de la consulta"),
                  _buildMotivoField(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
      ),
    );
  }

  Widget _buildMascotaSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _surfaceDark, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Mascota>(
          value: _selectedMascota,
          dropdownColor: _surfaceDark,
          isExpanded: true,
          items: _mascotas.map((m) => DropdownMenuItem(
            value: m,
            child: Text(m.nombre, style: GoogleFonts.outfit(color: Colors.white)),
          )).toList(),
          onChanged: (val) => setState(() => _selectedMascota = val),
        ),
      ),
    );
  }

  Widget _buildClinicaSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _surfaceDark, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Clinica>(
          value: _selectedClinica,
          dropdownColor: _surfaceDark,
          isExpanded: true,
          items: _clinicas.map((c) => DropdownMenuItem(
            value: c,
            child: Text(c.nombre, style: GoogleFonts.outfit(color: Colors.white)),
          )).toList(),
          onChanged: (val) => setState(() => _selectedClinica = val),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _surfaceDark, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: _auroraBase, size: 20),
                  const SizedBox(width: 12),
                  Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: GoogleFonts.outfit(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _surfaceDark, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: _auroraBase, size: 20),
                  const SizedBox(width: 12),
                  Text(_selectedTime.format(context), style: GoogleFonts.outfit(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivoField() {
    return TextField(
      controller: _motivoController,
      maxLines: 3,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Escribe el motivo...",
        hintStyle: GoogleFonts.outfit(color: Colors.white24),
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _auroraBase,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Confirmar Cita", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

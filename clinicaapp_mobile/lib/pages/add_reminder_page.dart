import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/recordatorio.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  String _tipo = 'GMAIL';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa un título para el recordatorio")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final recordatorio = Recordatorio(
        titulo: _tituloController.text.trim(),
        descripcion: _descController.text.trim(),
        fechaHora: _selectedDate.toIso8601String(),
        tipo: _tipo,
        estado: 'PENDIENTE',
        usuarioId: AppConfig.userId ?? '',
      );

      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/recordatorios"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(recordatorio.toJson()),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recordatorio guardado")));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se pudo guardar")));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error de conexión")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Nuevo Recordatorio"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: AppleCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppleTextField(
                controller: _tituloController,
                label: "Título *",
                hint: "Ej. Vacuna antirrábica",
                prefixIcon: Icons.alarm_add_rounded,
              ),
              const SizedBox(height: 14),
              AppleTextField(
                controller: _descController,
                label: "Descripción",
                hint: "Notas adicionales...",
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Text("Canal de alerta", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppleTheme.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: ['GMAIL', 'SMS', 'APP'].map((t) {
                  final selected = _tipo == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            t,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : AppleTheme.textSecondary,
                            ),
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppleTheme.blue,
                        backgroundColor: AppleTheme.surfaceSecondary,
                        side: BorderSide(color: selected ? AppleTheme.blue : AppleTheme.border),
                        onSelected: (_) => setState(() => _tipo = t),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              AppleCard(
                onTap: _pickDate,
                color: AppleTheme.surfaceSecondary,
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Fecha programada", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppleTheme.textSecondary)),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppleTheme.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              AppleButton(
                text: "Guardar Recordatorio",
                icon: Icons.check_rounded,
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

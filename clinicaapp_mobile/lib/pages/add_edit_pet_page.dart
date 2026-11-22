import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/mascota.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class AddEditPetPage extends StatefulWidget {
  final Mascota? mascota;
  const AddEditPetPage({super.key, this.mascota});

  @override
  State<AddEditPetPage> createState() => _AddEditPetPageState();
}

class _AddEditPetPageState extends State<AddEditPetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _razaCtrl;
  late TextEditingController _fotoUrlCtrl;
  late TextEditingController _edadCtrl;
  String _especie = "PERRO";
  String _sexo = "Macho";
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.mascota;
    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    _razaCtrl = TextEditingController(text: m?.raza ?? '');
    _fotoUrlCtrl = TextEditingController(text: m?.fotoUrl ?? '');
    _edadCtrl = TextEditingController(text: m != null && m.edad > 0 ? '${m.edad}' : '');
    if (m != null) {
      if (['PERRO', 'GATO', 'OTRO'].contains(m.especie.toUpperCase())) {
        _especie = m.especie.toUpperCase();
      }
      if (['Macho', 'Hembra'].contains(m.sexo)) {
        _sexo = m.sexo;
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _razaCtrl.dispose();
    _fotoUrlCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarMascota() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final payload = {
      if (widget.mascota != null) 'id': widget.mascota!.id,
      'nombre': _nombreCtrl.text.trim(),
      'especie': _especie,
      'razaPersonalizada': _razaCtrl.text.trim(),
      'sexo': _sexo,
      'fotoUrl': _fotoUrlCtrl.text.trim(),
      'edad': int.tryParse(_edadCtrl.text.trim()) ?? 0,
      'propietarioId': AppConfig.userId ?? '',
    };

    try {
      final isEdit = widget.mascota != null;
      final url = isEdit
          ? "${AppConfig.baseUrl}/mascotas/${widget.mascota!.id}"
          : "${AppConfig.baseUrl}/mascotas";

      final response = isEdit
          ? await http.put(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(payload))
          : await http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(payload));

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? "Mascota actualizada" : "Mascota registrada")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se pudo guardar la mascota")),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error de conexión")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mascota != null;

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: Text(isEdit ? "Editar Mascota" : "Nueva Mascota"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Form(
          key: _formKey,
          child: AppleCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppleTextField(
                  controller: _nombreCtrl,
                  label: "Nombre de la mascota *",
                  prefixIcon: Icons.pets_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Ingresa el nombre" : null,
                ),
                const SizedBox(height: 16),

                Text("Especie", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppleTheme.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: ["PERRO", "GATO", "OTRO"].map((esp) {
                    final selected = _especie == esp;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              esp,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : AppleTheme.textSecondary,
                              ),
                            ),
                          ),
                          selected: selected,
                          selectedColor: AppleTheme.blue,
                          backgroundColor: AppleTheme.surfaceSecondary,
                          side: BorderSide(color: selected ? AppleTheme.blue : AppleTheme.border),
                          onSelected: (_) => setState(() => _especie = esp),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                AppleTextField(
                  controller: _razaCtrl,
                  label: "Raza",
                  prefixIcon: Icons.category_outlined,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AppleTextField(
                        controller: _edadCtrl,
                        label: "Edad (años)",
                        prefixIcon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sexo,
                        decoration: InputDecoration(
                          labelText: "Sexo",
                          filled: true,
                          fillColor: AppleTheme.surfaceSecondary,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppleTheme.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppleTheme.border)),
                        ),
                        items: ["Macho", "Hembra"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _sexo = v ?? "Macho"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AppleTextField(
                  controller: _fotoUrlCtrl,
                  label: "URL de foto (opcional)",
                  prefixIcon: Icons.image_outlined,
                ),
                const SizedBox(height: 22),

                AppleButton(
                  text: isEdit ? "Guardar Cambios" : "Registrar Mascota",
                  icon: Icons.check_rounded,
                  isLoading: _isSaving,
                  onPressed: _guardarMascota,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

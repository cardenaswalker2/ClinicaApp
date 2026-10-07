import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/mascota.dart';

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

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

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
          ? await http.put(
              Uri.parse(url),
              headers: {"Content-Type": "application/json"},
              body: json.encode(payload),
            )
          : await http.post(
              Uri.parse(url),
              headers: {"Content-Type": "application/json"},
              body: json.encode(payload),
            );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? "¡Mascota actualizada!" : "¡Mascota registrada!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al guardar: ${response.body}"), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mascota != null;

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        title: Text(
          isEdit ? "Editar Mascota" : "Registrar Mascota",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel("Nombre de la mascota"),
              _buildTextField(_nombreCtrl, "Ej. Luna, Toby", Icons.pets, validator: (v) {
                if (v == null || v.trim().isEmpty) return "El nombre es obligatorio";
                return null;
              }),
              const SizedBox(height: 20),
              _buildFieldLabel("Especie"),
              _buildEspecieSelector(),
              const SizedBox(height: 20),
              _buildFieldLabel("Raza"),
              _buildTextField(_razaCtrl, "Ej. Golden Retriever, Siames, Mestizo", Icons.category_rounded),
              const SizedBox(height: 20),
              _buildFieldLabel("Sexo"),
              _buildSexoSelector(),
              const SizedBox(height: 20),
              _buildFieldLabel("Edad aproximada (años)"),
              _buildTextField(_edadCtrl, "Ej. 3", Icons.cake_rounded, keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _buildFieldLabel("URL de la Foto (Opcional)"),
              _buildTextField(_fotoUrlCtrl, "https://...", Icons.image_rounded),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarMascota,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _auroraBase,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? "Guardar Cambios" : "Registrar Mascota",
                          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon,
      {String? Function(String?)? validator, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: Colors.white24),
        prefixIcon: Icon(icon, color: _auroraBase),
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildEspecieSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _surfaceDark, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _especie,
          dropdownColor: _surfaceDark,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "PERRO", child: Text("Perro 🐶", style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: "GATO", child: Text("Gato 🐱", style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: "OTRO", child: Text("Otro 🦜", style: TextStyle(color: Colors.white))),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _especie = val);
          },
        ),
      ),
    );
  }

  Widget _buildSexoSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _sexo = "Macho"),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _sexo == "Macho" ? _auroraBase.withOpacity(0.25) : _surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _sexo == "Macho" ? _auroraBase : Colors.white10),
              ),
              child: Center(
                child: Text("Macho ♂", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _sexo = "Hembra"),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _sexo == "Hembra" ? Colors.pinkAccent.withOpacity(0.25) : _surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _sexo == "Hembra" ? Colors.pinkAccent : Colors.white10),
              ),
              child: Center(
                child: Text("Hembra ♀", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

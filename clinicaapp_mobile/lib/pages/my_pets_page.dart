import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/mascota.dart';
import 'add_edit_pet_page.dart';
import 'pet_medical_history_page.dart';
import 'book_appointment_page.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  List<Mascota> _pets = [];
  bool _loading = true;

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}/mascotas/usuario/${AppConfig.userEmail}"),
      );
      if (res.statusCode == 200 && mounted) {
        final List list = json.decode(res.body);
        setState(() {
          _pets = list.map((e) => Mascota.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _eliminarMascota(Mascota m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: _surfaceDark,
        title: Text("Eliminar a ${m.nombre}", style: const TextStyle(color: Colors.white)),
        content: const Text("¿Estás seguro de que deseas eliminar este registro?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final res = await http.delete(Uri.parse("${AppConfig.baseUrl}/mascotas/${m.id}"));
        if (res.statusCode == 200) {
          _fetchPets();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${m.nombre} ha sido eliminado"), backgroundColor: Colors.orangeAccent),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al eliminar: $e"), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        title: Text("Mis Mascotas", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: _auroraBase, size: 28),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddEditPetPage()),
              );
              if (result == true) _fetchPets();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _auroraBase))
          : RefreshIndicator(
              onRefresh: _fetchPets,
              color: _auroraBase,
              backgroundColor: _surfaceDark,
              child: _pets.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      itemCount: _pets.length,
                      itemBuilder: (context, index) => _buildPetCard(_pets[index]),
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AddEditPetPage()),
          );
          if (result == true) _fetchPets();
        },
        backgroundColor: _auroraBase,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Registrar Mascota", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildPetCard(Mascota m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: _auroraBase.withOpacity(0.15),
                  backgroundImage: m.fotoUrl.isNotEmpty ? NetworkImage(m.fotoUrl) : null,
                  child: m.fotoUrl.isEmpty ? const Icon(Icons.pets, color: _auroraBase, size: 36) : null,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.nombre,
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${m.especie} • ${m.raza}",
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildBadge(m.sexo, m.sexo == "Hembra" ? Colors.pinkAccent : _auroraBase),
                          const SizedBox(width: 8),
                          if (m.edad > 0)
                            _buildBadge("${m.edad} años", Colors.orangeAccent),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white38),
                  color: _surfaceDark,
                  onSelected: (val) async {
                    if (val == 'edit') {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => AddEditPetPage(mascota: m)),
                      );
                      if (res == true) _fetchPets();
                    } else if (val == 'delete') {
                      _eliminarMascota(m);
                    }
                  },
                  itemBuilder: (c) => [
                    const PopupMenuItem(value: 'edit', child: Text("Editar", style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 'delete', child: Text("Eliminar", style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.04), height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => PetMedicalHistoryPage(mascota: m)),
                      );
                    },
                    icon: const Icon(Icons.history_edu_rounded, size: 18, color: Colors.white70),
                    label: Text("Historial", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const BookAppointmentPage()),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_rounded, size: 18, color: Colors.white),
                    label: Text("Agendar Cita", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _auroraBase,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 70, color: Colors.white24),
            const SizedBox(height: 20),
            Text(
              "No tienes mascotas registradas",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Registra a tus peluditos para gestionar su historial médico y citas.",
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

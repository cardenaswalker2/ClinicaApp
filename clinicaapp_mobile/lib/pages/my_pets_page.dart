import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/mascota.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';
import 'add_edit_pet_page.dart';
import 'pet_detail_page.dart';
import 'pet_medical_history_page.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  List<Mascota> _pets = [];
  bool _loading = true;

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
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _eliminarMascota(Mascota m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppleTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Eliminar a ${m.nombre}",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppleTheme.textPrimary),
        ),
        content: Text(
          "¿Estás seguro de que deseas eliminar este registro?",
          style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text("Cancelar", style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppleTheme.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Eliminar", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
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
              SnackBar(content: Text("${m.nombre} ha sido eliminado")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al eliminar: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Mis Mascotas"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppleTheme.blue, size: 28),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditPetPage()),
              );
              if (result == true) _fetchPets();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppleTheme.blue))
          : RefreshIndicator(
              onRefresh: _fetchPets,
              color: AppleTheme.blue,
              child: _pets.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 60),
                        AppleCard(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              const AppleIconBox(icon: Icons.pets_rounded, color: AppleTheme.blue, size: 64, iconSize: 32),
                              const SizedBox(height: 16),
                              Text(
                                "Sin mascotas registradas",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppleTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Agrega a tu primera mascota para llevar su historial clínico y vacunas.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppleTheme.textSecondary),
                              ),
                              const SizedBox(height: 20),
                              AppleButton(
                                text: "Agregar Mascota",
                                icon: Icons.add_rounded,
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AddEditPetPage()),
                                  );
                                  if (result == true) _fetchPets();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      itemCount: _pets.length,
                      itemBuilder: (context, index) {
                        final pet = _pets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppleCard(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PetDetailPage(mascota: pet)),
                              );
                              _fetchPets();
                            },
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const AppleIconBox(icon: Icons.pets_rounded, color: AppleTheme.blue, size: 52, iconSize: 26),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  pet.nombre,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppleTheme.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              AppleBadge(text: pet.especie, color: AppleTheme.teal),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${pet.raza} • ${pet.edad} años • ${pet.sexo}",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: AppleTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => PetMedicalHistoryPage(mascota: pet)),
                                      ),
                                      icon: const Icon(Icons.medical_services_outlined, size: 17, color: AppleTheme.blue),
                                      label: Text("Historial", style: GoogleFonts.plusJakartaSans(color: AppleTheme.blue, fontWeight: FontWeight.w600)),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: AppleTheme.textSecondary, size: 20),
                                          onPressed: () async {
                                            final res = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => AddEditPetPage(mascota: pet)),
                                            );
                                            if (res == true) _fetchPets();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: AppleTheme.red, size: 20),
                                          onPressed: () => _eliminarMascota(pet),
                                        ),
                                      ],
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
    );
  }
}

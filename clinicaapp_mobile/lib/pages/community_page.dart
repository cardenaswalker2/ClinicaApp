import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<dynamic> _posts = [];
  bool _loading = true;
  String _selectedTab = "Todas";

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/comunidad"));
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _posts = json.decode(res.body) as List;
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _newPostDialog() {
    final nombreCtrl = TextEditingController();
    final historiaCtrl = TextEditingController();
    String especie = "Perro";
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppleTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(22, 20, 22, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Publicar en Comunidad", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Row(
                children: ["Perro", "Gato", "Otro"].map((t) {
                  final sel = especie == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(child: Text(t)),
                        selected: sel,
                        selectedColor: AppleTheme.blue,
                        labelStyle: TextStyle(color: sel ? Colors.white : AppleTheme.textPrimary, fontWeight: FontWeight.w600),
                        onSelected: (_) => setModal(() => especie = t),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              AppleTextField(controller: nombreCtrl, label: "Título / Nombre de mascota", prefixIcon: Icons.pets_rounded),
              const SizedBox(height: 12),
              AppleTextField(controller: historiaCtrl, label: "Historia o mensaje", prefixIcon: Icons.notes_rounded, maxLines: 3),
              const SizedBox(height: 18),
              AppleButton(
                text: "Publicar en Servidor",
                isLoading: saving,
                onPressed: () async {
                  if (nombreCtrl.text.trim().isEmpty || historiaCtrl.text.trim().isEmpty) return;
                  setModal(() => saving = true);
                  try {
                    final res = await http.post(
                      Uri.parse("${AppConfig.baseUrl}/comunidad"),
                      headers: {"Content-Type": "application/json"},
                      body: json.encode({
                        "nombre": nombreCtrl.text.trim(),
                        "especie": especie,
                        "historia": historiaCtrl.text.trim(),
                        "nombrePublicador": AppConfig.userName ?? "Usuario",
                        "propietarioId": AppConfig.userId ?? "",
                      }),
                    );
                    if (res.statusCode == 200 && ctx.mounted) {
                      Navigator.pop(ctx);
                      _fetchPosts();
                    }
                  } catch (_) {}
                  if (ctx.mounted) setModal(() => saving = false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _selectedTab == "Todas"
        ? _posts
        : _posts.where((p) => (p["especie"] ?? "").toString().toLowerCase() == _selectedTab.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Comunidad Pet"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppleTheme.blue, size: 28),
            onPressed: _newPostDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppleTheme.blue))
          : RefreshIndicator(
              onRefresh: _fetchPosts,
              color: AppleTheme.blue,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ["Todas", "Perro", "Gato"].map((tab) {
                        final sel = _selectedTab == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              tab,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : AppleTheme.textSecondary,
                              ),
                            ),
                            selected: sel,
                            selectedColor: AppleTheme.blue,
                            backgroundColor: AppleTheme.surface,
                            side: BorderSide(color: sel ? AppleTheme.blue : AppleTheme.border),
                            onSelected: (_) => setState(() => _selectedTab = tab),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (visible.isEmpty)
                    AppleCard(
                      child: Text(
                        "Aún no hay publicaciones. ¡Sé el primero en publicar!",
                        style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                      ),
                    )
                  else
                    ...visible.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppleCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p["nombrePublicador"] ?? "Comunidad ClinicaApp",
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppleTheme.textSecondary),
                                  ),
                                  AppleBadge(text: p["especie"] ?? "Mascota", color: AppleTheme.green),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p["nombre"] ?? "Mascota",
                                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppleTheme.textPrimary),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p["historia"] ?? "",
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppleTheme.textSecondary, height: 1.45),
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

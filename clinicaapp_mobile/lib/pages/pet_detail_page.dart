import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mascota.dart';
import '../config/app_config.dart';

class PetDetailPage extends StatefulWidget {
  final Mascota mascota;
  const PetDetailPage({super.key, required this.mascota});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> with TickerProviderStateMixin {
  late Mascota _mascota;
  bool _isLoading = false;

  late AnimationController _floatController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _bgDark = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _mascota = widget.mascota;
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 200 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Future<void> _refreshPet() async {
    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/mascotas/${_mascota.id}"));
      if (res.statusCode == 200) {
        setState(() {
          _mascota = Mascota.fromJson(json.decode(res.body));
        });
      }
    } catch (e) {
      debugPrint("Error refreshing pet: $e");
    }
  }

  Future<void> _addPhoto(String url) async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/mascotas/${_mascota.id}/album"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(url),
      );
      if (res.statusCode == 200) {
        await _refreshPet();
      }
    } catch (e) {
      debugPrint("Error adding photo: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deletePhoto(String url) async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}/mascotas/${_mascota.id}/album/eliminar"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(url),
      );
      if (res.statusCode == 200) {
        await _refreshPet();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto eliminada correctamente")));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al eliminar: Código ${res.statusCode}")));
        }
      }
    } catch (e) {
      debugPrint("Error deleting photo: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error de red: $e")));
      }
    }
    setState(() => _isLoading = false);
  }

  void _showAddPhotoDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Nueva Foto", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Pega la URL de la imagen que quieres añadir al álbum.", style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "https://...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addPhoto(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _auroraBase),
            child: const Text("Añadir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPetHeader(),
                      const SizedBox(height: 28),
                      _buildInfoCards(),
                      const SizedBox(height: 32),
                      _buildHealthSection(),
                      const SizedBox(height: 32),
                      _buildAlbumSection(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBackButton(),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: _auroraBase)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 380,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: _mascota.id,
              child: _mascota.fotoUrl.isNotEmpty
                  ? Image.network(_mascota.fotoUrl, fit: BoxFit.cover)
                  : Container(color: _surfaceDark, child: const Icon(Icons.pets, size: 80, color: Colors.white10)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _bgDark.withOpacity(0.95)],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_mascota.nombre, style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildBadge(_mascota.especie, _auroraBase),
            const SizedBox(width: 10),
            _buildBadge(_mascota.raza, Colors.white.withOpacity(0.4)),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildInfoCards() {
    final info = [
      {"icon": Icons.cake, "label": "Edad", "value": "${_mascota.edad} años", "color": Colors.orangeAccent},
      {"icon": _mascota.sexo.toLowerCase() == "macho" ? Icons.male : Icons.female, "label": "Sexo", "value": _mascota.sexo, "color": Colors.pinkAccent},
    ];
    return Row(
      children: info.map((item) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item["icon"] as IconData, color: item["color"] as Color, size: 24),
              const SizedBox(height: 12),
              Text(item["label"] as String, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
              Text(item["value"] as String, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildHealthSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Estado de Salud", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildHealthRow(Icons.vaccines, "Vacunas", "Al día", Colors.greenAccent),
          const SizedBox(height: 12),
          _buildHealthRow(Icons.favorite, "Peso", "4.5 kg", _auroraBase),
        ],
      ),
    );
  }

  Widget _buildHealthRow(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.outfit(color: Colors.white60)),
          ],
        ),
        Text(value, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAlbumSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Álbum de Fotos", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(
              onPressed: _showAddPhotoDialog,
              icon: const Icon(Icons.add_a_photo_rounded, color: _auroraBase),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _mascota.albumFotos.length,
          itemBuilder: (context, index) {
            final url = _mascota.albumFotos[index];
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => _showPhotoFullScreen(url),
                  onLongPress: () => _showDeletePhotoDialog(url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(url, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () => _showDeletePhotoDialog(url),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showPhotoFullScreen(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87,
                child: InteractiveViewer(
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePhotoDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceDark,
        title: const Text("Eliminar Foto", style: TextStyle(color: Colors.white)),
        content: const Text("¿Estás seguro de que quieres eliminar esta foto del álbum?", style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              _deletePhoto(url);
              Navigator.pop(context);
            },
            child: const Text("Sí, eliminar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        style: IconButton.styleFrom(backgroundColor: Colors.black26),
      ),
    );
  }
}

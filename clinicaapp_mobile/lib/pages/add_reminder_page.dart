import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../models/recordatorio.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage>
    with SingleTickerProviderStateMixin {
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  String _tipo = 'GMAIL';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;

  // ─── Luxury Aurora Palette ───
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraAccent = Color(0xFF22D3EE);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDeep = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);
  static const Color _surfaceElevated = Color(0xFF1E293B);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _tituloController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ─── Lógica original preservada exactamente ───
  Future<void> _save() async {
    if (_tituloController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final recordatorio = Recordatorio(
        titulo: _tituloController.text.trim(),
        descripcion: _descController.text.trim(),
        fechaHora: _selectedDate.toIso8601String(),
        tipo: _tipo,
        estado: 'PENDIENTE',
        usuarioId: AppConfig.userId!,
      );

      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/recordatorios"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(recordatorio.toJson()),
      );

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Glassmorphism Decoration Factory ───
  BoxDecoration _glassDecoration({
    bool glow = false,
    double radius = 20,
    Color? customBorder,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.03),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: customBorder ?? (glow
            ? _auroraBase.withOpacity(0.4)
            : Colors.white.withOpacity(0.1)),
        width: glow ? 1.5 : 1,
      ),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: _auroraBase.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDeep,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ─── Background Aurora Gradient ───
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _auroraBase.withOpacity(0.15),
                    _bgDeep,
                    _bgDeep,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // ─── Floating Aurora Orbs (Decorativos) ───
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _auroraBase.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _auroraAccent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ─── Main Content ───
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Header ───
                      Row(
                        children: [
                          _buildGlassIconButton(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nuevo Aviso",
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Programa un recordatorio inteligente",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // ─── Título ───
                      _buildSectionLabel("¿Qué hay que hacer?"),
                      const SizedBox(height: 12),
                      _buildGlassInput(
                        hint: "Título (ej: Vacuna de Rabia)",
                        controller: _tituloController,
                        icon: Icons.edit_note_rounded,
                      ),
                      const SizedBox(height: 28),

                      // ─── Descripción ───
                      _buildSectionLabel("Detalles adicionales"),
                      const SizedBox(height: 12),
                      _buildGlassInput(
                        hint: "Descripción",
                        controller: _descController,
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 28),

                      // ─── Medio de aviso ───
                      _buildSectionLabel("Medio de aviso"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildChoiceChip('GMAIL', Icons.email_outlined),
                          const SizedBox(width: 12),
                          _buildChoiceChip('SMS', Icons.chat_bubble_outline_rounded),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ─── Fecha ───
                      _buildSectionLabel("Fecha del aviso"),
                      const SizedBox(height: 12),
                      _buildDatePicker(),
                      const SizedBox(height: 40),

                      // ─── Botón Guardar ───
                      _buildSaveButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widgets Luxury ───

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_auroraBase, _auroraAccent],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: _glassDecoration(glow: false, radius: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(0.3),
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 50,
                minHeight: 56,
              ),
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.25),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String val, IconData icon) {
    final bool selected = _tipo == val;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _tipo = val);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 64,
          decoration: selected
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_auroraBase, _auroraAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _auroraBase.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : _glassDecoration(glow: false, radius: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: selected ? 0 : 20, sigmaY: selected ? 0 : 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      icon,
                      size: 22,
                      color: selected ? Colors.white : Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    val,
                    style: GoogleFonts.outfit(
                      color: selected ? Colors.white : Colors.white.withOpacity(0.5),
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: _auroraBase,
                  onPrimary: Colors.white,
                  surface: _surfaceDark,
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: _bgDeep,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 72,
        decoration: _glassDecoration(glow: true, radius: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_auroraBase, _auroraAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _auroraBase.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Fecha seleccionada",
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(_selectedDate),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.3),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      height: 64,
      decoration: _isLoading
          ? _glassDecoration(glow: false, radius: 20)
          : BoxDecoration(
              gradient: const LinearGradient(
                colors: [_auroraBase, _auroraAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _auroraBase.withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: _auroraAccent.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    _save();
                  },
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.transparent,
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.7),
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Guardar Aviso",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: _glassDecoration(radius: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return "${date.day} de ${months[date.month - 1]}, ${date.year}";
  }
}
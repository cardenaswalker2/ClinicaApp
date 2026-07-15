import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import '../config/app_config.dart';

// ============================================================
// AI CHAT PAGE - LUXURY AURORA EDITION
// Lógica de chat, API y scroll 100% preservada
// ============================================================

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════
  // CONTROLLERS & STATE - LÓGICA ORIGINAL PRESERVADA
  // ═══════════════════════════════════════════════════════════
  final List<Map<String, dynamic>> _messages = [
    {
      "role": "ai",
      "content":
          "¡Hola! Soy Guido 🤖, tu asistente experto en salud animal. ¿En qué puedo ayudarte hoy?"
    }
  ];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  // ── Animaciones ──
  late AnimationController _aurora;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _typingDots;

  // ── Colores Luxury Aurora ──
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraDeep = Color(0xFF0284C7);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDark = Color(0xFF020617);

  @override
  void initState() {
    super.initState();
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _typingDots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  // ═══════════════════════════════════════════════════════════
  // SEND MESSAGE - LÓGICA ORIGINAL 100% PRESERVADA
  // ═══════════════════════════════════════════════════════════

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    String userMsg = _controller.text.trim();
    setState(() {
      _messages.add({"role": "user", "content": userMsg});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/nova-brain/think"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "mensaje": userMsg,
          "contexto": {
            "user": AppConfig.userName ?? "Usuario",
            "userId": AppConfig.userId ?? ""
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add({
            "role": "ai",
            "content": data['respuesta'] ??
                "¡Perdona! No pude entenderte bien. 🐾"
          });
          _isTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "ai",
          "content":
              "Ups, parece que perdí la conexión con mi cerebro artificial. 🔌"
        });
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  // ═══════════════════════════════════════════════════════════
  // SCROLL TO BOTTOM - LÓGICA ORIGINAL 100% PRESERVADA
  // ═══════════════════════════════════════════════════════════

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _aurora.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _typingDots.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // ── Fondo Aurora Animado ──
          _buildBackground(),
          // ── Orbes flotantes ──
          _buildFloatingOrbs(),
          // ── Contenido Principal ──
          SafeArea(
            child: Column(
              children: [
                // ── Header ──
                _buildHeader(),
                // ── Lista de mensajes ──
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _buildChatBubble(_messages[index], index),
                  ),
                ),
                // ── Indicador de escritura ──
                if (_isTyping) _buildTypingIndicator(),
                // ── Área de input ──
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FONDO AURORA ANIMADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _aurora,
      builder: (context, child) {
        final hue = (_aurora.value * 360) % 360;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_aurora.value * math.pi * 2) * 0.3,
                math.cos(_aurora.value * math.pi * 2) * 0.3,
              ),
              radius: 1.8,
              colors: [
                HSLColor.fromAHSL(1.0, hue, 0.6, 0.12).toColor(),
                HSLColor.fromAHSL(1.0, (hue + 30) % 360, 0.5, 0.08).toColor(),
                _bgDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ORBES FLOTANTES
  // ═══════════════════════════════════════════════════════════

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        _buildOrb(
          top: -100,
          right: -100,
          size: 350,
          color: _auroraBase.withOpacity(0.06),
          blur: 100,
        ),
        _buildOrb(
          bottom: 100,
          left: -80,
          size: 300,
          color: const Color(0xFF818CF8).withOpacity(0.03),
          blur: 80,
        ),
        _buildOrb(
          top: 400,
          left: -60,
          size: 200,
          color: _auroraGlow.withOpacity(0.02),
          blur: 60,
        ),
      ],
    );
  }

  Widget _buildOrb({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    required double blur,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              math.sin(_floatController.value * math.pi) * 15,
              math.cos(_floatController.value * math.pi) * 20,
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color, color.withOpacity(0.0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color,
                    blurRadius: blur,
                    spreadRadius: size * 0.1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER CON AVATAR ANIMADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Avatar con halo ──
          Stack(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _auroraBase.withOpacity(
                          0.3 + _pulseController.value * 0.2,
                        ),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _auroraBase.withOpacity(
                            0.2 * _pulseController.value,
                          ),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: 4,
                left: 4,
                child: _buildGlassContainer(
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                  borderColor: Colors.white.withOpacity(0.1),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: _auroraBase,
                    size: 24,
                  ),
                ),
              ),
              // ── Punto online ──
              Positioned(
                bottom: 2,
                right: 2,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _bgDark,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(
                              0.5 + _pulseController.value * 0.3,
                            ),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // ── Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Guido AI",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Asistente Virtual Activo",
                      style: GoogleFonts.outfit(
                        color: Colors.greenAccent.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Botón info ──
          _buildGlassButton(
            onTap: () {},
            child: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white60,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CHAT BUBBLE PREMIUM (LÓGICA ORIGINAL PRESERVADA)
  // ═══════════════════════════════════════════════════════════

  Widget _buildChatBubble(Map<String, dynamic> msg, int index) {
    bool isAi = msg['role'] == 'ai';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            isAi ? -20 * (1 - value) : 20 * (1 - value),
            0,
          ),
          child: Opacity(
            opacity: value,
            child: Align(
              alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                child: Row(
                  mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ── Avatar para mensajes AI ──
                    if (isAi) ...[
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 10, bottom: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _auroraBase.withOpacity(0.2),
                              _auroraBase.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: _auroraBase,
                          size: 16,
                        ),
                      ),
                    ],
                    // ── Burbuja ──
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(22),
                          topRight: const Radius.circular(22),
                          bottomLeft: Radius.circular(isAi ? 4 : 22),
                          bottomRight: Radius.circular(isAi ? 22 : 4),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: isAi
                                  ? LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.06),
                                        Colors.white.withOpacity(0.02),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        _auroraBase.withOpacity(0.2),
                                        _auroraDeep.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(22),
                                topRight: const Radius.circular(22),
                                bottomLeft: Radius.circular(isAi ? 4 : 22),
                                bottomRight: Radius.circular(isAi ? 22 : 4),
                              ),
                              border: Border.all(
                                color: isAi
                                    ? Colors.white.withOpacity(0.08)
                                    : _auroraBase.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              msg['content'],
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // ── Avatar para mensajes usuario ──
                    if (!isAi) ...[
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(left: 10, bottom: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purpleAccent.withOpacity(0.2),
                              Colors.purpleAccent.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.purpleAccent,
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // INDICADOR DE ESCRITURA ANIMADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _auroraBase.withOpacity(0.2),
                  _auroraBase.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: _auroraBase,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          _buildGlassContainer(
            width: 80,
            height: 40,
            borderRadius: 20,
            borderColor: Colors.white.withOpacity(0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _typingDots,
                  builder: (context, child) {
                    final delay = index * 0.3;
                    final value = (_typingDots.value + delay) % 1.0;
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _auroraBase.withOpacity(
                          value < 0.5 ? 0.8 : 0.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ÁREA DE INPUT PREMIUM
  // ═══════════════════════════════════════════════════════════

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Botón adjuntar ──
          _buildGlassButton(
            onTap: () {},
            child: Icon(
              Icons.attach_file_rounded,
              color: Colors.white.withOpacity(0.40),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // ── Input field ──
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: "Escribe a Guido...",
                      hintStyle: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.25),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Botón enviar ──
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [_auroraBase, _auroraDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _auroraBase.withOpacity(
                        0.3 + _glowController.value * 0.2,
                      ),
                      blurRadius: 15 + _glowController.value * 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(18),
                    splashColor: Colors.white24,
                    highlightColor: Colors.white10,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UTILIDADES: Glassmorphism
  // ═══════════════════════════════════════════════════════════

  Widget _buildGlassContainer({
    required Widget child,
    double? width,
    double? height,
    required double borderRadius,
    Color borderColor = Colors.white10,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

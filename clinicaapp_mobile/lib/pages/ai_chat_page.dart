import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<Map<String, dynamic>> _messages = [
    {
      "role": "ai",
      "content": "¡Hola! Soy Nova AI, tu asistente veterinario de ClinicaApp. ¿En qué puedo ayudarte hoy?"
    }
  ];

  final List<String> _quickChips = [
    "Agendar Cita",
    "Ver mis mascotas",
    "Clínica más cercana",
    "Estado de mis pagos",
    "Horarios de atención"
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? preset]) async {
    final userMsg = (preset ?? _controller.text).trim();
    if (userMsg.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": userMsg});
      _isTyping = true;
    });
    if (preset == null) _controller.clear();
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

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _messages.add({
              "role": "ai",
              "content": data['respuesta'] ?? "No pude procesar esa consulta."
            });
            _isTyping = false;
          });
        } else {
          setState(() {
            _messages.add({"role": "ai", "content": "No se pudo obtener respuesta en este momento."});
            _isTyping = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "content": "Error de conexión con Nova Brain."});
          _isTyping = false;
        });
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header limpio estilo iMessage
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: const BoxDecoration(
                color: AppleTheme.surface,
                border: Border(bottom: BorderSide(color: AppleTheme.border, width: 0.8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppleTheme.purple.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppleTheme.purple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nova AI",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppleTheme.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppleTheme.green, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "En línea • Groq LLM",
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppleTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: "Nueva conversación",
                    icon: const Icon(Icons.refresh_rounded, color: AppleTheme.textSecondary),
                    onPressed: () {
                      setState(() {
                        _messages
                          ..clear()
                          ..add({
                            "role": "ai",
                            "content": "¡Hola! Soy Nova AI, tu asistente veterinario de ClinicaApp. ¿En qué puedo ayudarte hoy?"
                          });
                      });
                    },
                  ),
                ],
              ),
            ),

            // Mensajes
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppleTheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppleTheme.border),
                        ),
                        child: Text(
                          "Escribiendo...",
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppleTheme.textSecondary),
                        ),
                      ),
                    );
                  }
                  final msg = _messages[index];
                  final isUser = msg["role"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser ? AppleTheme.blue : AppleTheme.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 6),
                          bottomRight: Radius.circular(isUser ? 6 : 20),
                        ),
                        border: isUser ? null : Border.all(color: AppleTheme.border),
                        boxShadow: isUser ? null : AppleTheme.cardShadow,
                      ),
                      child: Text(
                        msg["content"] ?? "",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          height: 1.4,
                          color: isUser ? Colors.white : AppleTheme.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Chips rápidos
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(
                      _quickChips[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppleTheme.blue,
                      ),
                    ),
                    backgroundColor: AppleTheme.surface,
                    side: const BorderSide(color: AppleTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () => _sendMessage(_quickChips[index]),
                  );
                },
              ),
            ),

            // Barra de entrada estilo iMessage
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppleTheme.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppleTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(),
                        style: GoogleFonts.plusJakartaSans(color: AppleTheme.textPrimary, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Escribe tu consulta...",
                          hintStyle: GoogleFonts.plusJakartaSans(color: AppleTheme.textTertiary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: AppleTheme.surface,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                          builder: (ctx) => Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AppleIconBox(icon: Icons.mic_rounded, color: AppleTheme.purple, size: 60, iconSize: 30),
                                const SizedBox(height: 12),
                                Text("Comandos Rápidos de Voz", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 12),
                                ...["¿Qué clínica está abierta ahora?", "¿Cómo agendo una cita de urgencia?", "Muéstrame mis citas"].map(
                                  (cmd) => ListTile(
                                    leading: const Icon(Icons.graphic_eq_rounded, color: AppleTheme.purple),
                                    title: Text(cmd, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _sendMessage(cmd);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppleTheme.purple.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_rounded, color: AppleTheme.purple, size: 19),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _sendMessage(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppleTheme.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

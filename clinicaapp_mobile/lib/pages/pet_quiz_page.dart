import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class PetQuizPage extends StatefulWidget {
  const PetQuizPage({super.key});

  @override
  State<PetQuizPage> createState() => _PetQuizPageState();
}

class _PetQuizPageState extends State<PetQuizPage> {
  double _salud = 0.82;
  double _felicidad = 0.76;
  double _energia = 0.70;

  int _qIndex = 0;
  int _score = 0;
  bool _finished = false;

  final List<Map<String, dynamic>> _questions = [
    {
      "q": "¿Cada cuánto se recomienda desparasitar a un perro adulto?",
      "opts": ["Cada 3 a 4 meses", "Cada 5 años", "Solo una vez al nacer"],
      "ans": 0,
    },
    {
      "q": "¿Cuál de estos alimentos es tóxico para perros y gatos?",
      "opts": ["Zanahoria cocida", "Chocolate y uvas", "Pollo sin sal"],
      "ans": 1,
    },
    {
      "q": "¿Qué vacuna es obligatoria anualmente para prevenir contagio zoonótico?",
      "opts": ["Vitamina C", "Antirrábica", "Suplemento cálcico"],
      "ans": 1,
    },
    {
      "q": "¿Qué debes hacer ante una urgencia veterinaria nocturna?",
      "opts": ["Esperar 3 días", "Ubicar la clínica abierta más cercana en ClinicaApp", "Dar medicamentos humanos"],
      "ans": 1,
    },
  ];

  void _careAction(String tipo) {
    HapticFeedback.lightImpact();
    setState(() {
      if (tipo == 'food') {
        _energia = (_energia + 0.15).clamp(0.0, 1.0);
        _salud = (_salud + 0.05).clamp(0.0, 1.0);
      } else if (tipo == 'play') {
        _felicidad = (_felicidad + 0.15).clamp(0.0, 1.0);
        _energia = (_energia - 0.08).clamp(0.2, 1.0);
      } else {
        _salud = 1.0;
      }
    });
  }

  void _answer(int idx) {
    HapticFeedback.selectionClick();
    if (idx == _questions[_qIndex]["ans"]) _score++;
    setState(() {
      if (_qIndex + 1 < _questions.length) {
        _qIndex++;
      } else {
        _finished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Mascota Virtual & Quiz"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          // Mascota Virtual
          AppleCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Column(
              children: [
                const AppleIconBox(icon: Icons.pets_rounded, color: AppleTheme.blue, size: 68, iconSize: 34),
                const SizedBox(height: 12),
                Text("Doki Virtual", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
                Text("Cuida su bienestar diario", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppleTheme.textSecondary)),
                const SizedBox(height: 16),
                _MeterRow(label: "Salud", value: _salud, color: AppleTheme.green),
                const SizedBox(height: 8),
                _MeterRow(label: "Felicidad", value: _felicidad, color: AppleTheme.orange),
                const SizedBox(height: 8),
                _MeterRow(label: "Energía", value: _energia, color: AppleTheme.blue),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionPill(label: "Alimentar", icon: Icons.restaurant_rounded, color: AppleTheme.orange, onTap: () => _careAction('food')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionPill(label: "Jugar", icon: Icons.sports_baseball_rounded, color: AppleTheme.blue, onTap: () => _careAction('play')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionPill(label: "Chequeo", icon: Icons.medical_services_rounded, color: AppleTheme.green, onTap: () => _careAction('vet')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const AppleSectionHeader(title: "Quiz de Cuidado Animal"),
          const SizedBox(height: 12),

          AppleCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: _finished
                ? Column(
                    children: [
                      const AppleIconBox(icon: Icons.emoji_events_rounded, color: AppleTheme.orange, size: 60, iconSize: 30),
                      const SizedBox(height: 12),
                      Text(
                        "Puntaje: $_score / ${_questions.length}",
                        style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _score >= 3 ? "¡Excelente tutor responsable!" : "Sigue aprendiendo sobre bienestar animal.",
                        style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      AppleButton(
                        text: "Reiniciar Quiz",
                        onPressed: () => setState(() {
                          _qIndex = 0;
                          _score = 0;
                          _finished = false;
                        }),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppleBadge(text: "Pregunta ${_qIndex + 1} de ${_questions.length}", color: AppleTheme.purple),
                      const SizedBox(height: 12),
                      Text(
                        _questions[_qIndex]["q"] as String,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16.5, fontWeight: FontWeight.w700, color: AppleTheme.textPrimary),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate((_questions[_qIndex]["opts"] as List).length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppleButton(
                            text: (_questions[_qIndex]["opts"] as List)[i] as String,
                            outlined: true,
                            height: 48,
                            onPressed: () => _answer(i),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MeterRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MeterRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppleTheme.bg,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text("${(value * 100).toInt()}%", style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionPill({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

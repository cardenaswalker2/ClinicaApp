class HistorialVisita {
  final String id;
  final String fechaVisita;
  final String diagnostico;
  final String tratamiento;
  final List<String> medicamentosRecetados;
  final double costoTotal;
  final String notasAdicionales;
  final double? peso;
  final double? temperatura;
  final int? frecuenciaCardiaca;
  final int? frecuenciaRespiratoria;
  final String? estadoConciencia;
  final String? condicionCorporal;
  final String clinicaNombre;

  HistorialVisita({
    required this.id,
    required this.fechaVisita,
    required this.diagnostico,
    required this.tratamiento,
    required this.medicamentosRecetados,
    required this.costoTotal,
    required this.notasAdicionales,
    this.peso,
    this.temperatura,
    this.frecuenciaCardiaca,
    this.frecuenciaRespiratoria,
    this.estadoConciencia,
    this.condicionCorporal,
    required this.clinicaNombre,
  });

  factory HistorialVisita.fromJson(Map<String, dynamic> json) {
    return HistorialVisita(
      id: json['id'] ?? '',
      fechaVisita: json['fechaVisita'] ?? '',
      diagnostico: json['diagnostico'] ?? 'Sin diagnóstico registrado',
      tratamiento: json['tratamiento'] ?? 'Sin tratamiento especificado',
      medicamentosRecetados: (json['medicamentosRecetados'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      costoTotal: (json['costoTotal'] ?? 0.0).toDouble(),
      notasAdicionales: json['notasAdicionales'] ?? '',
      peso: json['peso'] != null ? (json['peso']).toDouble() : null,
      temperatura: json['temperatura'] != null ? (json['temperatura']).toDouble() : null,
      frecuenciaCardiaca: json['frecuenciaCardiaca'] is int ? json['frecuenciaCardiaca'] : null,
      frecuenciaRespiratoria: json['frecuenciaRespiratoria'] is int ? json['frecuenciaRespiratoria'] : null,
      estadoConciencia: json['estadoConciencia'],
      condicionCorporal: json['condicionCorporal'],
      clinicaNombre: json['clinicaNombre'] ?? 'Clínica Veterinaria',
    );
  }
}

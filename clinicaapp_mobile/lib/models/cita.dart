class Cita {
  final String id;
  final String usuarioId;
  final String clinicaId;
  final String mascotaId;
  final String fechaHora;
  final String motivo;
  final String estado;
  final String estadoPago;
  final double costo;
  final String? clinicaNombre;
  final String? mascotaNombre;

  Cita({
    required this.id,
    required this.usuarioId,
    required this.clinicaId,
    required this.mascotaId,
    required this.fechaHora,
    required this.motivo,
    required this.estado,
    this.estadoPago = 'PENDIENTE',
    required this.costo,
    this.clinicaNombre,
    this.mascotaNombre,
  });

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
        id: json['id'] ?? '',
        usuarioId: json['usuarioId'] ?? '',
        clinicaId: json['clinicaId'] ?? '',
        mascotaId: json['mascotaId'] ?? '',
        fechaHora: json['fechaHora'] ?? '',
        motivo: json['motivo'] ?? '',
        estado: json['estado'] ?? 'PENDIENTE',
        estadoPago: json['estadoPago'] ?? 'PENDIENTE',
        costo: (json['costo'] ?? 0.0).toDouble(),
        clinicaNombre: json['clinicaNombre'],
        mascotaNombre: json['mascotaNombre'],
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'usuarioId': usuarioId,
        'clinicaId': clinicaId,
        'mascotaId': mascotaId,
        'fechaHora': fechaHora,
        'motivo': motivo,
        'estado': estado,
        'estadoPago': estadoPago,
        'costo': costo,
      };
}

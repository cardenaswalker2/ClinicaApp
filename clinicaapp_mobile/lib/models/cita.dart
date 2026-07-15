class Cita {
  final String id, usuarioId, clinicaId, mascotaId, fechaHora, motivo, estado;
  final double costo;

  Cita({
    required this.id, required this.usuarioId, required this.clinicaId, 
    required this.mascotaId, required this.fechaHora, required this.motivo, 
    required this.estado, required this.costo
  });

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
    id: json['id'] ?? '',
    usuarioId: json['usuarioId'] ?? '',
    clinicaId: json['clinicaId'] ?? '',
    mascotaId: json['mascotaId'] ?? '',
    fechaHora: json['fechaHora'] ?? '',
    motivo: json['motivo'] ?? '',
    estado: json['estado'] ?? 'PENDIENTE',
    costo: (json['costo'] ?? 0.0).toDouble(),
  );
}

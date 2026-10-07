class PagoUsuario {
  final String citaId;
  final String fecha;
  final double monto;
  final String estado;
  final String? paymentIntentId;
  final String? nombreClinica;
  final String? nombreServicio;
  final String? nombreMascota;

  PagoUsuario({
    required this.citaId,
    required this.fecha,
    required this.monto,
    required this.estado,
    this.paymentIntentId,
    this.nombreClinica,
    this.nombreServicio,
    this.nombreMascota,
  });

  factory PagoUsuario.fromJson(Map<String, dynamic> json) {
    return PagoUsuario(
      citaId: json['citaId'] ?? '',
      fecha: json['fecha'] ?? '',
      monto: (json['monto'] ?? 0.0).toDouble(),
      estado: json['estado'] ?? 'PENDIENTE',
      paymentIntentId: json['paymentIntentId'],
      nombreClinica: json['nombreClinica'],
      nombreServicio: json['nombreServicio'],
      nombreMascota: json['nombreMascota'],
    );
  }
}

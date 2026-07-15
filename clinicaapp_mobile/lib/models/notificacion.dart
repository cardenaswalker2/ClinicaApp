class Notificacion {
  final String id;
  final String usuarioId;
  final String titulo;
  final String mensaje;
  final String? link;
  final bool leida;
  final DateTime fecha;

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.mensaje,
    this.link,
    required this.leida,
    required this.fecha,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      link: json['link'],
      leida: json['leida'] ?? false,
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    );
  }
}

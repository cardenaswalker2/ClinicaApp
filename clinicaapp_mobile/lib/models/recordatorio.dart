class Recordatorio {
  final String? id;
  final String titulo, descripcion, fechaHora, tipo, estado, usuarioId;

  Recordatorio({
    this.id, required this.titulo, required this.descripcion, 
    required this.fechaHora, required this.tipo, required this.estado, 
    required this.usuarioId
  });

  factory Recordatorio.fromJson(Map<String, dynamic> json) => Recordatorio(
    id: json['id'], 
    titulo: json['titulo'] ?? '', 
    descripcion: json['descripcion'] ?? '', 
    fechaHora: json['fechaHora'] ?? '', 
    tipo: json['tipo'] ?? 'GMAIL', 
    estado: json['estado'] ?? 'PENDIENTE', 
    usuarioId: json['usuarioId'] ?? ''
  );

  Map<String, dynamic> toJson() => {
    'titulo': titulo, 
    'descripcion': descripcion, 
    'fechaHora': fechaHora, 
    'tipo': tipo, 
    'estado': estado, 
    'usuarioId': usuarioId
  };
}

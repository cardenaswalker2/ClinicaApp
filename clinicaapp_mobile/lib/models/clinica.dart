import '../config/app_config.dart';

class Clinica {
  final String id, nombre, direccion, telefono, email, descripcion, imagenUrl;

  Clinica({
    required this.id, required this.nombre, required this.direccion, 
    required this.telefono, required this.email, required this.descripcion, 
    required this.imagenUrl
  });

  factory Clinica.fromJson(Map<String, dynamic> json) {
    String fUrl(String? u) => (u == null || u.isEmpty) ? '' : (u.startsWith('http') ? u : "${AppConfig.baseUrl.replaceAll('/api', '')}${u.startsWith('/') ? u : '/$u'}");
    return Clinica(
      id: json['id'] ?? '', 
      nombre: json['nombre'] ?? '', 
      direccion: json['direccion'] ?? '', 
      telefono: json['telefono'] ?? '', 
      email: json['email'] ?? '', 
      descripcion: json['descripcion'] ?? '', 
      imagenUrl: fUrl(json['imagenUrl'])
    );
  }
}

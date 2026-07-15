import '../config/app_config.dart';

class Mascota {
  final String id, nombre, especie, raza, sexo, fotoUrl;
  final int edad;
  final List<String> albumFotos;

  Mascota({
    required this.id, required this.nombre, required this.especie, 
    required this.raza, required this.sexo, required this.fotoUrl, 
    required this.edad, required this.albumFotos
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    String fUrl(String? u) => (u == null || u.isEmpty) ? '' : (u.startsWith('http') ? u : "${AppConfig.baseUrl.replaceAll('/api', '')}${u.startsWith('/') ? u : '/$u'}");
    return Mascota(
      id: json['id'] ?? '', 
      nombre: json['nombre'] ?? '', 
      especie: json['especie'] ?? '', 
      raza: json['raza'] ?? '', 
      sexo: json['sexo'] ?? '', 
      fotoUrl: fUrl(json['fotoUrl']), 
      edad: json['edad'] ?? 0, 
      albumFotos: (json['albumFotos'] as List? ?? []).map((e) => fUrl(e.toString())).toList()
    );
  }
}

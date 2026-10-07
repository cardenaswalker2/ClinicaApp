import '../config/app_config.dart';

class Mascota {
  final String id;
  final String nombre;
  final String especie;
  final String raza;
  final String sexo;
  final String fotoUrl;
  final int edad;
  final String fechaNacimiento;
  final String propietarioId;
  final List<String> albumFotos;

  Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.sexo,
    required this.fotoUrl,
    required this.edad,
    this.fechaNacimiento = '',
    this.propietarioId = '',
    required this.albumFotos,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    String fUrl(String? u) => (u == null || u.isEmpty)
        ? ''
        : (u.startsWith('http')
            ? u
            : "${AppConfig.baseUrl.replaceAll('/api', '')}${u.startsWith('/') ? u : '/$u'}");

    String formatRaza() {
      if (json['raza'] != null && json['raza'].toString().isNotEmpty) {
        return json['raza'].toString();
      }
      if (json['razaPersonalizada'] != null && json['razaPersonalizada'].toString().isNotEmpty) {
        return json['razaPersonalizada'].toString();
      }
      if (json['razaPerro'] != null) return json['razaPerro'].toString();
      if (json['razaGato'] != null) return json['razaGato'].toString();
      return 'Mestizo';
    }

    return Mascota(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      especie: json['especie'] != null ? json['especie'].toString() : 'PERRO',
      raza: formatRaza(),
      sexo: json['sexo'] ?? 'No especificado',
      fotoUrl: fUrl(json['fotoUrl']),
      edad: json['edad'] is int ? json['edad'] : 0,
      fechaNacimiento: json['fechaNacimiento'] ?? '',
      propietarioId: json['propietarioId'] ?? '',
      albumFotos: (json['albumFotos'] as List? ?? []).map((e) => fUrl(e.toString())).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nombre': nombre,
      'especie': especie.toUpperCase(),
      'razaPersonalizada': raza,
      'sexo': sexo,
      'fotoUrl': fotoUrl,
      'propietarioId': propietarioId.isNotEmpty ? propietarioId : AppConfig.userId,
      'fechaNacimiento': fechaNacimiento.isNotEmpty ? fechaNacimiento : null,
      'albumFotos': albumFotos,
    };
  }
}

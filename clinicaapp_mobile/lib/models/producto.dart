class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String imagenUrl;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imagenUrl,
    required this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      imagenUrl: json['imagenUrl'] ?? '',
      categoria: json['categoria'] ?? '',
    );
  }
}

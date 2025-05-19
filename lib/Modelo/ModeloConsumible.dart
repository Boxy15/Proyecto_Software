class Consumible {
  final String nombre;
  final String proveedor;
  final int stock;
  final double precioUnitario;

  Consumible({
    required this.nombre,
    required this.proveedor,
    required this.stock,
    required this.precioUnitario,
  });

  factory Consumible.fromJson(Map<String, dynamic> json) {
    return Consumible(
      nombre: json['nombre'],
      proveedor: json['proveedor'],
      stock: json['stock'],
      precioUnitario: json['precio_unitario'].toDouble(),
    );
  }
}

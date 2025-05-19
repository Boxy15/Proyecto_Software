class TipoBoleto {
  final int id;
  final String nombre;
  final double precio;

  TipoBoleto({
    required this.id,
    required this.nombre,
    required this.precio,
  });

  factory TipoBoleto.fromJson(Map<String, dynamic> json) {
    return TipoBoleto(
      id: json['id_boleto'],
      nombre: json['nombre'],
      precio: (json['precio'] as num).toDouble(),
    );
  }
}

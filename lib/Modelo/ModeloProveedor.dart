class Proveedor {
  final int? id;
  final String nombre;
  final String correo;
  final String telefono;
  final String direccion;
  final String rfc;

  Proveedor({
    this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.rfc,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      rfc: json['rfc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'rfc': rfc,
    };
  }
}

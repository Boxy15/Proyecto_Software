class User {
  final int id;
  final String nombre;
  final String apellidos;
  final String telefono;
  final String usuario;
  final String cumpleanos;
  final String rfc;
  final String departamento;

  User({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.usuario,
    required this.cumpleanos,
    required this.rfc,
    required this.departamento,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'usuario': usuario,
      'cumpleanos': cumpleanos,
      'rfc': rfc,
      'departamento': departamento,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      telefono: json['telefono'] ?? '',
      usuario: json['usuario'] ?? '',
      cumpleanos: json['cumpleanos'] ?? '',
      rfc: json['rfc'] ?? '',
      departamento: json['departamento'] ?? '',
    );
  }
}

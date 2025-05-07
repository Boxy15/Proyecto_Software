import 'dart:convert';

class Funcion {
  final String titulo;
  final String genero;
  final String clasificacion;
  final String duracion;
  final String poster;
  final Map<String, List<Map<String, String>>> funciones;

  Funcion({
    required this.titulo,
    required this.genero,
    required this.clasificacion,
    required this.duracion,
    required this.poster,
    required this.funciones,
  });

  factory Funcion.fromJson(Map<String, dynamic> json) {
  // Asegurarte de que poster sea un String
  final dynamic rawPoster = json['poster'];
  String posterString;

  if (rawPoster is String) {
    posterString = rawPoster;
  } else if (rawPoster is Map<String, dynamic> && rawPoster.containsKey('data')) {
    // Manejar el caso de Buffer (por si algo en el backend falló)
    final List<int> bytes = List<int>.from(rawPoster['data']);
    posterString = 'data:image/jpeg;base64,${base64Encode(bytes)}';
  } else {
    posterString = ''; // imagen vacía o placeholder
  }

  return Funcion(
    titulo: json['titulo'],
    genero: json['genero'],
    clasificacion: json['clasificacion'],
    duracion: json['duracion'],
    poster: posterString,
    funciones: Map<String, List<Map<String, String>>>.from(
      json['funciones'].map(
        (key, value) => MapEntry(
          key,
          List<Map<String, String>>.from(
            value.map<Map<String, String>>(
                (item) => Map<String, String>.from(item)),
          ),
        ),
      ),
    ),
  );
}

}

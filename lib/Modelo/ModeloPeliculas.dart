class PeliculaModel {
  final String titulo;
  final String duracion;
  final String idioma;
  final String genero;
  final String clasificacion;

  PeliculaModel({
    required this.titulo,
    required this.duracion,
    required this.idioma,
    required this.genero,
    required this.clasificacion,
  });

  factory PeliculaModel.fromJson(Map<String, dynamic> json) {
    return PeliculaModel(
      titulo: json['Titulo'],
      duracion: json['Duracion'].toString().substring(11, 19),
      idioma: json['Idioma'],
      genero: json['Genero'],
      clasificacion: json['Clasificacion'],
    );
  }
}

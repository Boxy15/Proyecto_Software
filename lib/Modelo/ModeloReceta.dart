class Ingrediente {
  final int idConsumible;
  final String unidad;
  final int stock;
  final double cantidad;
  final String unidadUsada;

  Ingrediente({
    required this.idConsumible,
    required this.unidad,
    required this.stock,
    required this.cantidad,
    required this.unidadUsada,
  });

  factory Ingrediente.fromJson(Map<String, dynamic> json) {
    return Ingrediente(
      idConsumible: json['idConsumible'],
      unidad: json['unidad'],
      stock: json['stock'],
      cantidad: (json['cantidad'] as num).toDouble(),
      unidadUsada: json['unidadUsada'],
    );
  }
}


class Receta {
  final int id;
  final String nombre;
  final String imagen;
  final double precio;
  final String descripcion;
  final List<Ingrediente> ingredientes;

  Receta({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.precio,
    required this.descripcion,
    required this.ingredientes,
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    var lista = json['ingredientes'] as List;
    List<Ingrediente> ingredientes = lista.map((e) => Ingrediente.fromJson(e)).toList();
    return Receta(
      id: json['id'],
      nombre: json['nombre'],
      imagen: json['imagen'] ?? '',
      precio: (json['precio'] as num).toDouble(),
      descripcion: json['descripcion'] ?? '',
      ingredientes: ingredientes,
    );
  }
}

class Producto {
  final int idProducto;
  final String nombre;
  final String? tamano;
  final double? porcionCantidad;
  final String? porcionUnidad;
  final int stock;
  final double precio;
  final String? imagen;
  final String? departamento;

  Producto({
    required this.idProducto,
    required this.nombre,
    this.tamano,
    this.porcionCantidad,
    this.porcionUnidad,
    required this.stock,
    required this.precio,
    this.imagen,
    this.departamento,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['idProducto'] ?? 0,
      nombre: json['nombre'] ?? '',
      tamano: json['tamano'],
      porcionCantidad: (json['porcionCantidad'] != null)
          ? (json['porcionCantidad'] as num).toDouble()
          : null,
      porcionUnidad: json['porcionUnidad'],
      stock: json['stock'] ?? 0,
      precio: (json['precio'] ?? 0).toDouble(),
      imagen: json['imagen'],
      departamento: json['departamento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'tamano': tamano,
      'porcionCantidad': porcionCantidad,
      'porcionUnidad': porcionUnidad,
      'stock': stock,
      'precio': precio,
      'imagen': imagen,
      'departamento': departamento,
    };
  }
}
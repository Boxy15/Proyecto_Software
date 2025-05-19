import 'package:proyecto_cine_equipo3/Modelo/ModeloReceta.dart';

class CarritoCafeteriaGlobal {
  static final CarritoCafeteriaGlobal _instance = CarritoCafeteriaGlobal._internal();
  factory CarritoCafeteriaGlobal() => _instance;
  CarritoCafeteriaGlobal._internal();

  final List<Producto> productosSeleccionados = [];
  final List<Receta> combosSeleccionados = [];

  void agregarProducto(Producto producto) {
    productosSeleccionados.add(producto);
  }

  void agregarCombo(Receta combo) {
    combosSeleccionados.add(combo);
  }
 
  void limpiar() {
    productosSeleccionados.clear();
    combosSeleccionados.clear();
  }

  double get total {
    double totalProductos = productosSeleccionados.fold(0.0, (sum, item) => sum + item.precio);
    double totalCombos = combosSeleccionados.fold(0.0, (sum, item) => sum + item.precio);
    return totalProductos + totalCombos;
  }
}
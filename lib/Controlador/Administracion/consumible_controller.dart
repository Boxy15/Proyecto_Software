import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_cine_equipo3/Modelo/ModeloConsumible.dart';

class ConsumibleController {
  final String baseUrl = 'http://localhost:3000';

  Future<List<Consumible>> fetchConsumibles(String proveedor) async {
    try {
      final url = Uri.parse('$baseUrl/api/admingetAllConsumibles');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Consumible> consumibles = data.map((c) => Consumible.fromJson(c)).toList();

        if (proveedor == 'Todos') return consumibles;

        return consumibles.where((c) => c.proveedor == proveedor).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error: $e");
      return [];
    }
  }

  List<Consumible> filtrar(List<Consumible> lista, String query) {
    if (query.isEmpty) return lista;
    return lista.where((c) => c.nombre.toLowerCase().contains(query.toLowerCase())).toList();
  }
}

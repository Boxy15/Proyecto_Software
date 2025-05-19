import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloProveedor.dart';

const String baseUrl = 'http://localhost:3000/api/admin';

class ProveedorController {
  final BuildContext context;
  ProveedorController(this.context);

  Future<bool> guardarProveedor(Proveedor proveedor) async {
    print("🛠 FUNCIÓN _guardarProveedor INVOCADA");
    final url = proveedor.id == null
        ? Uri.parse('$baseUrl/addProveedor')
        : Uri.parse('$baseUrl/updateProveedor/${proveedor.id}');

    final response = proveedor.id == null
        ? await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(proveedor.toJson()),
          )
        : await http.put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(proveedor.toJson()),
          );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Proveedor guardado correctamente');
      return true;
    } else {
      print('❌ Error al guardar proveedor: ${response.body}');
      return false;
    }
  }

  Future<List> fetchProveedores() async {
    final url = Uri.parse('http://localhost:3000/api/admin/getAllProveedores');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

      // print("🧾 JSON recibido: ${json.encode(data)}");

        return data.map((p) {
          try {
            return Proveedor.fromJson(p);
          } catch (e) {
            print("⚠️ Error al parsear proveedor: $e");
            return Proveedor(
              nombre: 'Desconocido',
              telefono: 'N/A',
              correo: 'N/A',
              direccion: 'N/A',
              rfc: 'N/A',
            );
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error al obtener proveedores: $e");
      return [];
    }
  }

  Future<bool> eliminarProveedor(String nombre) async {
    final url =
        Uri.parse('http://localhost:3000/api/admin/deleteProveedor/$nombre');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('❌ Error de conexión: $error');
      return false;
    }
  }

  List<Proveedor> filtrar(List<Proveedor> lista, String query) {
    return lista
        .where((p) => p.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<bool> actualizarProveedor(Proveedor proveedor) async {
    final url = Uri.parse(
        'http://localhost:3000/api/admin/updateProveedor/${proveedor.id}');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(proveedor.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error al actualizar proveedor: $e');
      return false;
    }
  }
}

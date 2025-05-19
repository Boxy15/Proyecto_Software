import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MiembrosController {
  final String baseUrl = 'http://localhost:3000'; // Ajusta si es necesario

  // 🚀 Función para obtener todos los miembros
  Future<List<dynamic>> obtenerMiembros() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/taquilla/miembros'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar miembros');
    }
  }

  // 🚀 Función para filtrar miembros por nombre
  List<dynamic> filtrarMiembros(List<dynamic> miembros, String query) {
    return miembros
        .where((miembro) =>
            miembro['nombre'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // 🚀 Función para guardar miembro (ya la tienes)
  Future<String> guardarMiembro({
    required BuildContext context,
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String ine,
    required String tipoMembresia,
  }) async {
    if (nombre.trim().isEmpty ||
        apellido.trim().isEmpty ||
        telefono.trim().isEmpty ||
        direccion.trim().isEmpty ||
        ine.trim().isEmpty ||
        tipoMembresia.isEmpty) {
      mostrarError(context, 'Por favor llena todos los campos');
      return 'ERROR';
    }

    if (!RegExp(r'^\d+$').hasMatch(telefono)) {
      mostrarError(context, 'El teléfono debe contener solo números');
      return 'ERROR';
    }

    if (!RegExp(r'^\d{8,}$').hasMatch(ine)) {
      mostrarError(
          context, 'El INE debe ser numérico y tener mínimo 8 dígitos');
      return 'ERROR';
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/taquilla/addMiembro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre.trim(),
          'apellido': apellido.trim(),
          'telefono': telefono.trim(),
          'direccion': direccion.trim(),
          'ine': ine.trim(),
          'tipo_membresia': tipoMembresia,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Miembro agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        return 'OK';
      } else {
        throw Exception('Error al guardar miembro');
      }
    } catch (e) {
      mostrarError(context, 'Error: $e');
      return 'ERROR';
    }
  }

  void mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> eliminarMiembro(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/taquilla/miembros/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar miembro');
    }
  }

  Future<String> actualizarMiembro({
    required BuildContext context,
    required int id,
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String ine,
    required String tipoMembresia,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/taquilla/miembros/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre.trim(),
          'apellido': apellido.trim(),
          'telefono': telefono.trim(),
          'direccion': direccion.trim(),
          'ine': ine.trim(),
          'tipo_membresia': tipoMembresia,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Miembro actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        return 'OK';
      } else {
        throw Exception('Error al actualizar miembro');
      }
    } catch (e) {
      mostrarError(context, 'Error: $e');
      return 'ERROR';
    }
  }
}

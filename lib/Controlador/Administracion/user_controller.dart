import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloUsuarios.dart';

class UserController {
  final String baseUrl = 'http://localhost:3000';

  // ✅ Formatear Fecha
  String formatearFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return 'No disponible';
    try {
      DateTime parsedDate = DateTime.parse(fecha);
      return '${parsedDate.year.toString().padLeft(4, '0')}-'
          '${parsedDate.month.toString().padLeft(2, '0')}-'
          '${parsedDate.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Formato inválido';
    }
  }

  // ✅ Obtener Usuarios desde la API
  Future<List<User>> fetchUsuarios(String dropdownValue) async {
    final url = Uri.parse(
        '$baseUrl/api/admin/getUsers?orderBy=Departamento&departamento=$dropdownValue');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((usuario) => User.fromJson(usuario)).toList();
      } else {
        print("Error al cargar los usuarios: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Excepción atrapada: $e");
      return [];
    }
  }

  // ✅ Eliminar Usuario
  Future<bool> eliminarUsuario(int userId) async {
    final url = Uri.parse('$baseUrl/api/admin/deleteUser/$userId');
    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print("Excepción atrapada al eliminar: $e");
      return false;
    }
  }

  // ✅ Filtrar Usuarios
  List<User> filtrarUsuarios(List<User> usuarios, String query) {
    if (query.isEmpty) {
      return usuarios;
    } else {
      return usuarios.where((usuario) {
        final nombre = '${usuario.nombre} ${usuario.apellidos}'.toLowerCase();

        return nombre.contains(query.toLowerCase());
      }).toList();
    }
  }

  // ✅ Mostrar Mensaje
  void mostrarMensaje(BuildContext context, String mensaje,
      {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

// ✅ Guardar Usuario
  Future<void> saveUser(BuildContext context, User user, String contrasena,
      String confirmarContrasena) async {
    try {
      // Verificar que todos los campos estén llenos
      if ([
        user.nombre,
        user.apellidos,
        user.telefono,
        user.usuario,
        user.cumpleanos,
        user.rfc,
        user.departamento,
        contrasena,
        confirmarContrasena
      ].any((element) => element.isEmpty)) {
        mostrarMensaje(context, "Todos los campos son obligatorios.");
        return;
      }

      // Validar el teléfono (solo números y longitud de 10)
      final RegExp telefonoRegex = RegExp(r'^\d{10}$');
      if (!telefonoRegex.hasMatch(user.telefono)) {
        mostrarMensaje(
            context, "El teléfono debe contener 10 dígitos numéricos.");
        return;
      }

      // Validar el RFC (formato estándar)
      final RegExp rfcRegex = RegExp(r'^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$');
      if (!rfcRegex.hasMatch(user.rfc)) {
        mostrarMensaje(context, "El RFC no tiene un formato válido.");
        return;
      }

      // Validar la longitud de la contraseña
      if (contrasena.length < 6) {
        mostrarMensaje(
            context, "La contraseña debe tener al menos 6 caracteres.");
        return;
      }

      // Validar que las contraseñas coincidan
      if (contrasena != confirmarContrasena) {
        mostrarMensaje(
            context, "Las contraseñas no coinciden. Inténtalo de nuevo.");
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/addUser'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'nombre': user.nombre,
          'apellidos': user.apellidos,
          'telefono': user.telefono,
          'rfc': user.rfc,
          'usuario': user.usuario,
          'contrasena': contrasena,
          'cumpleanos': user.cumpleanos,
          'departamento': user.departamento,
        }),
      );

      if (response.statusCode == 201) {
        mostrarMensaje(context, "Usuario guardado con éxito",
            color: Colors.green);
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      } else {
        mostrarMensaje(context, "Error al guardar usuario: ${response.body}");
      }
    } catch (error) {
      mostrarMensaje(context, "Error de conexión: $error");
    }
  }

  Future<void> seleccionarFecha(
      BuildContext context, TextEditingController fechaController) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> actualizarUsuario(BuildContext context, User user) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/updateUser/${user.id}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'nombre': user.nombre,
        'apellidos': user.apellidos,
        'telefono': user.telefono,
        'rfc': user.rfc,
        'usuario': user.usuario,
        'cumpleanos': user.cumpleanos,
        'departamento': user.departamento,
      }),
    );

    if (response.statusCode == 200) {
      mostrarMensaje(context, "Usuario actualizado con éxito",
          color: Colors.green);
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } else {
      mostrarMensaje(
          context, "Error al actualizar usuario: ${response.body}");
    }
  } catch (e) {
    mostrarMensaje(context, "Error de conexión: $e");
  }
}
}





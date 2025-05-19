import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_cine_equipo3/Modelo/ModeloFunciones.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloTipoBoleto.dart';

class FuncionesController {
  final String baseUrl = 'http://localhost:3000';

  Future<List<Funcion>> obtenerFuncionesPorFecha(String fecha) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/taquilla/funciones?fecha=$fecha'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Funcion.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener funciones');
    }
  }
}

class BoletosController {
  final String baseUrl = 'http://localhost:3000';

  Future<List<TipoBoleto>> obtenerBoletos(String fecha, String tipoSala) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/taquilla/tiposboletos?fecha=$fecha&tipoSala=$tipoSala'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => TipoBoleto.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener tipos de boletos');
    }
  }

  double calcularTotal(List<int> cantidades, List<TipoBoleto> boletos) {
    double total = 0.0;
    for (int i = 0; i < cantidades.length; i++) {
      total += cantidades[i] * boletos[i].precio;
    }
    return total;
  }
}

class PagoController {
  final String baseUrl = 'http://localhost:3000';

  // Buscar miembro por teléfono
  Future<Map<String, dynamic>?> buscarMiembroPorTelefono(
      String telefono) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/taquilla/miembroTelefono/$telefono'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al buscar miembro');
    }
  }

  double calcularCambio({
    required double montoRecibido,
    required double total,
  }) {
    if (montoRecibido < total) {
      throw Exception('El monto recibido no puede ser menor al total.');
    }
    return montoRecibido - total;
  }

  // Calcular cashback de acuerdo al tipo de membresía
  double calcularCashback(double total, String tipoMembresia) {
    double porcentaje = 0.0;
    if (tipoMembresia == '3%') porcentaje = 0.03;
    if (tipoMembresia == '5%') porcentaje = 0.05;
    if (tipoMembresia == '7%') porcentaje = 0.07;
    return total * porcentaje;
  }

  Future<String> registrarPago({
    required int? idMiembro,
    required String nombreCliente,
    required double montoTotal,
    required double montoRecibido,
    required double cambio,
    required String tipoPago,
    required double cashbackGenerado,
  }) async {
    final url = Uri.parse('$baseUrl/api/taquilla/pago');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_miembro': idMiembro,
        'nombre_cliente': nombreCliente,
        'monto_total': montoTotal,
        'monto_recibido': montoRecibido,
        'cambio': cambio,
        'tipo_pago': tipoPago,
        'cashback_generado': cashbackGenerado,
      }),
    );

    if (response.statusCode == 201) {
      return 'OK';
    } else {
      throw Exception('Error al registrar el pago');
    }
  }
}

class AsientosController {
  final String baseUrl = 'http://localhost:3000';

  Future<List<String>> cargarAsientosOcupados({
    required String fecha,
    required String horario,
    required String sala,
  }) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/api/taquilla/asientosOcupados?fecha=$fecha&horario=$horario&sala=$sala',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> asientosVendidos =
          (data['asientos_ocupados'] as String).split(',');
      return asientosVendidos.map((e) => e.trim()).toList();
    } else {
      throw Exception('Error al cargar asientos ocupados');
    }
  }

  Future<void> actualizarAsientosVendidos({
    required String fecha,
    required String horario,
    required String sala,
    required String nuevosAsientos,
  }) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/api/taquilla/actualizarAsientosVendidos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fecha': fecha,
        'horario': horario,
        'sala': sala,
        'nuevos_asientos': nuevosAsientos,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar asientos vendidos');
    }
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const String baseUrl = 'http://localhost:3000';

class VistaReportePagos extends StatefulWidget {
  const VistaReportePagos({super.key});

  @override
  State<VistaReportePagos> createState() => _VistaReportePagosState();
}

class _VistaReportePagosState extends State<VistaReportePagos> {
  List<Map<String, dynamic>> pagos = [];
  List<String> fechasDisponibles = [];
  String fechaSeleccionada = "";

  @override
  void initState() {
    super.initState();
    cargarFechasDisponibles();
  }

  Future<void> cargarFechasDisponibles() async {
  final url = Uri.parse('$baseUrl/api/admin/fechas-corte');

  try {
    final response = await http.get(url);
    print("🌐 Estado HTTP: ${response.statusCode}");
    print("📦 Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = List<String>.from(jsonDecode(response.body));
      print("📅 Fechas recibidas: $data");

      data.sort((a, b) => a.compareTo(b)); // ahora 05 irá antes que 21
      setState(() {
        fechasDisponibles = data;
        if (fechasDisponibles.isNotEmpty) {
          fechaSeleccionada = fechasDisponibles.first;
          cargarPagosPorFecha(fechaSeleccionada);
        }
      });
    }
  } catch (e) {
    print("❌ Error al cargar fechas disponibles: $e");
    setState(() => fechasDisponibles = []);
  }
}


  Future<void> cargarPagosPorFecha(String fechaCorte) async {
    
    final url = Uri.parse('$baseUrl/api/admin/reporte-pagos?fecha_corte=$fechaCorte');

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pagos = List<Map<String, dynamic>>.from(data);
        });

        // ✅ Debug para verificar si llegan los campos esperados
        print("📋 Pagos cargados:");
        for (var p in pagos) {
          print("🔹 Pago: ${p["id_pago"]} | Película: ${p["pelicula"]} | Función: ${p["funcion_horario"]}");
        }

      } else {
        setState(() => pagos = []);
      }
    } catch (e) {
      setState(() => pagos = []);
    }
  }
  

  Future<void> generarPDF() async {
    print("🖨️ Entrando a generarPDF...");

    if (pagos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay datos para generar el PDF")),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final ByteData imageData = await rootBundle.load('images/PICNITO LOGO.jpeg');
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      final logoImage = pw.MemoryImage(imageBytes);

      final ahora = DateTime.parse(fechaSeleccionada);
      final hasta = ahora.add(const Duration(days: 15));
      final fechaDesde = "${ahora.day.toString().padLeft(2, '0')}-${ahora.month.toString().padLeft(2, '0')}-${ahora.year}";
      final fechaHasta = "${hasta.day.toString().padLeft(2, '0')}-${hasta.month.toString().padLeft(2, '0')}-${hasta.year}";

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.ClipOval(child: pw.Image(logoImage, width: 60, height: 60)),
                pw.Text("Del $fechaDesde al $fechaHasta",
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('PICNITO CINEMIA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Reporte de Pagos', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['ID', 'Cliente', 'Fecha', 'Total', 'Recibido', 'Cambio', 'Película', 'Función'],
              data: pagos.map((p) => [
                '${p["id_pago"]}',
                '${p["nombre_cliente"]}',
                DateTime.tryParse(p["fecha_pago"] ?? "") != null
                    ? "${DateTime.parse(p["fecha_pago"]).day.toString().padLeft(2, '0')}/"
                      "${DateTime.parse(p["fecha_pago"]).month.toString().padLeft(2, '0')}/"
                      "${DateTime.parse(p["fecha_pago"]).year}"
                    : '',
                '\$${p["monto_total"]}',
                '\$${p["monto_recibido"]}',
                '\$${p["cambio"]}',
                '${p["pelicula"] ?? ''}',
                DateTime.tryParse(p["funcion_horario"] ?? "") != null
                ? DateTime.parse(p["funcion_horario"]).toLocal().toString().substring(11, 16)
                : ''
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print("❌ Error al generar el PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaObj = DateTime.tryParse(fechaSeleccionada);
    final fechaFin = fechaObj != null ? fechaObj.add(const Duration(days: 15)) : DateTime.now();
    final textoCorte = fechaObj != null
      ? 'Del ${fechaObj.day.toString().padLeft(2, '0')}-'
        '${fechaObj.month.toString().padLeft(2, '0')}-'
        '${fechaObj.year} al '
        '${fechaFin.day.toString().padLeft(2, '0')}-'
        '${fechaFin.month.toString().padLeft(2, '0')}-'
        '${fechaFin.year}'
      : 'Corte inválido';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF061C3D),
        foregroundColor: Colors.white,
        title: const Text("🧾 Reporte de Pagos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () => cargarPagosPorFecha(fechaSeleccionada),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generar PDF',
            onPressed: generarPDF,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('images/PICNITO LOGO.jpeg'),
              radius: 20,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              children: [
                const Text(
                  "Corte:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: fechaSeleccionada.isNotEmpty ? fechaSeleccionada : null,
                  items: fechasDisponibles.map((fecha) => DropdownMenuItem(
                    value: fecha,
                    child: Text(fecha),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      fechaSeleccionada = value!;
                    });
                    cargarPagosPorFecha(fechaSeleccionada);
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              textoCorte,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF061C3D),
              ),
            ),
          ),
          Expanded(
            child: pagos.isEmpty
              ? const Center(child: Text("📭 No hay pagos registrados aún"))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("ID")),
                      DataColumn(label: Text("Cliente")),
                      DataColumn(label: Text("Fecha")),
                      DataColumn(label: Text("Total")),
                      DataColumn(label: Text("Recibido")),
                      DataColumn(label: Text("Cambio")),
                      DataColumn(label: Text("Película")),
                      DataColumn(label: Text("Función")),
                    ],
                    rows: pagos.map((pago) {
                      final fecha = DateTime.tryParse(pago["fecha_pago"]);
                      final formatoFecha = fecha != null
                          ? '${fecha.day.toString().padLeft(2, '0')}/'
                            '${fecha.month.toString().padLeft(2, '0')}/'
                            '${fecha.year}'
                          : 'Fecha inválida';

                      return DataRow(cells: [
                        DataCell(Text('${pago["id_pago"]}')),
                        DataCell(Text('${pago["nombre_cliente"]}')),
                        DataCell(Text(formatoFecha)),
                        DataCell(Text('\$${pago["monto_total"]}')),
                        DataCell(Text('\$${pago["monto_recibido"]}')),
                        DataCell(Text('\$${pago["cambio"]}')),
                        DataCell(Text('${pago["pelicula"]}')),
                       // Dentro del `DataRow`:
                        DataCell(
                          Text(
                          pago["funcion_horario"] != null && pago["funcion_horario"].toString().isNotEmpty
                          ? (DateTime.tryParse(pago["funcion_horario"]) != null
                          ? DateTime.parse(pago["funcion_horario"]).toLocal().toString().substring(11, 16)
                          : "Formato inválido")
                          : "No asignado"
                          ),
                        ),

                      ]);
                    }).toList(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

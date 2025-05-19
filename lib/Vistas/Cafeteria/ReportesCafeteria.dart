import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:printing/printing.dart';

const String baseUrl = 'http://localhost:3000';

class ReportesCafe extends StatefulWidget {
  const ReportesCafe({super.key});

  @override
  State<ReportesCafe> createState() => _ReportesCafeState();
}

class _ReportesCafeState extends State<ReportesCafe> {
  List<Map<String, dynamic>> ventasCafe = [];
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
      if (response.statusCode == 200) {
        final data = List<String>.from(jsonDecode(response.body));
        data.sort((a, b) => a.compareTo(b));
        setState(() {
          fechasDisponibles = data;
          if (data.isNotEmpty) {
            fechaSeleccionada = data.first;
            cargarVentas(fechaSeleccionada);
          }
        });
      }
    } catch (e) {
      print("❌ Error fechas: $e");
    }
  }

  Future<void> cargarVentas(String fecha) async {
    final desde = DateTime.parse(fecha);
    final hasta = desde.add(const Duration(days: 15));
    final url = Uri.parse(
      '$baseUrl/api/admin/reporte-cafeteria?desde=${desde.toIso8601String()}&hasta=${hasta.toIso8601String()}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ventasCafe = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() => ventasCafe = []);
      }
    } catch (e) {
      print("❌ Error cargando ventas: $e");
    }
  }

  Future<void> generarPDF() async {
    if (ventasCafe.isEmpty) return;

    final pdf = pw.Document();
    final ByteData imageData = await rootBundle.load('images/PICNITO LOGO.jpeg');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final logo = pw.MemoryImage(imageBytes);

    final desde = DateTime.parse(fechaSeleccionada);
    final hasta = desde.add(const Duration(days: 15));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logo, width: 50),
              pw.Text(
                "Del ${desde.day}/${desde.month}/${desde.year} al ${hasta.day}/${hasta.month}/${hasta.year}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              )
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text("Reporte de Ventas Cafetería", style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Producto/Combo', 'Cantidad', 'Precio Unitario', 'Total', 'Fecha'],
            data: ventasCafe.map((e) => [
              e["nombre"] ?? '',
              '${e["cantidad"] ?? 0}',
              '\$${e["precio_unitario"]?.toStringAsFixed(2) ?? "0.00"}',
              '\$${e["total"]?.toStringAsFixed(2) ?? "0.00"}',
              e["fecha_creacion"] ?? '',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total general: \$${calcularTotalGeneral().toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  double calcularTotalGeneral() {
    return ventasCafe.fold(0.0, (acc, e) {
      final total = (e["total"] is num) ? e["total"].toDouble() : 0.0;
      return acc + total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01021E),
      appBar: AppBar(
        title: const Text("📊 Reporte Cafetería", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF061C3D),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: generarPDF,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Corte: ", style: TextStyle(color: Colors.white)),
              DropdownButton<String>(
                dropdownColor: const Color(0xFF081C42),
                value: fechaSeleccionada.isNotEmpty ? fechaSeleccionada : null,
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                items: fechasDisponibles
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => fechaSeleccionada = v!);
                  cargarVentas(v!);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ventasCafe.isEmpty
                ? const Center(
                    child: Text("📭 Sin registros", style: TextStyle(color: Colors.white)),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: ventasCafe.map((e) {
                            return ListTile(
                              title: Text(
                                e["nombre"] ?? '',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Cantidad: ${e["cantidad"]} - Fecha: ${e["fecha_creacion"]?.toString().split('T').first ?? 'Sin fecha'}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Text(
                                "\$${e["total"]?.toStringAsFixed(2) ?? '0.00'}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        alignment: Alignment.centerRight,
                        color: const Color(0xFF081C42),
                        child: Text(
                          "Total general: \$${calcularTotalGeneral().toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

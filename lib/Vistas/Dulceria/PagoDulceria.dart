// ✅ PAGO DULCERIA FINAL, corrigiendo registro y ticket

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proyecto_cine_equipo3/Modelo/CarritoCafeteria.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:proyecto_cine_equipo3/Modelo/ModeloReceta.dart';

Future<void> registrarPagoDulceria(double total, double recibido, double cambio,
    List<Producto> productos, List<Receta> combos) async {
  const url = 'http://localhost:3000/api/admin/registrar-pago-dulceria';

  final payload = {
    "monto_total": total,
    "monto_recibido": recibido,
    "cambio": cambio,
    "productos": productos.map((p) => {
      "nombre": p.nombre,
      "precio": p.precio,
      "cantidad": 1
    }).toList(),
    "combos": combos.map((c) => {
      "nombre": c.nombre,
      "precio": c.precio,
      "cantidad": 1
    }).toList()
  };

  final response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    print("✅ Pago registrado exitosamente");
  } else {
    print("❌ Error al registrar pago: ${response.body}");
  }
}

Future<void> generarTicketPDF(
  double total,
  double recibido,
  double cambio,
  List<Producto> productos,
  List<Receta> combos,
) async {
  final pdf = pw.Document();
  final roboto = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final ByteData imageData = await rootBundle.load('images/PICNITO LOGO.jpeg');
  final Uint8List imageBytes = imageData.buffer.asUint8List();
  final logoImage = pw.MemoryImage(imageBytes);
  final now = DateTime.now();
  final fecha = DateFormat('dd/MM/yyyy HH:mm').format(now);
  final colorFondo = PdfColor.fromInt(0xFF01021E);
  final colorPrincipal = PdfColor(0, 1, 1);
  final colorSecundario = PdfColor(1, 0, 1);
  final colorTexto = PdfColor(1, 1, 1);
  final colorAcento = PdfColor(0, 1, 0);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pw.Context context) {
        return pw.Container(
          color: colorFondo,
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.ClipOval(child: pw.Image(logoImage, width: 50, height: 50)),
                  pw.Text("Fecha: $fecha", style: pw.TextStyle(font: roboto, fontSize: 10, color: colorTexto)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text("PICNITO CINEMIA", style: pw.TextStyle(font: roboto, fontSize: 18, fontWeight: pw.FontWeight.bold, color: colorPrincipal)),
              pw.Text("Ticket de Compra", style: pw.TextStyle(font: roboto, fontSize: 12, color: colorSecundario)),
              pw.Container(height: 1, color: colorSecundario),
              pw.SizedBox(height: 6),
              pw.Text("Productos:", style: pw.TextStyle(font: roboto, fontWeight: pw.FontWeight.bold, color: colorTexto)),
              if (productos.isEmpty)
                pw.Text(" - Ninguno", style: pw.TextStyle(font: roboto, color: colorTexto))
              else
                ...productos.map((p) => pw.Text(" - ${p.nombre} (\$${p.precio.toStringAsFixed(2)})", style: pw.TextStyle(font: roboto, color: colorTexto))),
              pw.SizedBox(height: 6),
              pw.Text("Combos:", style: pw.TextStyle(font: roboto, fontWeight: pw.FontWeight.bold, color: colorTexto)),
              if (combos.isEmpty)
                pw.Text(" - Ninguno", style: pw.TextStyle(font: roboto, color: colorTexto))
              else
                ...combos.map((c) => pw.Text(" - ${c.nombre} (\$${c.precio.toStringAsFixed(2)})", style: pw.TextStyle(font: roboto, color: colorTexto))),
              pw.Container(height: 1, color: colorSecundario),
              pw.Text("Total: \$${total.toStringAsFixed(2)}", style: pw.TextStyle(font: roboto, color: colorTexto)),
              pw.Text("Recibido: \$${recibido.toStringAsFixed(2)}", style: pw.TextStyle(font: roboto, color: colorTexto)),
              pw.Text("Cambio: \$${cambio.toStringAsFixed(2)}", style: pw.TextStyle(font: roboto, color: colorTexto)),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text("\u00a1Gracias por tu compra!", style: pw.TextStyle(font: roboto, fontSize: 12, fontWeight: pw.FontWeight.bold, color: colorAcento))),
            ],
          ),
        );
      },
    ),
  );

  final output = await getApplicationDocumentsDirectory();
  final file = File("${output.path}/Ticket_${DateTime.now().millisecondsSinceEpoch}.pdf");
  await file.writeAsBytes(await pdf.save());
  print("✅ Ticket guardado en: \${file.path}");
}

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: SDulce()));

class SDulce extends StatelessWidget {
  const SDulce({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: VentanaPagosC());
}

class VentanaPagosC extends StatefulWidget {
  const VentanaPagosC({super.key});
  @override
  _VentanaPagosState createState() => _VentanaPagosState();
}

final montoRecibidoController = TextEditingController();
final cambioController = TextEditingController();
double total = 0.0;

class _VentanaPagosState extends State<VentanaPagosC> {
  @override
  void initState() {
    super.initState();
    total = CarritoCafeteriaGlobal().total;
  }

  Widget TarjetaPelicula() {
    final productos = CarritoCafeteriaGlobal().productosSeleccionados;
    final combos = CarritoCafeteriaGlobal().combosSeleccionados;
    if (productos.isEmpty && combos.isEmpty) {
      return const Text('No hay items en el carrito', style: TextStyle(color: Colors.white));
    }
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productos.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: productos.map((item) => Chip(label: Text("${item.nombre} - \$${item.precio.toStringAsFixed(2)}"))).toList(),
              ),
            if (combos.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text("Combos:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: combos.map((combo) => Chip(label: Text("${combo.nombre} - \$${combo.precio.toStringAsFixed(2)}"))).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget SecciondePago() {
    bool esMiembro = false;
    bool usarCashback = false;

    return StatefulBuilder(builder: (ctx, setState) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Checkbox(value: esMiembro, onChanged: (value) => setState(() => esMiembro = value!)),
            const Text('Miembros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          ]),
          if (esMiembro) ...[
            const SizedBox(height: 10),
            TextFields('Nombre'),
            const SizedBox(height: 10),
            TextFields('Apellido'),
            const SizedBox(height: 10),
            TextFields('Teléfono'),
            const SizedBox(height: 10),
            TextFields('Cashback'),
            const SizedBox(height: 10),
            Row(children: [
              Checkbox(value: usarCashback, onChanged: (value) => setState(() => usarCashback = value!)),
              const Text('Usar Cashback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))
            ]),
          ],
          Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: montoRecibidoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto Recibido', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            onChanged: (val) {
              final recibido = double.tryParse(val) ?? 0.0;
              final cambio = recibido - total;
              cambioController.text = cambio.toStringAsFixed(2);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: cambioController,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Cambio', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                final recibido = double.tryParse(montoRecibidoController.text) ?? 0;
                final cambio = recibido - total;
                final productos = CarritoCafeteriaGlobal().productosSeleccionados;
                final combos = CarritoCafeteriaGlobal().combosSeleccionados;
                await registrarPagoDulceria(total, recibido, cambio, productos, combos);
                await generarTicketPDF(total, recibido, cambio, productos, combos);
                CarritoCafeteriaGlobal().limpiar();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0665A4),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Pagar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      );
    });
  }

  Widget TextFields(String label) => TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF022044), Color(0xFF01021E)]),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                          const SizedBox(width: 10),
                          const Text('Atras', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ]),
                        const Text('Pago', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF0665A4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset('images/PICNITO LOGO.jpeg', fit: BoxFit.contain),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 900,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff081C42),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TarjetaPelicula(),
                            const SizedBox(height: 20),
                            SecciondePago(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

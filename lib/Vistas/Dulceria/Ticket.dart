import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proyecto_cine_equipo3/Modelo/CarritoCafeteria.dart';

Future<void> generarTicketPDF(double total, double recibido, double cambio) async {
  final pdf = pw.Document();
  final carrito = CarritoCafeteriaGlobal();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('🎟️ Ticket - PICHTO CINEMAS',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Fecha: ${DateTime.now()}'),
          pw.Divider(),

          // Productos
          pw.Text('🍭 Productos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...carrito.productosSeleccionados.map((p) => pw.Text('${p.nombre} - \$${p.precio.toStringAsFixed(2)}')),

          pw.SizedBox(height: 10),

          // Combos
          pw.Text('🥡 Combos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...carrito.combosSeleccionados.map((c) => pw.Text('${c.nombre} - \$${c.precio.toStringAsFixed(2)}')),

          pw.Divider(),
          pw.Text('💰 Total: \$${total.toStringAsFixed(2)}'),
          pw.Text('💵 Recibido: \$${recibido.toStringAsFixed(2)}'),
          pw.Text('🔁 Cambio: \$${cambio.toStringAsFixed(2)}'),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text('¡Gracias por tu compra!',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}

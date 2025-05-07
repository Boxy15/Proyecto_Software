import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloTipoBoleto.dart';
import 'package:proyecto_cine_equipo3/Vistas/Taquilla/SeleccionAsientos.dart';
import 'package:proyecto_cine_equipo3/Controlador/Taquilla/Proceso.dart';

/*void main() {
  runApp(const SBoletos());
}*/

class SBoletos extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String horario;
  final String sala;
  final String poster;

  const SBoletos({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.horario,
    required this.sala,
    required this.poster,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SeleccionBoletos(
        titulo: titulo,
        fecha: fecha,
        horario: horario,
        sala: sala,
        poster: poster,
      ),
    );
  }
}

class SeleccionBoletos extends StatefulWidget {
  final String titulo;
  final String fecha;
  final String horario;
  final String sala;
  final String poster;

  const SeleccionBoletos({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.horario,
    required this.sala,
    required this.poster,
  });

  @override
  _SeleccionBoletosState createState() => _SeleccionBoletosState();
}

class _SeleccionBoletosState extends State<SeleccionBoletos> {
  List<int> cantidades = [];
  double total = 0.0;
  TextEditingController totalController =
      TextEditingController(text: 'Total: \$0.00');
  final BoletosController boletosController = BoletosController();
  late String tipoSala;

  @override
  void initState() {
    super.initState();
    tipoSala =
        int.tryParse(widget.sala) != null && int.parse(widget.sala) % 2 == 0
            ? '3D'
            : '2D';
  }

  Widget TarjetaPelicula(
    String titulo,
    String fecha,
    String horario,
    String sala,
    String poster,
  ) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black12,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: widget.poster.startsWith('data:image')
                    ? Image.memory(
                        const Base64Decoder().convert(
                          widget.poster.split(',').last,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 40);
                        },
                      )
                    : Image.asset(
                        'assets/placeholder.jpg',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Fecha: $fecha',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Hora: $horario',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Sala: $sala',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void recalcularTotal(List<TipoBoleto> boletos) {
    double nuevoTotal = 0.0;
    for (int i = 0; i < cantidades.length; i++) {
      nuevoTotal += cantidades[i] * boletos[i].precio;
    }
    setState(() {
      total = nuevoTotal;
      totalController.text = 'Total: \$${total.toStringAsFixed(2)}';
    });
  }

  Widget SeleccionBoletos() {
    return FutureBuilder<List<TipoBoleto>>(
      future: boletosController.obtenerBoletos(widget.fecha, tipoSala),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No hay boletos disponibles.');
        } else {
          final boletos = snapshot.data!;
          if (cantidades.isEmpty) {
            cantidades = List.filled(boletos.length, 0);
          }

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ...List.generate(boletos.length, (index) {
                    final boleto = boletos[index];
                    return Column(
                      children: [
                        TiposBoletos(
                            boleto.nombre, boleto.precio, index, boletos),
                        const Divider(color: Colors.black54),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black54),
                          ),
                          child: TextField(
                            readOnly: true,
                            controller: totalController,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          final int totalBoletos =
                              cantidades.fold(0, (sum, item) => sum + item);

                          if (totalBoletos == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '⚠️ Debes seleccionar al menos un boleto.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SAsientos(
                                titulo: widget.titulo,
                                fecha: widget.fecha,
                                horario: widget.horario,
                                sala: widget.sala,
                                boletos: totalBoletos.toString(),
                                poster: widget.poster,
                                total: total,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0665A4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Siguiente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget TiposBoletos(
    String tipo,
    double precio,
    int index,
    List<TipoBoleto> boletos,
  ) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 140, // Ajusta si ves que se corta texto
              child: Text(
                tipo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              '\$$precio',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (cantidades[index] > 0) {
                      setState(() {
                        cantidades[index]--;
                        total = boletosController.calcularTotal(
                            cantidades, boletos);
                        totalController.text =
                            'Total: \$${total.toStringAsFixed(2)}';
                      });
                    }
                  },
                  icon: const Icon(Icons.remove, color: Colors.black),
                ),
                Text(
                  '${cantidades[index]}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      cantidades[index]++;
                      total =
                          boletosController.calcularTotal(cantidades, boletos);
                      totalController.text =
                          'Total: \$${total.toStringAsFixed(2)}';
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF022044), Color(0xFF01021E)],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Atras',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Seleccion de Boletos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF0665A4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              'images/PICNITO LOGO.jpeg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 900,
                          height: 550,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff081C42),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TarjetaPelicula(
                                  widget.titulo,
                                  widget.fecha,
                                  widget.horario,
                                  widget.sala,
                                  widget.poster,
                                ),
                                const SizedBox(height: 15),
                                SeleccionBoletos(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

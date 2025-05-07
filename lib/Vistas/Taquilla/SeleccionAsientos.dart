import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Controlador/Taquilla/Proceso.dart';
import 'package:proyecto_cine_equipo3/Vistas/Taquilla/PagoTaquilla.dart';

class SAsientos extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String horario;
  final String sala;
  final String boletos;
  final String poster;
  final double total;

  const SAsientos({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.horario,
    required this.sala,
    required this.boletos,
    required this.poster,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SeleccionAsientos(
        titulo: titulo,
        fecha: fecha,
        horario: horario,
        sala: sala,
        boletos: boletos,
        poster: poster,
        total: total,
      ),
    );
  }
}

class SeleccionAsientos extends StatefulWidget {
  final String titulo;
  final String fecha;
  final String horario;
  final String sala;
  final String boletos;
  final String poster;
  final double total;

  const SeleccionAsientos({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.horario,
    required this.sala,
    required this.boletos,
    required this.poster,
    required this.total,
  });

  @override
  _SeleccionAsientosState createState() => _SeleccionAsientosState();
}

class _SeleccionAsientosState extends State<SeleccionAsientos> {
  late List<Map<String, dynamic>> asientos;
  int asientosPermitidos = 0;
  int asientosActualmenteSeleccionados = 0;
  final AsientosController asientosController = AsientosController();

  @override
  void initState() {
    super.initState();
    inicializarAsientos();
    asientosPermitidos = int.tryParse(widget.boletos) ?? 0;
  }

  Future<void> inicializarAsientos() async {
    asientos = List.generate(32, (index) {
      int fila = index ~/ 8; // 0, 1, 2, 3
      int columna = index % 8; // 0..7
      String letraFila = String.fromCharCode(65 + fila); // 'A', 'B', 'C', 'D'
      return {
        'ocupado': false,
        'seleccionado': false,
        'id': '$letraFila${columna + 1}',
      };
    });

    try {
      List<String> ocupados = await asientosController.cargarAsientosOcupados(
        fecha: widget.fecha,
        horario: widget.horario,
        sala: widget.sala,
      );

      setState(() {
        for (var id in ocupados) {
          int index = asientos.indexWhere((asiento) => asiento['id'] == id);
          if (index != -1) {
            asientos[index]['ocupado'] = true;
          }
        }
      });
    } catch (e) {
      // Manejo de errores al cargar asientos ocupados
      print('Error al cargar asientos ocupados: $e');
    }
  }

  void seleccionarAsiento(int index) {
    setState(() {
      if (asientos[index]['ocupado']) return;

      if (asientos[index]['seleccionado']) {
        // Deseleccionar
        asientos[index]['seleccionado'] = false;
        asientosActualmenteSeleccionados--;
      } else {
        if (asientosActualmenteSeleccionados < asientosPermitidos) {
          // Seleccionar
          asientos[index]['seleccionado'] = true;
          asientosActualmenteSeleccionados++;
        }
      }
    });
  }

  Widget Asientos() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: asientos.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            IconButton(
              onPressed: asientos[index]['ocupado']
                  ? null
                  : () {
                      seleccionarAsiento(index);
                    },
              icon: Icon(
                Icons.chair_rounded,
                size: 30,
                color: asientos[index]['ocupado']
                    ? const Color(0xFF767676)
                    : asientos[index]['seleccionado']
                        ? const Color(0xFFFAB802)
                        : const Color(0xFF14AE5C),
              ),
            ),
            Text(
              asientos[index]['id'],
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        );
      },
    );
  }

  Widget TarjetaPelicula(
    String titulo,
    String fecha,
    String horario,
    String sala,
    String boletos,
  ) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(
        vertical: 10, /*horizontal: 4*/
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
                  const SizedBox(height: 5),
                  Text(
                    'Boletos: $boletos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget SeleccionAsientos() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 30,
                      child: Container(
                        color: const Color(0xFFFAB802),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Asiento Seleccionado',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 30,
                      child: Container(
                        color: const Color(0xFF767676),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ocupado',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 30,
                      child: Container(
                        color: const Color(0xFF14AE5C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              color: Colors.black54,
              thickness: 1,
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              height: 30,
              color: const Color(0XFF767676),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('PANTALLA',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Asientos(),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
                          'Seleccion de Asientos',
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
                                  widget.boletos,
                                ),
                                const SizedBox(height: 20),
                                SeleccionAsientos(),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                List<String> asientosSeleccionados = asientos
                    .where((asiento) => asiento['seleccionado'])
                    .map((asiento) => asiento['id'] as String)
                    .toList();

                if (asientosSeleccionados.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '⚠️ Selecciona al menos un asiento para continuar.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                String asientosString = asientosSeleccionados.join(', ');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => STaquilla(
                      titulo: widget.titulo,
                      fecha: widget.fecha,
                      horario: widget.horario,
                      sala: widget.sala,
                      boletos: widget.boletos,
                      poster: widget.poster,
                      asientos: asientosString,
                      total: widget.total,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0665A4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

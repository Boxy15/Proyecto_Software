import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Vistas/Taquilla/SeleccionBoletos.dart';
import 'package:proyecto_cine_equipo3/Controlador/Taquilla/Proceso.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloFunciones.dart';

class SFunciones extends StatelessWidget {
  const SFunciones({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SeleccionFunciones(),
    );
  }
}

class SeleccionFunciones extends StatefulWidget {
  const SeleccionFunciones({super.key});

  @override
  _SeleccionFuncionesState createState() => _SeleccionFuncionesState();
}

class _SeleccionFuncionesState extends State<SeleccionFunciones> {
  final TextEditingController fechaController = TextEditingController();
  final FuncionesController funcionesController = FuncionesController();
  DateTime? fecha;

  @override
  void initState() {
    super.initState();
    final String fechaHoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    fechaController.text = fechaHoy;
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00BFA5), // color de selección
              surface: Color(0xFF1E2A45), // fondo del recuadro
              onSurface: Colors.white, // texto
            ),
            dialogBackgroundColor: const Color(0xFF121212), // fondo general
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        fecha = fechaSeleccionada;
        fechaController.text =
            DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
      });
    }
  }

  Future<List<Funcion>> obtenerFunciones() async {
    if (fechaController.text.isEmpty) {
      return [];
    }
    return await funcionesController
        .obtenerFuncionesPorFecha(fechaController.text);
  }

  Widget BotonHorario(String texto, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      onPressed: onPressed,
      child: Text(
        texto,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget TarjetaPelicula(Funcion funcion) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black12,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: funcion.poster.startsWith('data:image')
                    ? Image.memory(
                        // Decodifica el base64
                        const Base64Decoder().convert(
                          funcion.poster.split(',').last,
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
                    funcion.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.category,
                              size: 16, color: Color(0xffFF6F61)),
                          const SizedBox(width: 5),
                          Text(
                            'Género: ${funcion.genero}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Color(0xFFf9c74f)),
                          const SizedBox(width: 5),
                          Text(
                            'Clasificación: ${funcion.clasificacion}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Color(0xff4A90E2)),
                          const SizedBox(width: 5),
                          Text(
                            'Duración: ${funcion.duracion}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...funcion.funciones.entries.map((entry) {
                    final idioma = entry.key;
                    final horarios = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          idioma.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: horarios.map((horarioData) {
                            final horario = horarioData['horario']!;
                            final tipoSala = horarioData['tipo_sala']!;

                            return BotonHorario(
                              '$horario - $tipoSala',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SBoletos(
                                      titulo: funcion.titulo,
                                      fecha: fechaController.text,
                                      horario: horario,
                                      sala: horarioData['sala']!,
                                      poster: funcion.poster,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                ],
              ),
            ),
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
                            'Atrás',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 100),
                        child: Text(
                          'Seleccionar Función',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Fecha: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            width: 200,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              controller: fechaController,
                              readOnly: true,
                              onTap: () => seleccionarFecha(context),
                              decoration: const InputDecoration(
                                hintText: 'Seleccione una fecha',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                prefixIcon: Icon(Icons.date_range),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    top: 8, left: 10, bottom: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Funcion>>(
                    future: obtenerFunciones(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay funciones disponibles para la fecha seleccionada.',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        return ListView(
                          children: snapshot.data!
                              .map((funcion) => TarjetaPelicula(funcion))
                              .toList(),
                        );
                      }
                    },
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

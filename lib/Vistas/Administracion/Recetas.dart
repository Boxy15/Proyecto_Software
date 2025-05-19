import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_cine_equipo3/Vistas/Services/Multiseleccion.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Recetas(),
  ));
}

class Recetas extends StatelessWidget {
  const Recetas({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: formularioRecetas(),
    );
  }
}

class formularioRecetas extends StatefulWidget {
  const formularioRecetas({super.key});

  @override
  _formularioRecetasState createState() => _formularioRecetasState();
}

class _formularioRecetasState extends State<formularioRecetas> {
  final consumiblesController = TextEditingController();
  final nombreController = TextEditingController();
  final stockController = TextEditingController();
  final costoController = TextEditingController();
  final cConsumiblesController = TextEditingController();
  File? _imagen;
  String dropdownValue = 'U';

  final List<String> _consumibles = [
    "Maiz Palomero",
    "Mantequilla",
    "Queso Amarillo"
  ];
  List<String> _consumiblesSeleccionados = [];

  Future<void> _seleccionarImagen() async {
    final imgSeleccionada =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (imgSeleccionada != null) {
        _imagen = File(imgSeleccionada.path);
      } else {
        Exception('No image selected.');
      }
    });
  }

  Future<void> _seleccionarConsumibles() async {
    final List<String> seleccionados = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _consumibles,
          initialSelectedItems: _consumiblesSeleccionados,
          titulo: 'Seleccione los consumibles a usar',
        );
      },
    );
    setState(() {
      _consumiblesSeleccionados = seleccionados;
      //consumiblesController.text = _consumiblesSeleccionados.join(', ');
    });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  'Recetas',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                width: 750,
                height: 600,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff081C42),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.arrow_back,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      size: 30),
                                ),
                                const Text(
                                  'Atras',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ],
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
                        const SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _imagen == null
                                      ? Container(
                                          width: 130,
                                          height: 180,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image,
                                              size: 100, color: Colors.grey),
                                        )
                                      : Image.file(
                                          _imagen!,
                                          width: 130,
                                          height: 180,
                                          fit: BoxFit.contain,
                                        ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 40,
                                    width: 130,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _seleccionarImagen();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          backgroundColor:
                                              const Color(0xff434343)),
                                      child: const Text(
                                        'Cargar Imagen',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xffF5F5F5)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(width: 30),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nombre de la receta',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 250,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: TextField(
                                      cursorColor: const Color(0xff000000),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff000000)),
                                      controller: nombreController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                  const Text(
                                    'Consumibles a usar',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 250,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: TextField(
                                      onTap: () {},
                                      controller: consumiblesController,
                                      decoration: const InputDecoration(
                                          hintText: 'Buscar consumible',
                                          hintStyle: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                          prefixIcon: Icon(Icons.search)),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Ingrese la cantidad usada de cada consumible',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 250,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: _consumiblesSeleccionados
                                            .map((consumible) => ListTile(
                                                  title: Text(
                                                    consumible,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: Row(
                                                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black),
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: const TextField(
                                                          //controller: cConsumiblesController,
                                                          cursorColor:
                                                              Color(
                                                                  0xff000000),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xff000000)),
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    bottom: 10),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Text("Unidad"),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                            size: 24),
                                                        onPressed: () {
                                                          setState(() {
                                                            _consumiblesSeleccionados
                                                                .remove(
                                                                    consumible);
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cantidad producida',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width: 190,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextField(
                                          cursorColor: const Color(0xff000000),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff000000)),
                                          controller: stockController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                left: 10, bottom: 10),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.only(left: 10),
                                        width: 50,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: DropdownButton<String>(
                                          items: <String>[
                                            'U',
                                            'Kg',
                                            'L',
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              dropdownValue = value!;
                                            });
                                          },
                                          value: dropdownValue,
                                          icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black),
                                          iconSize: 20,
                                          elevation: 16,
                                          style: const TextStyle(
                                              color: Colors.black),
                                          underline: Container(
                                            height: 0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 50),
                                  const Text(
                                    'Costo Total estimado',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 250,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: TextField(
                                      readOnly: true,
                                      cursorColor: const Color(0xff000000),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff000000)),
                                      controller: costoController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: SizedBox(
                        height: 40,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: const Color(0xff14AE5C),
                          ),
                          child: const Text(
                            'Guardar Receta',
                            style: TextStyle(color: Color(0xffF5F5F5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

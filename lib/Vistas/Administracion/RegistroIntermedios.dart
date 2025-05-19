import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/ListaIntermedio.dart';
import 'dart:io';

import 'package:proyecto_cine_equipo3/Vistas/Services/Multiseleccion.dart';

void main() {
  runApp(const Registrointermedios());
}

class Registrointermedios extends StatelessWidget {
  const Registrointermedios({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: formulario(),
      ),
    );
  }
}

class Consumible {
  final int id;
  final String nombre;
  final String unidad;
  final double precioUnitario;
  final int stock;

  Consumible({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.precioUnitario,
    required this.stock,
  });

  factory Consumible.fromJson(Map<String, dynamic> json) {
    return Consumible(
      id: json['id'],
      nombre: json['nombre'],
      unidad: json['unidad'],
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      stock: json['stock'],
    );
  }
}

class ConsumibleUsado {
  final String nombre;
  final double cantidadUsada;

  ConsumibleUsado({required this.nombre, required this.cantidadUsada});

  factory ConsumibleUsado.fromJson(Map<String, dynamic> json) {
    return ConsumibleUsado(
      nombre: json['nombre'],
      cantidadUsada: json['cantidad_usada'].toDouble(),
    );
  }
}

class Intermedio {
  final int id;
  final String nombre;
  final String? imagen;
  final double cantidadProducida;
  final String unidad;
  final double costoTotalEstimado;
  final List<ConsumibleUsado> consumibles;

  Intermedio({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.cantidadProducida,
    required this.unidad,
    required this.costoTotalEstimado,
    required this.consumibles,
  });

  factory Intermedio.fromJson(Map<String, dynamic> json) {
    var listaConsumibles = (json['consumibles'] as List)
        .map((item) => ConsumibleUsado.fromJson(item))
        .toList();

    return Intermedio(
      id: json['id'],
      nombre: json['nombre'],
      imagen: json['imagen'],
      cantidadProducida: json['cantidad_producida'].toDouble(),
      unidad: json['unidad'],
      costoTotalEstimado: json['costo_total_estimado'].toDouble(),
      consumibles: listaConsumibles,
    );
  }
}

class formulario extends StatefulWidget {
  const formulario({super.key});

  @override
  _formularioState createState() => _formularioState();
}

class _formularioState extends State<formulario> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController costoController = TextEditingController();
  final TextEditingController consumiblesController = TextEditingController();

  File? _imagen;
  String dropdownValue = 'U';
  String? _imagenUrl;

  List<Consumible> _consumiblesDisponibles = [];

  void _calcularCostoTotal() {
    double total = 0.0;

    _consumiblesSeleccionados.forEach((nombre, controller) {
      final cantidad = double.tryParse(controller.text) ?? 0.0;
      final consumible = _consumiblesDisponibles.firstWhere(
        (c) => c.nombre == nombre,
        orElse: () => Consumible(
            id: 0, nombre: '', unidad: '', precioUnitario: 0.0, stock: 0),
      );
      total += cantidad * consumible.precioUnitario;
    });

    setState(() {
      costoController.text = total.toStringAsFixed(2);
    });
  }

  Future<void> _fetchConsumibles() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/api/admin/getAllConsumibles'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _consumiblesDisponibles =
              data.map((json) => Consumible.fromJson(json)).toList();
        });
      } else {
        // Manejo de errores
      }
    } catch (e) {
      // Manejo de unidad
    }
  }

//controller
  @override
  void initState() {
    super.initState();
    _fetchConsumibles();
  }

  final List<String> _unidades = ['U', 'Kg', 'L'];

  final Map<String, TextEditingController> _consumiblesSeleccionados = {};

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagenSeleccionada =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagenSeleccionada == null) return;

    setState(() {
      _imagen = File(imagenSeleccionada.path);
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/admin/uploadImage'),
    );

    request.files
        .add(await http.MultipartFile.fromPath('poster', _imagen!.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final imageUrl = jsonDecode(responseBody)['imageUrl'];

      setState(() {
        _imagenUrl = imageUrl;
      });

      print("✅ Imagen subida: $_imagenUrl");
    } else {
      print("❌ Error al subir imagen: ${response.statusCode}");
    }
  }

  Future<void> _seleccionarConsumibles() async {
    final List<String>? seleccionados = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _consumiblesDisponibles.map((c) => c.nombre).toList(),
          initialSelectedItems: _consumiblesSeleccionados.keys.toList(),
          titulo: 'Seleccione los consumibles a usar',
        );
      },
    );

    if (seleccionados != null) {
      setState(() {
        final nuevosSeleccionados = <String, TextEditingController>{};

        for (var consumible in seleccionados) {
          if (_consumiblesSeleccionados.containsKey(consumible)) {
            nuevosSeleccionados[consumible] =
                _consumiblesSeleccionados[consumible]!;
          } else {
            nuevosSeleccionados[consumible] = TextEditingController();
          }
        }

        _consumiblesSeleccionados
          ..clear()
          ..addAll(nuevosSeleccionados);
      });

      _calcularCostoTotal(); // Opcional si quieres recalcular al cerrar selección
    }
  }

  void _guardarIntermedio() async {
    if (nombreController.text.isEmpty ||
        stockController.text.isEmpty ||
        costoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Todos los campos deben estar completos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? stock = double.tryParse(stockController.text);
    final double? costo = double.tryParse(costoController.text);
    if (stock == null || costo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Valores numéricos inválidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> body = {
      'nombre': nombreController.text,
      'imagen': _imagenUrl ?? '',
      'cantidad_producida': stock,
      'unidad': dropdownValue,
      'costo_total_estimado': costo,
      'consumibles_usados': _consumiblesSeleccionados.entries.map((e) {
        return {
          'nombre': e.key,
          'cantidad_usada': double.tryParse(e.value.text) ?? 0.0,
        };
      }).toList(),
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/admin/addIntermedio'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Intermedio guardado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ListaIntermedios()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al guardar intermedio'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    'Registro de Intermedios',
                    style: TextStyle(
                      color: Color(0xffF5F5F5),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 750,
                  height: 550,
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
                          //_seleccionarImagen
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ListaIntermedios()),
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_back,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
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
                          const SizedBox(height: 50),
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
                                      'Nombre del Intermedio',
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
                                        controller: nombreController,
                                        cursorColor: Colors.black,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
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
                                        controller: consumiblesController,
                                        readOnly: true,
                                        onTap: _seleccionarConsumibles,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.inventory),
                                          hintText:
                                              'Selecciona los consumibles',
                                          hintStyle:
                                              TextStyle(color: Colors.black54),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
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
                                              .entries
                                              .map((entry) {
                                            final consumible = entry.key;
                                            final controller = entry.value;
                                            return ListTile(
                                              title: Text(consumible,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 70,
                                                    child: TextField(
                                                      controller: controller,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (_) =>
                                                          setState(() {
                                                        _calcularCostoTotal();
                                                      }),
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                bottom: 10),
                                                        errorText: () {
                                                          final cantidad =
                                                              double.tryParse(
                                                                      controller
                                                                          .text) ??
                                                                  0.0;
                                                          final stock =
                                                              _consumiblesDisponibles
                                                                  .firstWhere((c) =>
                                                                      c.nombre ==
                                                                      consumible)
                                                                  .stock;
                                                          return cantidad >
                                                                  stock
                                                              ? 'NoDisp'
                                                              : null;
                                                        }(),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _consumiblesDisponibles
                                                        .firstWhere((c) =>
                                                            c.nombre ==
                                                            consumible)
                                                        .unidad,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 24),
                                                    onPressed: () {
                                                      setState(() {
                                                        _consumiblesSeleccionados
                                                            .remove(consumible);
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
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
                                            cursorColor:
                                                const Color(0xff000000),
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
                                        //controller: controller
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
                            onPressed: _guardarIntermedio,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text('Guardar Intermedio',
                                style: TextStyle(color: Color(0xffF5F5F5))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Modelo/CarritoCafeteria.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/ListaCombos.dart';
import 'package:proyecto_cine_equipo3/Vistas/Cafeteria/CarritoCafeteria.dart';
import 'package:proyecto_cine_equipo3/Vistas/Services/SeleccionconTarjetasTama%C3%B1os.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloReceta.dart'; 

class ListaVentaDulceriaCombos extends StatelessWidget {
  const ListaVentaDulceriaCombos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Lista());
  }
}

class Lista extends StatefulWidget {
  const Lista({Key? key}) : super(key: key);

  @override
  _ListaState createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  final TextEditingController buscadorController = TextEditingController();
  late Future<List<Receta>> _combosFuture;

  @override
  void initState() {
    super.initState();
    _combosFuture = fetchCombos();
  }

  Future<List<Receta>> fetchCombos() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/api/admin/combos'));
    print('Respuesta status: ${response.statusCode}');
    print('Cuerpo: ${response.body}');

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Receta.fromJson(e)).toList();
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en fetchCombos(): $e');
    throw Exception('Error al obtener combos');
  }
}


void mostrarAlertaAgregarCarrito(Receta combo) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xff081C42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Agregar al Carrito', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        content: Text('¿Deseas agregar el combo "${combo.nombre}" al carrito por \$${combo.ingredientes.length * 30.0}?', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              CarritoCafeteriaGlobal().agregarCombo(combo);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('El combo "${combo.nombre}" ha sido agregado al carrito.', style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color.fromARGB(255, 38, 109, 36),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14AE5C)),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}


  Widget _buildTarjetaProducto(Receta combo) {
  return GestureDetector(
    onTap: () {
      mostrarAlertaAgregarCarrito(combo);
    },
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fastfood, size: 80, color: Colors.grey),
              const SizedBox(height: 8),
              Text(combo.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Precio: \$${combo.precio}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  )),
              const SizedBox(height: 4),
              Text('Descripción: ${combo.descripcion}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget buildListaProductos(List<Receta> combos) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 50,
        mainAxisSpacing: 20,
        childAspectRatio: 0.6,
      ),
      itemCount: combos.length,
      itemBuilder: (context, index) {
        final combo = combos[index];
        return _buildTarjetaProducto(combo);
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
                  const Padding(padding: EdgeInsets.only(top: 14)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
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
                                  color: Colors.white,
                                  size: 30),
                            ),
                            const Text(
                              'Atras',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        const Text(
                          'Combos',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        PopupMenuButton<int>(
                          tooltip: 'Opciones de usuario',
                          icon: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF081C42),
                            child: Icon(
                              Icons.account_circle_outlined,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          color: const Color(0xFF081C42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          offset: const Offset(0, 50),
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                children: const [
                                  Icon(Icons.logout, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text("Cerrar sesión",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: const [
                                  Icon(Icons.notifications_active,
                                      color: Colors.white),
                                  SizedBox(width: 10),
                                  Text("Notificaciones",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 0) {}
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: buscadorController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Buscar Combos...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.search, color: Colors.white),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (String value) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 1125,
                      height: 425,
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
                      child: FutureBuilder<List<Receta>>(
                        future: _combosFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // <-- AQUÍ PUEDES VER EL ERROR
                          } else {
                            return buildListaProductos(snapshot.data!);
                          }
                        },
                      ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CarritoDulceria(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0665A4),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shopping_cart_checkout_sharp,
                      color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
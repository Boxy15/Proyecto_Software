import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Vistas/Services/SeleccionconTarjetasTama%C3%B1os.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/ListaCombos.dart';
import 'package:proyecto_cine_equipo3/Vistas/Cafeteria/CarritoCafeteria.dart';
import 'package:proyecto_cine_equipo3/Modelo/CarritoCafeteria.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloReceta.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ListaVentaCafe(),
    ),
  );
}

class ListaVentaCafe extends StatelessWidget {
  const ListaVentaCafe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ListaCafe());
  }
}

class ListaCafe extends StatefulWidget {
  const ListaCafe({Key? key}) : super(key: key);

  @override
  _ListaStateCafe createState() => _ListaStateCafe();
}

class _ListaStateCafe extends State<ListaCafe> {
  final TextEditingController buscadorController = TextEditingController();
  late Future<List<Producto>> _productosFuture;

  final List<Map<String, dynamic>> productosT = [
    {
      'imagen':
          'images/pngtree-big-fat-box-of-popcorn-to-go-photo-png-image_13600773.png',
      'nombre': 'Grandes',
      'porcion': 100,
      'precio': 60.0,
    },
    {
      'imagen': 'images/tradicional.png',
      'nombre': 'Medianas',
      'porcion': 85,
      'precio': 50.0,
    },
    {
      'imagen': 'images/Palomitas.jpeg',
      'nombre': 'Chicas',
      'porcion': 60,
      'precio': 40.0,
    },
  ];
  List<Map<String, dynamic>> productosSeleccionadosT = [];

  @override
  void initState() {
    super.initState();
    _productosFuture = fetchProductos();
  }

  Future<List<Producto>> fetchProductos() async {
  final response = await http.get(
    Uri.parse('http://localhost:3000/api/admin/productos?departamento=cafeteria'),
  );


  print('🖨️ Respuesta del servidor: ${response.statusCode} — ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Producto.fromJson(item)).toList();
  } else {
    throw Exception('Error al cargar productos: ${response.statusCode}');
  }
}


  Future<void> _seleccionarProductos() async {
    final List<Map<String, dynamic>> seleccionados = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectCardDialogT(
          items: productosT,
          initialSelectedItems: productosSeleccionadosT,
          titulo: 'Selecciona el Tamaño',
        );
      },
    );
    if (seleccionados != null) {
      setState(() {
        productosSeleccionadosT = seleccionados;
      });
    }
  }

Widget _buildTarjetaProducto(Producto producto) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xff081C42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Agregar al Carrito',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Deseas agregar el producto "${producto.nombre}" al carrito por \$${producto.precio.toStringAsFixed(2)}?',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                CarritoCafeteriaGlobal().agregarProducto(producto);
                print("Productos en carrito:");
                for (var p in CarritoCafeteriaGlobal().productosSeleccionados) {
                  print("- ${p.nombre}");
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${producto.nombre} agregado al carrito.'),
                    backgroundColor: const Color.fromARGB(255, 38, 109, 36),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      );
    },
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    producto.imagen ?? 'images/default.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('images/default.png', width: 140, height: 140),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  producto.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${producto.stock}',
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildListaProductos(List<Producto> productos) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 50,
      mainAxisSpacing: 20,
      childAspectRatio: 0.6,
    ),
    itemCount: productos.length,
    itemBuilder: (context, index) {
      final producto = productos[index];
      return _buildTarjetaProducto(producto);
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
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                            ),
                            const Text(
                              'Atras',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Lista de Productos',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PopupMenuButton<int>(
                          tooltip: 'Opciones de usuario',
                          icon: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF081C42),
                            child: Icon(Icons.account_circle_outlined, size: 50, color: Colors.white),
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
                                  Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: const [
                                  Icon(Icons.notifications_active, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text("Notificaciones", style: TextStyle(color: Colors.white)),
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
                              hintText: 'Buscar Producto...',
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
                      child: FutureBuilder<List<Producto>>(
                        future: _productosFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            return _buildListaProductos(snapshot.data!);
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
                  MaterialPageRoute(builder: (context) => const CarritoCafe()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0665A4),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shopping_cart_checkout_sharp, color: Colors.white, size: 30),
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

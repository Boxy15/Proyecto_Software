import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';
import 'package:proyecto_cine_equipo3/Modelo/CarritoCafeteria.dart';
import 'package:proyecto_cine_equipo3/Vistas/Cafeteria/PagoCafeteria.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CarritoCafe(),
  ));
}


class CarritoCafe extends StatelessWidget {
  const CarritoCafe({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CCafe(),
    );
  }
}

class CCafe extends StatefulWidget {
  const CCafe({super.key});

  @override
  _CCafeState createState() => _CCafeState();
}

class _CCafeState extends State<CCafe> {
  final TextEditingController fechaController = TextEditingController();
  DateTime? selectedDate;

  // 🔧 Aquí debe ir la función
  Widget TarjetasCarrito() {
    final carrito = CarritoCafeteriaGlobal();
    List<Widget> tarjetas = [];

    // Mostrar productos
    for (var producto in carrito.productosSeleccionados) {
      tarjetas.add(Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(producto.nombre),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stock: ${producto.stock}'),
              Text('Precio: \$${producto.precio.toStringAsFixed(2)}'),
            ],
          ),
          trailing:
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fastfood, color: Colors.grey,),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: (){
                    setState(() {
                      carrito.productosSeleccionados.remove(producto);
                    });
                  },
                )
              ],
            )
        ),
      ));
    }

    // Mostrar combos
    for (var combo in carrito.combosSeleccionados) {
      tarjetas.add(Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(combo.nombre),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descripción: ${combo.descripcion}'),
              Text('Precio: \$${combo.precio.toStringAsFixed(2)}'),
            ],
          ),
          trailing:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fastfood, color: Colors.grey,),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: (){
                    setState(() {
                      carrito.combosSeleccionados.remove(combo);
                    });
                  },
                )
              ],
            )
        ),
      ));
    }

    if (tarjetas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'El carrito está vacío',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Column(children: tarjetas);
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
                                  Text(
                                    "Cerrar sesión",
                                    style: TextStyle(color: Colors.white),
                                  ),
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
                                  Text(
                                    "Notificaciones",
                                    style: TextStyle(color: Colors.white),
                                  ),
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
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 900,
                          height: 550,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xff081C42),
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
                                const Text(
                                  textAlign: TextAlign.center,
                                  'Carrito de Compras',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TarjetasCarrito(), 
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
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SCafe(),
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
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Continuar al pago',
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

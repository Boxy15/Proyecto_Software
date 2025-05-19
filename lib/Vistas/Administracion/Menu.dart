import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Funciones.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Peliculas.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Consumibles.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Extras.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/InicioSesion.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/ListaCombos.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/ListaIntermedio.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/ListaProductos.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Proveedores.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Usuarios.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Reportesprueba.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
  });

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Widget _buildSidebarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool bordeBoton = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: bordeBoton
            ? const Border(
                bottom: BorderSide(color: Colors.white, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF022044), Color(0xFF01021E)],
            ),
          ),
          child: Row(
            children: [
              // Sidebar
              Container(
                width: 180,
                margin: const EdgeInsets.only(
                    left: 30, right: 30, top: 60, bottom: 60),
                decoration: BoxDecoration(
                  color: const Color(0xFF081C42),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        margin: const EdgeInsets.only(top: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'images/PICNITO LOGO.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSidebarButton(
                        icon: Icons.bar_chart,
                        label: 'Reportes',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const VistaReportePagos()), // Cambia a la vista de reportes
                          );
                        },
                      ),
                      _buildSidebarButton(
                        icon: Icons.people,
                        label: 'Usuarios',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Usuarios()),
                          );
                        },
                      ),

                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white, width: 0.5),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ExpansionTile(
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                          title: const Row(
                            children: [
                              Icon(Icons.shopping_cart,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Productos',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          collapsedIconColor: Colors.white,
                          iconColor: Colors.white,
                          trailing: const Icon(Icons.expand_more,
                              color: Colors.white, size: 20),
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildSubmenuButton(
                                    icon: Icons.local_shipping,
                                    label: 'Proveedores',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Proveedores()),
                                      );
                                    },
                                  ),
                                  _buildSubmenuButton(
                                    icon: Icons.inventory,
                                    label: 'Consumibles',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Consumibles()),
                                      );
                                    },
                                  ),
                                  _buildSubmenuButton(
                                    icon: Icons.receipt_long_sharp,
                                    label: 'Recetas',
                                    onPressed: () {
                                      /* Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Registrointermedios()),
                                      );*/
                                    },
                                  ),
                                  _buildSubmenuButton(
                                    icon: EvaIcons.grid,
                                    label: 'Intermedios',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ListaIntermedios()),
                                      );
                                    },
                                  ),
                                  _buildSubmenuButton(
                                    icon: Icons.shopping_bag,
                                    label: 'Vendibles',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ListaProductos()),
                                      );
                                    },
                                  ),
                                  _buildSubmenuButton(
                                    icon: Icons.all_inclusive,
                                    label: 'Combos',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ListaCombos()),
                                      );
                                    },
                                  ),
                                  _buildSubmenuButton(
                                    icon: EvaIcons.plusCircle,
                                    label: 'Extras',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Extras()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ExpansionTile(
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                          title: const Row(
                            children: [
                              Icon(Icons.movie, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Funciones',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          collapsedIconColor: Colors.white,
                          iconColor: Colors.white,
                          trailing: const Icon(Icons.expand_more,
                              color: Colors.white, size: 20),
                          children: [
                            _buildSubmenuButton(
                              icon: Icons.schedule,
                              label: 'Funciones',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ListaFunciones()),
                                );
                              },
                            ),
                            _buildSubmenuButton(
                              icon: Icons.local_movies,
                              label: 'Películas',
                              onPressed: () {
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const listaPeliculas()),
                                );
                              },
                            ),
                            _buildSubmenuButton(
                              icon: Icons.confirmation_number,
                              label: 'Boletos',
                              onPressed: () {
                                
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 30, top: 50, bottom: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bienvenido Sr(a) Administrador',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          PopupMenuButton<int>(
                            tooltip: 'Opciones de usuario',
                            icon: const CircleAvatar(
                              radius: 25,
                              backgroundColor: Color(0xFF081C42),
                              child: Icon(
                                Icons.account_circle_outlined,
                                size: 50,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            color: const Color(0xFF081C42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            offset: const Offset(0, 50),
                            itemBuilder: (context) => [
                              const PopupMenuItem<int>(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      "Cerrar sesión",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 0) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const InicioSesion()),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Funciones programadas para hoy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            border: TableBorder.all(color: Colors.grey),
                            headingTextStyle:
                                const TextStyle(color: Colors.white),
                            dataTextStyle: const TextStyle(color: Colors.white),
                            columns: const <DataColumn>[
                              DataColumn(label: Text('Titulo')),
                              DataColumn(label: Text('Horario')),
                              DataColumn(label: Text('Fecha')),
                              DataColumn(label: Text('Sala')),
                              DataColumn(label: Text('Tipo')),
                              DataColumn(label: Text('Idioma')),
                              DataColumn(label: Text('Estado')),
                            ],
                            rows: const <DataRow>[
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Jurassic World: Rebirth')),
                                  DataCell(Text('13:20')),
                                  DataCell(Text('06-03-2025')),
                                  DataCell(Text('8')),
                                  DataCell(Text('Tradicional')),
                                  DataCell(Text('Español')),
                                  DataCell(Text('Finalizado')),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}

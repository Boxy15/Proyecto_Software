import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/RegistroConsumibles.dart';

/*void main() {
  runApp(const Consumibles());
}*/

class Consumibles extends StatelessWidget {
  const Consumibles({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ListaConsumibles(),
    );
  }
}

class ListaConsumibles extends StatefulWidget {
  const ListaConsumibles({super.key});

  @override
  _ListaConsumiblesState createState() => _ListaConsumiblesState();
}

class _ListaConsumiblesState extends State<ListaConsumibles> {
  final TextEditingController buscadorController = TextEditingController();
  List<dynamic> consumibles = [];
  List<dynamic> consumiblesFiltrados = [];
  List<String> proveedores = ['Todos'];
  String proveedorSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    obtenerConsumibles();
    obtenerProveedores();
    buscadorController.addListener(_filtrarConsumibles);
  }

  Future<void> obtenerConsumibles() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/getAllConsumibles'));
    if (response.statusCode == 200) {
      setState(() {
        consumibles = json.decode(response.body);
        consumiblesFiltrados = consumibles;
      });
    }
  }

  Future<void> obtenerProveedores() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/getProveedores'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        proveedores.addAll(data.map<String>((e) => e['nombre'].toString()));
      });
    }
  }

  void _filtrarConsumibles() {
    String query = buscadorController.text.toLowerCase();
    setState(() {
      consumiblesFiltrados = consumibles.where((item) {
        final nombre = item['nombre'].toString().toLowerCase();
        final proveedor = item['proveedor'].toString();
        final coincideBusqueda = nombre.contains(query);
        final coincideProveedor = proveedorSeleccionado == 'Todos' ||
            proveedor == proveedorSeleccionado;
        return coincideBusqueda && coincideProveedor;
      }).toList();
    });
  }

  void _filtrarPorProveedor(String? nuevoProveedor) {
    if (nuevoProveedor != null) {
      setState(() {
        proveedorSeleccionado = nuevoProveedor;
        _filtrarConsumibles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Menu()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Atras',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextField(
                      controller: buscadorController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar consumible...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Filtrar por Proveedor:',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        dropdownColor: const Color(0xFF022044),
                        value: proveedorSeleccionado,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        style: const TextStyle(color: Colors.white),
                        underline: Container(height: 2, color: Colors.white),
                        onChanged: _filtrarPorProveedor,
                        items: proveedores.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF0665A4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset('images/PICNITO LOGO.jpeg',
                          fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lista de Consumibles',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(color: Colors.grey),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  dataTextStyle: const TextStyle(color: Colors.white),
                  columns: const [
                    DataColumn(label: Text('CONSUMIBLE')),
                    DataColumn(label: Text('PROVEEDOR')),
                    DataColumn(label: Text('STOCK')),
                    DataColumn(label: Text('PRECIO UNITARIO')),
                    DataColumn(label: Text('OPCIONES')),
                  ],
                  rows: consumiblesFiltrados.map<DataRow>((consumible) {
                    return DataRow(
                      cells: [
                        DataCell(Text(consumible['nombre'] ?? '')),
                        DataCell(Text(consumible['proveedor'] ?? '')),
                        DataCell(Text(consumible['stock'].toString())),
                        DataCell(
                            Text(consumible['precio_unitario'].toString())),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("¿Eliminar consumible?"),
                                  content: Text(
                                      "Estás por eliminar '${consumible['nombre']}'"),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(false),
                                        child: const Text("Cancelar")),
                                    TextButton(
                                        onPressed: () => Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(true),
                                        child: const Text("Eliminar")),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final response = await http.delete(
                                  Uri.parse(
                                      'http://localhost:3000/deleteConsumible/${Uri.encodeComponent(consumible['nombre'])}'),
                                );
                                if (response.statusCode == 200) {
                                  setState(() {
                                    consumibles.removeWhere((c) =>
                                        c['nombre'] == consumible['nombre']);
                                    _filtrarConsumibles();
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('❌ No se pudo eliminar')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Registroconsumibles()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff14AE5C),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Color(0xffF5F5F5), size: 20),
                      SizedBox(width: 8),
                      Text('Nuevo Consumible',
                          style: TextStyle(
                              color: Color(0xffF5F5F5), fontSize: 14)),
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

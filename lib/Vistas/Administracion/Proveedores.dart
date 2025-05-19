import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Controlador/Administracion/proovedor_controller.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloProveedor.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/RegistroProveedores.dart';

void main() {
  runApp(const Proveedores());
}

class Proveedores extends StatelessWidget {
  const Proveedores({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ListaProveedores(),
    );
  }
}

class ListaProveedores extends StatefulWidget {
  const ListaProveedores({super.key});

  @override
  _ListaProveedoresState createState() => _ListaProveedoresState();
}

class _ListaProveedoresState extends State<ListaProveedores> {
  final TextEditingController buscadorController = TextEditingController();
  late ProveedorController proveedorController;

  List<Proveedor> proveedores = [];
  List<Proveedor> proveedoresFiltrados = [];

  @override
  void initState() {
    super.initState();
    proveedorController = ProveedorController(context);
    cargarProveedores();
  }

  Future<void> eliminarProveedor(String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar proveedor?'),
        content: const Text('Esta acción no se puede deshacer. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(216, 231, 54, 42)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await proveedorController.eliminarProveedor(nombre);
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Proveedor eliminado con éxito'),
              backgroundColor: Colors.green),
        );
        cargarProveedores(); // Actualiza la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('❌ No se pudo eliminar el proveedor'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> cargarProveedores() async {
    proveedores =
        (await proveedorController.fetchProveedores()).cast<Proveedor>();
    setState(() {
      proveedoresFiltrados = proveedores;
    });
  }

  void filtrarProveedores(String query) {
    setState(() {
      proveedoresFiltrados = proveedorController.filtrar(proveedores, query);
    });
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: buscadorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por Nombre...',
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
                        onChanged: filtrarProveedores,
                      ),
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
            const SizedBox(height: 10),
            const Text(
              'Lista de Proveedores',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(color: Colors.grey),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  dataTextStyle: const TextStyle(color: Colors.white),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Teléfono')),
                    DataColumn(label: Text('Correo')),
                    DataColumn(label: Text('Dirección')),
                    DataColumn(label: Text('RFC')),
                    DataColumn(label: Text('Opciones')),
                  ],
                  rows: proveedoresFiltrados.map((p) {
                    return DataRow(cells: [
                      DataCell(Text(p.nombre)),
                      DataCell(Text(p.telefono)),
                      DataCell(Text(p.correo)),
                      DataCell(Text(p.direccion)),
                      DataCell(Text(p.rfc)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              print("🧪 ID del proveedor a editar: ${p.id}");

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegistroProveedoresView(
                                      proveedorExistente: p),
                                ),
                              ).then((_) => cargarProveedores());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => eliminarProveedor(p.nombre),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistroProveedoresView(),
                        ),
                      ).then((_) => cargarProveedores());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff14AE5C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(EvaIcons.peopleOutline,
                            color: Color(0xffF5F5F5), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Nuevo Proveedor',
                          style:
                              TextStyle(color: Color(0xffF5F5F5), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

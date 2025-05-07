import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Controlador/Taquilla/GuardarMiembros.dart';
import 'package:proyecto_cine_equipo3/Vistas/Taquilla/FormularioMiembros.dart';
import 'package:proyecto_cine_equipo3/Vistas/Services/AlertDialog.dart';

class Miembros extends StatelessWidget {
  const Miembros({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ListaMiembros(),
    );
  }
}

class ListaMiembros extends StatefulWidget {
  const ListaMiembros({super.key});

  @override
  _ListaMiembrosState createState() => _ListaMiembrosState();
}

class _ListaMiembrosState extends State<ListaMiembros> {
  final TextEditingController buscadorController = TextEditingController();
  final MiembrosController miembrosController = MiembrosController();

  List<dynamic> miembros = [];
  List<dynamic> miembrosFiltrados = [];

  @override
  void initState() {
    super.initState();
    cargarMiembros();
  }

  Future<void> cargarMiembros() async {
    try {
      miembros = await miembrosController.obtenerMiembros();
      setState(() {
        miembrosFiltrados = miembros;
      });
    } catch (e) {
      print('Error al cargar miembros: $e');
    }
  }

  void filtrarMiembros(String query) {
    setState(() {
      miembrosFiltrados = miembrosController.filtrarMiembros(miembros, query);
    });
  }

  void _confirmarEliminar(BuildContext context, int id) {
    CustomDialog.mostrarConfirmacion(
      context: context,
      titulo: '¿Eliminar miembro?',
      mensaje: '¿Estás seguro de que deseas eliminar este miembro?',
      textoConfirmar: 'Eliminar',
      textoCancelar: 'Cancelar',
      onConfirmar: () async {
        try {
          await miembrosController.eliminarMiembro(id);
          cargarMiembros();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Miembro eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
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
                          Navigator.pop(context);
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
                  const Text(
                    'Miembros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: buscadorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre...',
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
                        onChanged: filtrarMiembros,
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
            const SizedBox(height: 20),
            Expanded(
              child: miembrosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay miembros registrados',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        border: TableBorder.all(color: Colors.grey),
                        headingTextStyle: const TextStyle(color: Colors.white),
                        dataTextStyle: const TextStyle(color: Colors.white),
                        columns: const <DataColumn>[
                          DataColumn(label: Text('NOMBRE')),
                          DataColumn(label: Text('APELLIDOS')),
                          DataColumn(label: Text('TELÉFONO')),
                          DataColumn(label: Text('DIRECCIÓN')),
                          DataColumn(label: Text('TIPO MEMBRESÍA')),
                          DataColumn(label: Text('INE')),
                          DataColumn(label: Text('ACCIONES')),
                        ],
                        rows: miembrosFiltrados.map<DataRow>((miembro) {
                          return DataRow(
                            cells: [
                              DataCell(Text(miembro['nombre'])),
                              DataCell(Text(miembro['apellido'])),
                              DataCell(Text(miembro['telefono'])),
                              DataCell(Text(miembro['direccion'])),
                              DataCell(Text(miembro['tipo_membresia'])),
                              DataCell(Text(miembro['ine'])),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FormularioMiembros(
                                                    miembro: miembro),
                                          ),
                                        ).then((value) {
                                          if (value == 'EDITADO') {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Miembro actualizado exitosamente'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            cargarMiembros();
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.white),
                                      onPressed: () {
                                        _confirmarEliminar(
                                            context, miembro['id_miembro']);
                                      },
                                    ),
                                  ],
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
                        builder: (context) => const FormularioMiembros(),
                      ),
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
                      Icon(Icons.person_add_alt_1_sharp,
                          color: Color(0xffF5F5F5), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Nuevos Miembros',
                        style:
                            TextStyle(color: Color(0xffF5F5F5), fontSize: 14),
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

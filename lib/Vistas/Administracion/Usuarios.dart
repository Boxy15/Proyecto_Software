import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Controlador/Administracion/user_controller.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloUsuarios.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/RegistrarUsuario.dart';

void main() {
  runApp(const Usuarios());
}

class Usuarios extends StatelessWidget {
  const Usuarios({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListaUsuarios(),
      ),
    );
  }
}

class ListaUsuarios extends StatefulWidget {
  const ListaUsuarios({super.key});

  @override
  _ListaUsuariosState createState() => _ListaUsuariosState();
}

class _ListaUsuariosState extends State<ListaUsuarios> {
  final UserController userController = UserController();
  final TextEditingController buscadorController = TextEditingController();
  List<User> usuarios = [];
  List<User> usuariosFiltrados = [];
  String dropdownValue = 'Todos';

  Future<void> fetchUsuarios() async {
    usuarios = await userController.fetchUsuarios(dropdownValue);
    setState(() {
      usuariosFiltrados = usuarios;
    });
  }

  void filtrarUsuarios(String query) {
    setState(() {
      usuariosFiltrados = userController.filtrarUsuarios(usuarios, query);
    });
  }

  void _confirmarEliminacion(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Estás seguro?"),
          content: const Text(
            "Esta acción eliminará el usuario de manera permanente.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool eliminado = await userController.eliminarUsuario(userId);
                if (eliminado) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario eliminado exitosamente'),
                      backgroundColor: Color(0xff14AE5C),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar usuario'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child:
                  const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  late Future<List<User>> futureUsuarios;

  @override
  void initState() {
    super.initState();
    futureUsuarios = userController.fetchUsuarios(dropdownValue);
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
                        onChanged: filtrarUsuarios,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Filtrar por Departamento:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        dropdownColor: const Color(0xFF022044),
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(height: 2, color: Colors.white),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              futureUsuarios =
                                  userController.fetchUsuarios(dropdownValue);
                            });
                          }
                        },
                        items: [
                          'Todos',
                          'Cafeteria',
                          'Limpieza',
                          'Dulceria',
                          'Taquilla'
                        ].map<DropdownMenuItem<String>>((String value) {
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
              'Lista de Usuarios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: futureUsuarios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error al cargar los usuarios'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay usuarios disponibles'));
                  }

                  final usuariosFiltrados = snapshot.data!
                      .where(
                          (usuario) => usuario.departamento != 'Administrador')
                      .toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(color: Colors.grey),
                      headingTextStyle: const TextStyle(color: Colors.white),
                      dataTextStyle: const TextStyle(color: Colors.white),
                      columns: const [
                        DataColumn(
                            label: SizedBox(
                                width: 200, child: Text('NOMBRE COMPLETO'))),
                        DataColumn(label: Text('DEPARTAMENTO')),
                        DataColumn(label: Text('TELÉFONO')),
                        DataColumn(label: Text('USUARIO')),
                        DataColumn(label: Text('FEC NACIMIENTO')),
                        DataColumn(label: Text('RFC')),
                        DataColumn(label: Text('OPCIONES')),
                      ],
                      rows: usuariosFiltrados.map((usuario) {
                        return DataRow(cells: [
                          DataCell(SizedBox(
                            width: 200,
                            child:
                                Text('${usuario.nombre} ${usuario.apellidos}'),
                          )),
                          DataCell(Text(usuario.departamento)),
                          DataCell(Text(usuario.telefono)),
                          DataCell(Text(usuario.usuario)),
                          DataCell(Text(userController
                              .formatearFecha(usuario.cumpleanos))),
                          DataCell(Text(usuario.rfc)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RegistroU(user: usuario),
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      futureUsuarios = userController
                                          .fetchUsuarios(dropdownValue);
                                    });
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                onPressed: () async {
                                  _confirmarEliminacion(usuario.id);
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  );
                },
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
                        builder: (context) => const RegistroU(),
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
                      Text('Nuevo Usuario',
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

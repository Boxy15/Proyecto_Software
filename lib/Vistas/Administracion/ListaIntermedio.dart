import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_cine_equipo3/Vistas/Administracion/RegistroIntermedios.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart'; // Asegúrate de importar la pantalla anterior

class ListaIntermedios extends StatefulWidget {
  const ListaIntermedios({super.key});

  @override
  State<ListaIntermedios> createState() => _ListaIntermediosState();
}

class _ListaIntermediosState extends State<ListaIntermedios> {
  late Future<List<Intermedio>> _intermedios;

  Future<List<Intermedio>> fetchIntermedios() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/getIntermedios'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Intermedio.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar intermedios');
    }
  }

  Future<void> eliminarIntermedio(int id) async {
    final res = await http
        .delete(Uri.parse('http://localhost:3000/deleteIntermedio/$id'));

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("✅ Intermedio eliminado con éxito"),
        backgroundColor: Colors.green,
      ));
      setState(() {
        _intermedios = fetchIntermedios();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("❌ No se pudo eliminar el intermedio"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _intermedios = fetchIntermedios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff01021E),
      appBar: AppBar(
        backgroundColor: const Color(0xff081C42),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Menu()),
            );
          },
        ),
        title: const Text(
          'Intermedios',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Intermedio>>(
        future: _intermedios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay intermedios'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final i = items[index];
              return Card(
                color: const Color(0xff081C42),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: (i.imagen != null && i.imagen!.startsWith('http'))
                      ? Image.network(i.imagen!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                  title: Text(i.nombre,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${i.cantidadProducida} ${i.unidad}',
                          style: const TextStyle(color: Colors.white70)),
                      Text('Costo: \$${i.costoTotalEstimado}',
                          style: const TextStyle(color: Colors.white70)),
                      Text(
                        'Consumibles: ${i.consumibles.map((c) => "${c.nombre} (${c.cantidadUsada})").join(", ")}',
                        style: const TextStyle(color: Colors.white60),
                      )
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('¿Eliminar Intermedio?'),
                          content: const Text(
                              'Esta acción no se puede deshacer. ¿Estás seguro?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        eliminarIntermedio(i.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Registrointermedios()),
          );
        },
        backgroundColor: const Color(0xff14AE5C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

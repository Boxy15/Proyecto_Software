import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Controlador/Taquilla/GuardarMiembros.dart';

void main() {
  runApp(const RMiembros());
}

class RMiembros extends StatelessWidget {
  const RMiembros({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FormularioMiembros(),
      ),
    );
  }
}

class FormularioMiembros extends StatefulWidget {
  final Map<String, dynamic>? miembro;

  const FormularioMiembros({super.key, this.miembro});

  @override
  _FormularioMiembrosState createState() => _FormularioMiembrosState();
}

class _FormularioMiembrosState extends State<FormularioMiembros> {
  final nombreController = TextEditingController(); // Nombre
  final apellidoController = TextEditingController(); // Apellidos
  final telefonoController = TextEditingController(); // Teléfono
  final direccionController = TextEditingController(); // Dirección
  final ineController = TextEditingController(); // INE

  final MiembrosController miembrosController = MiembrosController();

  String? selectedMembresia; 

  @override
  void initState() {
    super.initState();
    if (widget.miembro != null) {
      nombreController.text = widget.miembro!['nombre'] ?? '';
      apellidoController.text = widget.miembro!['apellido'] ?? '';
      telefonoController.text = widget.miembro!['telefono'] ?? '';
      direccionController.text = widget.miembro!['direccion'] ?? '';
      ineController.text = widget.miembro!['ine'] ?? '';
      selectedMembresia = widget.miembro!['tipo_membresia'];
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
                  'Registrar Miembros',
                  style: TextStyle(
                    color: Color(0xffF5F5F5),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
                  child: Column(
                    children: [
                      Row(
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
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    size: 30),
                              ),
                              const Text(
                                'Atras',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nombre',
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
                                  cursorColor: const Color(0xff000000),
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff000000)),
                                  controller: nombreController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(left: 10, bottom: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              const Text(
                                'Apellido(s)',
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
                                  cursorColor: const Color(0xff000000),
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff000000)),
                                  controller: apellidoController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(left: 10, bottom: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              const Text(
                                'Tipo Membresia',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 250,
                                height: 35,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedMembresia,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  hint: const Text(
                                    'Seleccione',
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xff000000)),
                                  ),
                                  items: ['3%', '5%', '7%'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff000000)),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedMembresia = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 70),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Telefono',
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
                                  cursorColor: const Color(0xff000000),
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff000000)),
                                  controller: telefonoController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(left: 10, bottom: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              const Text(
                                'Direccion',
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
                                  cursorColor: const Color(0xff000000),
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff000000)),
                                  controller: direccionController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(left: 10, bottom: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              const Text(
                                'INE',
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
                                  cursorColor: const Color(0xff000000),
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff000000)),
                                  controller: ineController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(left: 10, bottom: 10),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        height: 40,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (widget.miembro == null) {
                              // Si es nuevo miembro (insertar)
                              final resultado =
                                  await miembrosController.guardarMiembro(
                                context: context,
                                nombre: nombreController.text,
                                apellido: apellidoController.text,
                                telefono: telefonoController.text,
                                direccion: direccionController.text,
                                ine: ineController.text,
                                tipoMembresia: selectedMembresia ?? '',
                              );

                              if (resultado == 'OK') {
                                Navigator.pop(context);
                              }
                            } else {
                              // Si es miembro existente (actualizar)
                              final resultado =
                                  await miembrosController.actualizarMiembro(
                                context: context,
                                id: widget.miembro![
                                    'id_miembro'],
                                nombre: nombreController.text,
                                apellido: apellidoController.text,
                                telefono: telefonoController.text,
                                direccion: direccionController.text,
                                ine: ineController.text,
                                tipoMembresia: selectedMembresia ?? '',
                              );

                              if (resultado == 'OK') {
                                Navigator.pop(context, 'EDITADO');

                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: const Color(0xff14AE5C),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(color: Color(0xffF5F5F5)),
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

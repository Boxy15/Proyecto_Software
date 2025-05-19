import 'package:flutter/material.dart';

import 'package:proyecto_cine_equipo3/Controlador/Administracion/proovedor_controller.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloProveedor.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Proveedores.dart';

/*void main() {
  runApp(const Rproveedores());
}*/

class RegistroProveedoresView extends StatefulWidget {
  final Proveedor? proveedorExistente;

const RegistroProveedoresView({super.key, this.proveedorExistente});


  @override
  _RegistroProveedoresViewState createState() =>
      _RegistroProveedoresViewState();
}

class _RegistroProveedoresViewState extends State<RegistroProveedoresView> {
  final correoController = TextEditingController();
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final direccionController = TextEditingController();
  final rfcController = TextEditingController();

  late final ProveedorController _proveedorController;

  @override
  void initState() {
    super.initState();
    _proveedorController = ProveedorController(context);
    // print("🧪 ID del proveedor a editar: ${widget.proveedorExistente?.id}");

    if (widget.proveedorExistente != null) {
      final p = widget.proveedorExistente!;
      correoController.text = p.correo;
      nombreController.text = p.nombre;
      telefonoController.text = p.telefono;
      direccionController.text = p.direccion;
      rfcController.text = p.rfc;
    }
  }

  void _guardarProveedor() async {
    final proveedor = Proveedor(
      id: widget.proveedorExistente?.id,
      nombre: nombreController.text,
      correo: correoController.text,
      telefono: telefonoController.text,
      direccion: direccionController.text,
      rfc: rfcController.text,
    );

    bool exito = false;

    if (widget.proveedorExistente != null) {
      exito = await _proveedorController.actualizarProveedor(proveedor);
    } else {
      exito = await _proveedorController.guardarProveedor(proveedor);
    }

    if (exito) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Proveedor guardado correctamente')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Proveedores()),
        );
      }
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
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                    child: Text(
                  widget.proveedorExistente != null
                      ? 'Editar Proveedor'
                      : 'Registro de Proveedores',
                  style: const TextStyle(
                    color: Color(0xffF5F5F5),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ))),
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
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Proveedores()),
                                      ); //HomeScreen
                                    },
                                    icon: const Icon(Icons.arrow_back,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        size: 30),
                                  ),
                                  const Text(
                                    'Atras',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 30),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Correo',
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
                                          fontSize: 14,
                                          color: Color(0xff000000)),
                                      controller: correoController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
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
                                          fontSize: 14,
                                          color: Color(0xff000000)),
                                      controller: nombreController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                  const Text(
                                    'RFC',
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
                                          fontSize: 14,
                                          color: Color(0xff000000)),
                                      controller: rfcController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 70),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                          fontSize: 14,
                                          color: Color(0xff000000)),
                                      controller: direccionController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
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
                                          fontSize: 14,
                                          color: Color(0xff000000)),
                                      controller: telefonoController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: SizedBox(
                          height: 40,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _guardarProveedor,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text(
                              'Guardar Proveedor',
                              style: TextStyle(color: Color(0xffF5F5F5)),
                            ),
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

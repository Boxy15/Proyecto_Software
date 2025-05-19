import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart'; // Importar el paquete
import 'package:proyecto_cine_equipo3/Vistas/Administracion/InicioSesion.dart'; // Importar la pantalla de inicio

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1200, 712); // Tamaño inicial de la ventana
    appWindow.size = initialSize;
    appWindow.title = "(BTS) Bite Technology System"; // Cambiar el nombre de la ventana
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: "BTS",
      debugShowCheckedModeBanner: false,
      home: const InicioSesion(), // Inicia en la pantalla de inicio
    );
  }
}
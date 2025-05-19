import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() {
  runApp(const AFunciones());
}

class AFunciones extends StatelessWidget {
  const AFunciones({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Funciones(),
      
    );
  }
}

class Funciones extends StatefulWidget {
  const Funciones({super.key});

  @override
  _FuncionesState createState() => _FuncionesState();
}

class _FuncionesState extends State<Funciones> {
  final tituloController = TextEditingController();
  final horarioController = TextEditingController();
  final salaController = TextEditingController();
  final fechaController = TextEditingController();
  final tipoController = TextEditingController();
  final idiomaController = TextEditingController();
  final buscadorController = TextEditingController();
  File? _imagen;
  String dropdownValue = 'Tradicional';
  String dropdownValue2 = '1';
  String dropdownValue3 = 'Español';
  String convertirHorario(String horario) {
    final RegExp regex = RegExp(r'(\d+)h\s*(\d+)m'); // Extrae "10h 30m"
    final match = regex.firstMatch(horario);

    if (match != null) {
      final horas = match.group(1) ?? "0";
      final minutos = match.group(2) ?? "0";
      return "${horas.padLeft(2, '0')}:${minutos.padLeft(2, '0')}:00"; // HH:mm:ss
    }

    return "00:00:00"; // En caso de error
    //Atras
  }

  Future<void> guardarFuncion() async {
    final titulo = tituloController.text.trim();
    final horario = convertirHorario(horarioController.text.trim());
    final fecha = fechaController.text.trim();
    final sala = dropdownValue2;
    final tipoSala = dropdownValue;
    final idioma = dropdownValue3;
    final poster = _imagen?.path ?? "";

    if ([titulo, horario, fecha, sala, tipoSala, idioma]
        .any((element) => element.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Todos los campos son obligatorios"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, String> functionData = {
      'titulo': titulo,
      'horario': horario,
      'fecha': fecha,
      'sala': sala,
      'tipo_sala': tipoSala,
      'idioma': idioma,
      'poster': poster,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/admin/addFunction'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(functionData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Función guardada con éxito"),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const Funciones(), // 🔄 Redirige a Funciones.dart
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar función: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de conexión: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _seleccionarHorario() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      confirmText: "Aceptar",
      cancelText: "Cancelar",
      helpText: "Seleccionar horario",
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xff14AE5C), // Verde
              onPrimary: Colors.white,
              surface: Color(0xFF022044), // Fondo dialog
              onSurface: Colors.white,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF022044),
              hourMinuteTextColor: Colors.white,
              dialHandColor: Color(0xff14AE5C),
              dialBackgroundColor: Color(0xFF0D1B3D),
              entryModeIconColor: Color(0xff14AE5C),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(const Color(0xff14AE5C)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        horarioController.text = '${picked.hour}h ${picked.minute}m';
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      confirmText: "Aceptar",
      cancelText: "Cancelar",
      helpText: "Seleccionar fecha",
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xff14AE5C),
              onPrimary: Colors.white,
              surface: Color(0xFF022044),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(const Color(0xff14AE5C)),
              ),
            ),
            dialogTheme: const DialogTheme(backgroundColor: Color(0xFF022044)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
                    'Añadir Funcion',
                    style: TextStyle(
                      color: Color(0xffF5F5F5),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
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
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
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
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: TextField(
                                    controller: buscadorController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Buscar Pelicula',
                                      hintStyle: const TextStyle(
                                          color: Colors.white70),
                                      prefixIcon: const Icon(Icons.search,
                                          color: Colors.white),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.2),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (String value) {},
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
                          const SizedBox(height: 75),
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Poster',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    _imagen == null
                                        ? Container(
                                            width: 150,
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image,
                                                size: 100, color: Colors.grey),
                                          )
                                        : Image.file(
                                            _imagen!,
                                            width: 150,
                                            height: 200,
                                            fit: BoxFit.contain,
                                          ),
                                  ],
                                ),
                                const SizedBox(width: 30),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Titulo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 200,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        controller: tituloController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Asigne un horario',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 200,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        controller: horarioController,
                                        readOnly: true,
                                        onTap: _seleccionarHorario,
                                        decoration: const InputDecoration(
                                          hintText: 'Seleccione un horario',
                                          hintStyle: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          prefixIcon: Icon(Icons.access_time),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Tipo de Sala',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      width: 200,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButton<String>(
                                        underline: Container(
                                          color: Colors.transparent,
                                        ),
                                        dropdownColor: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        value: dropdownValue,
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.black),
                                        iconSize: 24,
                                        //elevation: 16,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            dropdownValue = newValue!;
                                          });
                                        },
                                        items: <String>[
                                          'Tradicional',
                                          '3D',
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 30),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Seleccione una Sala',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      width: 200,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButton<String>(
                                        underline: Container(
                                          color: Colors.transparent,
                                        ),
                                        dropdownColor: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        value: dropdownValue2,
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.black),
                                        iconSize: 24,
                                        //elevation: 16,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            dropdownValue2 = newValue!;
                                          });
                                        },
                                        items: <String>[
                                          '1',
                                          '2',
                                          '3',
                                          '4',
                                          '5',
                                          '6',
                                          '7',
                                          '8',
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Asigne una Fecha',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 200,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        controller: fechaController,
                                        readOnly: true,
                                        onTap: _seleccionarFecha,
                                        decoration: const InputDecoration(
                                          hintText: 'Seleccione una fecha',
                                          hintStyle: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          prefixIcon: Icon(Icons.date_range),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Seleccione Idioma',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      width: 200,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButton<String>(
                                        underline: Container(
                                          color: Colors.transparent,
                                        ),
                                        dropdownColor: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        value: dropdownValue3,
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.black),
                                        iconSize: 24,
                                        //elevation: 16,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            dropdownValue3 = newValue!;
                                          });
                                        },
                                        items: <String>[
                                          'Español',
                                          'Ingles',
                                          'Frances',
                                          'Japon',
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    /*const SizedBox(height: 20),
                                    Container(
                                      height: 40,
                                      width: 200,
                                      child: ElevatedButton(
                                        onPressed: guardarFuncion,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          backgroundColor: const Color(0xff14AE5C),
                                        ),
                                        child: const Text(
                                          'Guardar Función',
                                          style: TextStyle(color: Color(0xffF5F5F5)),
                                        ),
                                      ),
                                    ),*/
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: SizedBox(
                          height: 40,
                          width: 250,
                          child: ElevatedButton(
                            onPressed: guardarFuncion,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text(
                              'Guardar Funcion',
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

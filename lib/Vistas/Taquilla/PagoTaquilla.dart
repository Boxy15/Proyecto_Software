import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Controlador/Taquilla/Proceso.dart';
import 'package:proyecto_cine_equipo3/Vistas/Taquilla/TicketCompra.dart';

class STaquilla extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String horario;
  final String sala;
  final String boletos;
  final String asientos;
  final String poster;
  final double total;

  const STaquilla({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.horario,
    required this.sala,
    required this.boletos,
    required this.asientos,
    required this.poster,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VentanaPagos(
        titulo: titulo,
        fecha: fecha,
        horario: horario,
        sala: sala,
        boletos: boletos,
        asientos: asientos,
        poster: poster,
        total: total,
      ),
    );
  }
}

class VentanaPagos extends StatefulWidget {
  final String titulo;
  final String fecha;
  final String horario;
  final String sala;
  final String boletos;
  final String asientos;
  final String poster;
  final double total;

  const VentanaPagos({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.horario,
    required this.sala,
    required this.boletos,
    required this.asientos,
    required this.poster,
    required this.total,
  });

  @override
  _VentanaPagosState createState() => _VentanaPagosState();
}

class _VentanaPagosState extends State<VentanaPagos> {
  final PagoController pagoController = PagoController();

  bool esMiembro = false;
  bool usarCashback = false;
  int? idMiembroEncontrado;
  String nombreCliente = '';

  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController cashbackController = TextEditingController();
  final TextEditingController montoRecibidoController = TextEditingController();
  final TextEditingController cambioController = TextEditingController();

  double totalCompra = 0.0;
  double totalConDescuento = 0.0;
  String tipoMembresia = '';

  void calcularCambioEnPantalla() {
    double montoRecibido = double.tryParse(montoRecibidoController.text) ?? 0.0;

    if (montoRecibido >= totalConDescuento) {
      double cambio = pagoController.calcularCambio(
        montoRecibido: montoRecibido,
        total: totalConDescuento,
      );
      setState(() {
        cambioController.text = cambio.toStringAsFixed(2);
      });
    } else {
      setState(() {
        cambioController.text = '';
      });
    }
  }

  double calcularNuevoCashback() {
    double porcentaje = 0.0;
    if (tipoMembresia == '3%') porcentaje = 0.03;
    if (tipoMembresia == '5%') porcentaje = 0.05;
    if (tipoMembresia == '7%') porcentaje = 0.07;
    return totalCompra * porcentaje;
  }

  @override
  void initState() {
    super.initState();
    totalCompra = widget.total;
    totalConDescuento = totalCompra;
  }

  Future<void> buscarMiembro() async {
    if (!esMiembro) return;

    if (telefonoController.text.length >= 8) {
      try {
        final miembro = await pagoController
            .buscarMiembroPorTelefono(telefonoController.text);

        if (miembro != null) {
          idMiembroEncontrado = miembro['id_miembro'];
          nombreCliente = miembro['nombre'];
          tipoMembresia = miembro['tipo_membresia'];

          double cashbackActualCompra =
              pagoController.calcularCashback(totalCompra, tipoMembresia);
          double cashbackAcumulado =
              double.tryParse(miembro['cashback_acumulado'].toString()) ?? 0.0;

          cashbackController.text =
              (cashbackActualCompra + cashbackAcumulado).toStringAsFixed(2);

          setState(() {
            usarCashback = false;
          });
        } else {
          tipoMembresia = '';
          cashbackController.clear();
          setState(() {
            usarCashback = false;
            totalConDescuento = totalCompra;
          });
        }
      } catch (e) {
        tipoMembresia = '';
        cashbackController.clear();
        setState(() {
          usarCashback = false;
          totalConDescuento = totalCompra;
        });
      }
    }
  }

  void actualizarTotal() {
    if (usarCashback && cashbackController.text.isNotEmpty) {
      double cashback = double.parse(cashbackController.text);
      setState(() {
        totalConDescuento = totalCompra - cashback;
      });
    } else {
      setState(() {
        totalConDescuento = totalCompra;
      });
    }
  }

  Widget TarjetaPelicula(
    String titulo,
    String fecha,
    String horario,
    String sala,
    String boletos,
    String asientos,
  ) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(
        vertical: 10, /*horizontal: 4*/
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black12,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: widget.poster.startsWith('data:image')
                    ? Image.memory(
                        const Base64Decoder().convert(
                          widget.poster.split(',').last,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 40);
                        },
                      )
                    : Image.asset(
                        'assets/placeholder.jpg',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Fecha: $fecha',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Hora: $horario',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Sala: $sala',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Boletos: $boletos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Asientos: $asientos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget SecciondePago() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: esMiembro,
                    onChanged: (bool? value) {
                      setState(() {
                        esMiembro = value!;
                        if (!esMiembro) {
                          telefonoController.clear();
                          cashbackController.clear();
                          usarCashback = false;
                          totalConDescuento = totalCompra;
                        }
                      });
                    },
                  ),
                  const Text(
                    'Miembros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              if (esMiembro) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: telefonoController,
                  onChanged: (value) {
                    buscarMiembro();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cashbackController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Cashback Disponible',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: usarCashback,
                      onChanged: (bool? value) {
                        setState(() {
                          usarCashback = value!;
                          actualizarTotal();
                        });
                      },
                    ),
                    const Text(
                      'Usar Cashback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Total: \$${totalConDescuento.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: montoRecibidoController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  calcularCambioEnPantalla();
                },
                decoration: const InputDecoration(
                  labelText: 'Monto Recibido',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cambioController,
                decoration: const InputDecoration(
                  labelText: 'Cambio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    double montoRecibido =
                        double.tryParse(montoRecibidoController.text) ?? 0.0;

                    if (montoRecibido < totalConDescuento) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'El monto recibido no puede ser menor al total a pagar.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // Registrar el pago primero
                      await pagoController.registrarPago(
                        idMiembro: esMiembro ? idMiembroEncontrado : null,
                        nombreCliente:
                            esMiembro ? nombreCliente : 'Cliente General',
                        montoTotal: totalConDescuento,
                        montoRecibido: montoRecibido,
                        cambio: montoRecibido - totalConDescuento,
                        tipoPago: 'Efectivo',
                        cashbackGenerado:
                            usarCashback ? 0.0 : calcularNuevoCashback(),
                      );

                      // Actualizar los asientos vendidos
                      final AsientosController asientosController =
                          AsientosController();
                      await asientosController.actualizarAsientosVendidos(
                        fecha: widget.fecha,
                        horario: widget.horario,
                        sala: widget.sala,
                        nuevosAsientos: widget.asientos,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pago registrado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return TicketCompra(
                            titulo: widget.titulo,
                            fecha: widget.fecha,
                            horario: widget.horario,
                            sala: widget.sala,
                            boletos: widget.boletos,
                            asientos: widget.asientos,
                            total: totalConDescuento,
                          );
                        },
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al registrar el pago: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0665A4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Pagar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget TextFields(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF022044), Color(0xFF01021E)],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Atras',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Pago',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 900,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff081C42),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TarjetaPelicula(
                                  widget.titulo,
                                  widget.fecha,
                                  widget.horario,
                                  widget.sala,
                                  widget.boletos,
                                  widget.asientos,
                                ),
                                const SizedBox(height: 20),
                                SecciondePago(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

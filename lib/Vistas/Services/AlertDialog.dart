import 'package:flutter/material.dart';

class CustomDialog {
  static Future<void> mostrarConfirmacion({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    required VoidCallback onConfirmar,
    VoidCallback? onCancelar,
    String textoConfirmar = 'Confirmar',
    String textoCancelar = 'Cancelar',
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF022044), // Fondo azul oscuro
          title: Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            mensaje,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              onPressed: onCancelar ??
                  () {
                    Navigator.of(context).pop();
                  },
              child: Text(textoCancelar),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff14AE5C), // Verde para confirmar
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cerramos el diálogo
                onConfirmar();
              },
              child: Text(textoConfirmar),
            ),
          ],
        );
      },
    );
  }
}

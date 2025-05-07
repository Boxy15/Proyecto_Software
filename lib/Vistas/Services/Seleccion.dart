import 'package:flutter/material.dart';

class Seleccion extends StatefulWidget {
  final List<String> items;
  final String? titulo;

  const Seleccion({
    super.key,
    required this.items,
    required this.titulo,
  });

  @override
  _SeleccionState createState() => _SeleccionState();
}

class _SeleccionState extends State<Seleccion> {
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.items.isNotEmpty ? widget.items[0] : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF022044),
      title: Text(
        widget.titulo!,
        style: const TextStyle(color: Color(0xffffffff)),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            return RadioListTile<String>(
              activeColor: const Color(0xFF4CAF50),
              value: item,
              groupValue: _selectedItem,
              title: Text(
                item,
                style: const TextStyle(color: Color(0xffffffff)),
              ),
              onChanged: (String? value) {
                setState(() {
                  _selectedItem = value;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              fillColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4CAF50);
                  }
                  return Colors.white;
                },
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
              side: WidgetStateProperty.all(
                  const BorderSide(color: Color(0xffBC0D06)))),
          child: const Text('Cancelar',
              style: TextStyle(color: Color(0xffBC0D06))),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedItem);
          },
          style: ButtonStyle(
              side: WidgetStateProperty.all(
                  const BorderSide(color: Color(0xff14AE5C)))),
          child:
              const Text('Aceptar', style: TextStyle(color: Color(0xff14AE5C))),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;
  final String? titulo;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.initialSelectedItems,
    required this.titulo,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
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
            return CheckboxListTile(
              activeColor: const Color(0xFF4CAF50),
              checkColor: Colors.white,
              side: WidgetStateBorderSide.resolveWith(
                  (states) => BorderSide(width: 1.0, color: Colors.grey[400]!)),
              value: _selectedItems.contains(item),
              title: Text(
                item,
                style: const TextStyle(color: Color(0xffffffff)),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _selectedItems.add(item);
                  } else {
                    _selectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.initialSelectedItems);
          },
          style: ButtonStyle(
              side: WidgetStateProperty.all(
                  const BorderSide(color: Color(0xffBC0D06)))),
          child: const Text('Cancelar',
              style: TextStyle(color: Color(0xffBC0D06))),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedItems);
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

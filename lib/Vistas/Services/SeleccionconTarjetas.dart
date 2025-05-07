import 'package:flutter/material.dart';

class MultiSelectCardDialog extends StatefulWidget {
  final List<Map<String, String>> items;
  final List<Map<String, String>> initialSelectedItems;
  final String? titulo;

  const MultiSelectCardDialog({
    super.key,
    required this.items,
    required this.initialSelectedItems,
    required this.titulo,
  });

  @override
  _MultiSelectCardDialogState createState() => _MultiSelectCardDialogState();
}

class _MultiSelectCardDialogState extends State<MultiSelectCardDialog> {
  late List<Map<String, String>> _selectedItems;

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
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 800,
        height: 350,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.5,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isSelected = _selectedItems.contains(item);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedItems.remove(item);
                  } else {
                    _selectedItems.add(item);
                  }
                });
              },
              child: Card(
                color: isSelected
                    ? const Color(0xFF4CAF50).withOpacity(0.5)
                    : const Color(0xFF0D1B3D),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      item["imagen"]!,
                      fit: BoxFit.contain,
                      height: 100,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item["nombre"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Precio: \$${item["precio"]!}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Stock: ${item["stock"]!}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.initialSelectedItems);
          },
          style: ButtonStyle(
            side: WidgetStateProperty.all(
              const BorderSide(color: Color(0xffBC0D06)),
            ),
          ),
          child: const Text('Cancelar',
              style: TextStyle(color: Color(0xffBC0D06))),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedItems);
          },
          style: ButtonStyle(
            side: WidgetStateProperty.all(
              const BorderSide(color: Color(0xff14AE5C)),
            ),
          ),
          child:
              const Text('Aceptar', style: TextStyle(color: Color(0xff14AE5C))),
        ),
      ],
    );
  }
}

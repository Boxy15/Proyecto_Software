import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Vistas/Cafeteria/PagoCafeteria.dart';
import 'package:proyecto_cine_equipo3/Vistas/Cafeteria/MenuCafeteria.dart';
import 'package:proyecto_cine_equipo3/Vistas/Cafeteria/ReportesCafeteria.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MenuCafeteria2(),
  ));
}

class MenuCafeteria2 extends StatefulWidget {
  const MenuCafeteria2({super.key});

  @override
  State<MenuCafeteria2> createState() => _MenuCafeteriaState();
}

class _MenuCafeteriaState extends State<MenuCafeteria2> {
  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF022044), Color(0xFF01021E)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 180,
              margin: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 60),
              decoration: BoxDecoration(
                color: const Color(0xFF081C42),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(top: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'images/PICNITO LOGO.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SidebarButton(
                    icon: Icons.local_cafe,
                    label: 'Tienda Cafetería',
                    onTap: () => _navigateTo(const MenuCafeteria()),
                  ),
                  _SidebarButton(
                    icon: Icons.bar_chart,
                    label: 'Reportes',
                    onTap: () => _navigateTo(const ReportesCafe()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 30, top: 50, bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bienvenido al módulo de Cafetería',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'images/PICNITO LOGO.jpeg',
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

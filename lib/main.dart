import 'package:flutter/material.dart';

import 'taller1/home_page.dart';
import 'taller3/screens/future_page.dart';
import 'taller3/screens/isolate_page.dart';
import 'taller3/screens/timer_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electiva Profesional I',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const MenuPage(),
    );
  }
}

/// Pantalla de inicio: enlaza el Taller 1 y las 3 pantallas del Taller 3.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _abrir(BuildContext context, Widget pagina) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú principal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Taller 3 – Segundo plano y asincronía',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _Opcion(
            icono: Icons.cloud_download,
            titulo: '1. Future / async / await',
            subtitulo: 'Consulta simulada: Cargando → Éxito / Error',
            onTap: () => _abrir(context, const FuturePage()),
          ),
          _Opcion(
            icono: Icons.timer,
            titulo: '2. Cronómetro (Timer)',
            subtitulo: 'Iniciar / Pausar / Reanudar / Reiniciar',
            onTap: () => _abrir(context, const TimerPage()),
          ),
          _Opcion(
            icono: Icons.memory,
            titulo: '3. Tarea pesada (Isolate)',
            subtitulo: 'Cálculo CPU-bound sin bloquear la UI',
            onTap: () => _abrir(context, const IsolatePage()),
          ),
          const Divider(height: 32),
          const Text(
            'Talleres anteriores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _Opcion(
            icono: Icons.widgets,
            titulo: 'Taller 1 – Widgets y setState',
            subtitulo: 'StatefulWidget, SnackBar, ListView',
            onTap: () => _abrir(context, const HomePage()),
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

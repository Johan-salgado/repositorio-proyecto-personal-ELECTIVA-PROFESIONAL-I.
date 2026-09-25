import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taller 1',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _cambiado = false;

  // Variable de estado: controla el título de la AppBar
  String get _titulo => _cambiado ? '¡Título cambiado!' : 'Hola, Flutter';

  void _cambiarTitulo() {
    setState(() {
      _cambiado = !_cambiado;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Título actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulo)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nombre completo del estudiante, centrado
              const Center(
                child: Text(
                  'JOHAN ELIU SALGADO CASTRO',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Row con Image.network() + Image.asset()
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Image.network(
                      'https://picsum.photos/200/150',
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón obligatorio: alterna título + SnackBar con setState()
              ElevatedButton(
                onPressed: _cambiarTitulo,
                child: const Text('Cambiar título'),
              ),
              const SizedBox(height: 24),

              // Widget adicional 1: Container (bordes/colores/márgenes)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Este texto está dentro de un Container con borde y color de fondo.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Widget adicional 2: ListView (lista simple con icono y texto)
              SizedBox(
                height: 200,
                child: ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.phone_android),
                      title: Text('Programación Móvil'),
                    ),
                    ListTile(
                      leading: Icon(Icons.code),
                      title: Text('Flutter y Dart'),
                    ),
                    ListTile(
                      leading: Icon(Icons.merge_type),
                      title: Text('Git Flow'),
                    ),
                    ListTile(
                      leading: Icon(Icons.school),
                      title: Text('UCEVA'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
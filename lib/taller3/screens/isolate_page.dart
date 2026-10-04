import 'package:flutter/material.dart';

import '../services/heavy_task.dart';

class IsolatePage extends StatefulWidget {
  const IsolatePage({super.key});

  @override
  State<IsolatePage> createState() => _IsolatePageState();
}

class _IsolatePageState extends State<IsolatePage> {
  int _n = 500000000; // 500 millones de iteraciones
  bool _ocupado = false;
  final List<String> _log = [];

  void _registrar(String linea) {
    debugPrint(linea);
    if (mounted) setState(() => _log.add(linea));
  }

  /// Tarea pesada en un Isolate: la UI (indicador de progreso) sigue fluida.
  Future<void> _conIsolate() async {
    setState(() {
      _log.clear();
      _ocupado = true;
    });
    final reloj = Stopwatch()..start();
    _registrar('[Main] Lanzando Isolate (n = $_n)...');

    try {
      final resultado = await sumaGrandeEnIsolate(_n);
      reloj.stop();
      _registrar('[Main] Resultado recibido: $resultado');
      _registrar('[Main] Tiempo con Isolate: ${reloj.elapsedMilliseconds} ms');
    } catch (e) {
      _registrar('[Main] Error: $e');
    }
    if (mounted) setState(() => _ocupado = false);
  }

  /// Misma tarea en el hilo principal: la UI se congela mientras dura.
  Future<void> _sinIsolate() async {
    setState(() {
      _log.clear();
      _ocupado = true;
    });
    _registrar('[Main] Calculando en el hilo principal (la UI se congelará)');
    // Deja que Flutter pinte el estado "ocupado" antes de bloquear el hilo.
    await Future.delayed(const Duration(milliseconds: 300));

    final reloj = Stopwatch()..start();
    final resultado = sumaGrande(_n);
    reloj.stop();

    _registrar('[Main] Resultado: $resultado');
    _registrar('[Main] Tiempo sin Isolate: ${reloj.elapsedMilliseconds} ms');
    if (mounted) setState(() => _ocupado = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarea pesada (Isolate)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Suma grande (CPU-bound). Elige el tamaño del cálculo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 100000000, label: Text('100 M')),
                ButtonSegment(value: 500000000, label: Text('500 M')),
                ButtonSegment(value: 1000000000, label: Text('1000 M')),
              ],
              selected: {_n},
              onSelectionChanged:
                  _ocupado ? null : (s) => setState(() => _n = s.first),
            ),
            const SizedBox(height: 16),
            // Si este indicador se mueve, la UI NO está bloqueada.
            SizedBox(
              height: 6,
              child: _ocupado ? const LinearProgressIndicator() : null,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _ocupado ? null : _conIsolate,
              icon: const Icon(Icons.memory),
              label: const Text('Ejecutar con Isolate'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _ocupado ? null : _sinIsolate,
              icon: const Icon(Icons.warning_amber),
              label: const Text('Ejecutar sin Isolate (congela la UI)'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mensajes (también en consola):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(children: [for (final l in _log) Text(l)]),
            ),
          ],
        ),
      ),
    );
  }
}

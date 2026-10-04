import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

enum EstadoCronometro { detenido, corriendo, pausado }

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  // El Stopwatch mide el tiempo real (no acumula errores);
  // el Timer solo se usa para refrescar la pantalla cada 100 ms.
  final Stopwatch _reloj = Stopwatch();
  Timer? _timer;
  EstadoCronometro _estado = EstadoCronometro.detenido;

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {}); // redibuja con el tiempo transcurrido
    });
  }

  void _iniciar() {
    _reloj.start();
    _iniciarTimer();
    setState(() => _estado = EstadoCronometro.corriendo);
  }

  void _pausar() {
    _timer?.cancel(); // se cancela el Timer al pausar
    _reloj.stop();
    setState(() => _estado = EstadoCronometro.pausado);
  }

  void _reanudar() => _iniciar();

  void _reiniciar() {
    _timer?.cancel();
    _reloj
      ..stop()
      ..reset();
    setState(() => _estado = EstadoCronometro.detenido);
  }

  @override
  void dispose() {
    _timer?.cancel(); // limpieza de recursos al salir de la vista
    super.dispose();
  }

  String _formato(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seg = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final dec = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$min:$seg.$dec';
  }

  @override
  Widget build(BuildContext context) {
    final corriendo = _estado == EstadoCronometro.corriendo;
    final pausado = _estado == EstadoCronometro.pausado;
    final detenido = _estado == EstadoCronometro.detenido;

    return Scaffold(
      appBar: AppBar(title: const Text('Cronómetro (Timer)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formato(_reloj.elapsed),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Estado: ${_estado.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: detenido ? _iniciar : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar'),
                ),
                FilledButton.icon(
                  onPressed: corriendo ? _pausar : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pausar'),
                ),
                FilledButton.icon(
                  onPressed: pausado ? _reanudar : null,
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Reanudar'),
                ),
                OutlinedButton.icon(
                  onPressed: detenido ? null : _reiniciar,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reiniciar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

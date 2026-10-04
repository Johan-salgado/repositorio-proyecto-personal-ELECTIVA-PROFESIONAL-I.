import 'package:flutter/material.dart';

import '../services/datos_service.dart';

enum EstadoCarga { inicial, cargando, exito, error }

class FuturePage extends StatefulWidget {
  const FuturePage({super.key});

  @override
  State<FuturePage> createState() => _FuturePageState();
}

class _FuturePageState extends State<FuturePage> {
  final _servicio = const DatosService();

  EstadoCarga _estado = EstadoCarga.inicial;
  String _mensaje = 'Presiona un botón para consultar los datos.';
  final List<String> _log = [];

  void _registrar(String linea) {
    debugPrint(linea); // consola
    setState(() => _log.add(linea)); // pantalla (para las evidencias)
  }

  /// async/await: la función "se pausa" en el await sin bloquear la UI.
  Future<void> _consultar({required bool simularError}) async {
    setState(() {
      _log.clear();
      _estado = EstadoCarga.cargando;
      _mensaje = 'Cargando...';
    });

    _registrar('1. ANTES: inicia la consulta, estado = Cargando');

    // Se crea el Future: la consulta comienza pero NO se espera todavía.
    final futuro = _servicio.consultarDatos(simularError: simularError);
    _registrar('2. DURANTE: la consulta sigue en curso, la UI no se bloquea');

    try {
      final datos = await futuro; // aquí se espera el resultado
      if (!mounted) return;
      setState(() {
        _estado = EstadoCarga.exito;
        _mensaje = datos;
      });
      _registrar('3. DESPUÉS: la consulta terminó con éxito');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estado = EstadoCarga.error;
        _mensaje = e.toString().replaceFirst('Exception: ', '');
      });
      _registrar('3. DESPUÉS: la consulta terminó con error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = _estado == EstadoCarga.cargando;

    return Scaffold(
      appBar: AppBar(title: const Text('Future / async / await')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TarjetaEstado(estado: _estado, mensaje: _mensaje),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: cargando
                  ? null
                  : () {
                      debugPrint('A. Antes de llamar a _consultar()');
                      _consultar(simularError: false);
                      // Se imprime ANTES de que termine la consulta, porque
                      // _consultar() no se esperó con await.
                      debugPrint('B. Después de llamar (sin esperar)');
                    },
              icon: const Icon(Icons.cloud_download),
              label: const Text('Consultar datos'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed:
                  cargando ? null : () => _consultar(simularError: true),
              icon: const Icon(Icons.error_outline),
              label: const Text('Consultar con error'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Orden de ejecución (también en consola):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                children: [for (final l in _log) Text(l)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaEstado extends StatelessWidget {
  const _TarjetaEstado({required this.estado, required this.mensaje});

  final EstadoCarga estado;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icono;
    late final String titulo;

    switch (estado) {
      case EstadoCarga.inicial:
        color = Colors.grey;
        icono = Icons.hourglass_empty;
        titulo = 'En espera';
      case EstadoCarga.cargando:
        color = Colors.blue;
        icono = Icons.sync;
        titulo = 'Cargando…';
      case EstadoCarga.exito:
        color = Colors.green;
        icono = Icons.check_circle;
        titulo = 'Éxito';
      case EstadoCarga.error:
        color = Colors.red;
        icono = Icons.error;
        titulo = 'Error';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (estado == EstadoCarga.cargando)
            const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(),
            )
          else
            Icon(icono, size: 40, color: color),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(mensaje, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

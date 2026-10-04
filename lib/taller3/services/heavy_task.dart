import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// Función CPU-bound: suma grande con operaciones aritméticas repetidas.
/// Es una función pura y de nivel superior, por lo que puede correr en
/// cualquier Isolate.
int sumaGrande(int n) {
  var total = 0;
  for (var i = 1; i <= n; i++) {
    total += (i * i) % 7;
  }
  return total;
}

/// Punto de entrada del Isolate (debe ser top-level o static).
/// Recibe [SendPort, n], calcula y devuelve el resultado por el puerto.
void _isolateEntry(List<dynamic> mensaje) {
  final SendPort puerto = mensaje[0] as SendPort;
  final int n = mensaje[1] as int;

  debugPrint('   [Isolate] Iniciado. Calculando suma con n = $n ...');
  final resultado = sumaGrande(n);
  debugPrint('   [Isolate] Cálculo terminado. Enviando resultado.');

  puerto.send(resultado);
}

/// Ejecuta [sumaGrande] en un Isolate nuevo con [Isolate.spawn] y espera el
/// resultado que llega como mensaje por un [ReceivePort].
Future<int> sumaGrandeEnIsolate(int n) async {
  final receivePort = ReceivePort();
  final errorPort = ReceivePort();

  final isolate = await Isolate.spawn<List<dynamic>>(
    _isolateEntry,
    [receivePort.sendPort, n],
    onError: errorPort.sendPort,
  );

  try {
    // Lo primero que llegue: el resultado o un error del Isolate.
    final primero = await Future.any<dynamic>([
      receivePort.first,
      errorPort.first,
    ]);
    if (primero is List) {
      throw Exception('Error en el Isolate: ${primero.first}');
    }
    return primero as int;
  } finally {
    receivePort.close();
    errorPort.close();
    isolate.kill(priority: Isolate.immediate);
  }
}

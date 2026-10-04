import 'package:flutter/foundation.dart';

/// Servicio simulado que "consulta" datos a un servidor remoto.
///
/// Usa [Future.delayed] para imitar la latencia de red (3 s). Devuelve un
/// [Future] que se completa con el resultado, o con un error si
/// [simularError] es true.
class DatosService {
  const DatosService();

  Future<String> consultarDatos({bool simularError = false}) async {
    debugPrint('   [Servicio] Consulta iniciada, esperando 3 s...');
    await Future.delayed(const Duration(seconds: 3));

    if (simularError) {
      throw Exception('No se pudo conectar con el servidor (error simulado)');
    }

    debugPrint('   [Servicio] Datos listos.');
    return 'Se recibieron 3 registros:\n'
        '• Ana Pérez – Ingeniería\n'
        '• Luis Gómez – Sistemas\n'
        '• María Rojas – Electrónica';
  }
}

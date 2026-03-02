/// @archivo   SocketServicio.dart
/// @descripcion Gestiona la conexion Socket.IO para progreso y alertas de fraude.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../Configuracion/Entorno.dart';
import '../Constantes/EventosSocket.dart';
import '../Modelos/Enums/TipoEventoTelemetria.dart';

class SocketServicio {
  io.Socket? _socket;

  /// Conecta al servidor websocket y une al usuario a la sala de sesion.
  void conectar({
    required String idSesion,
    required String rol,
  }) {
    if (_socket != null) {
      return;
    }

    _socket = io.io(
      Entorno.websocketUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.on(EventosSocket.conectar, (_) {
      _socket!.emit(EventosSocket.unirseSalaSesion, <String, dynamic>{
        'idSesion': idSesion,
        'rol': rol,
      });
    });
  }

  /// Desconecta la sesion websocket activa.
  void desconectar() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Emite alerta de fraude al docente en tiempo real.
  void emitirAlertaFraude(
    TipoEventoTelemetria tipoEvento, {
    String? idIntento,
  }) {
    _socket?.emit(EventosSocket.alertaFraude, <String, dynamic>{
      'idIntento': idIntento,
      'tipoEvento': tipoEvento.name,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  /// Emite avance del estudiante para monitoreo docente.
  void emitirProgreso({
    required String idIntento,
    required int respondidas,
    required int total,
  }) {
    _socket?.emit(EventosSocket.progresoEstudiante, <String, dynamic>{
      'idIntento': idIntento,
      'preguntasRespondidas': respondidas,
      'totalPreguntas': total,
    });
  }
}

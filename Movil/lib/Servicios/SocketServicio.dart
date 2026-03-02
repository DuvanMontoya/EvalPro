/// @archivo   SocketServicio.dart
/// @descripcion Gestiona la conexion Socket.IO para progreso y alertas de fraude.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../Configuracion/Entorno.dart';
import '../Constantes/ClavesAlmacen.dart';
import '../Constantes/EventosSocket.dart';
import '../Modelos/Enums/TipoEventoTelemetria.dart';

class SocketServicio {
  static const _namespaceSesiones = '/sesiones';

  final FlutterSecureStorage _almacenSeguro;
  io.Socket? _socket;

  SocketServicio({required FlutterSecureStorage almacenSeguro})
      : _almacenSeguro = almacenSeguro;

  /// Construye la URL del namespace oficial de sesiones sin duplicarlo.
  static String construirUrlNamespaceSesiones(String urlBase) {
    final limpia = urlBase.trim().replaceFirst(RegExp(r'/$'), '');
    if (limpia.endsWith(_namespaceSesiones)) {
      return limpia;
    }
    return '$limpia$_namespaceSesiones';
  }

  /// Arma la carga de autenticacion del handshake para el gateway.
  static Map<String, dynamic> construirAutenticacionHandshake(
      String tokenAcceso) {
    return <String, dynamic>{'tokenAcceso': tokenAcceso};
  }

  /// Conecta al servidor websocket y une al usuario a la sala de sesion.
  Future<bool> conectar({
    required String idSesion,
    required String rol,
  }) async {
    if (_socket != null && _socket!.connected) {
      return true;
    }

    final tokenAcceso =
        await _almacenSeguro.read(key: ClavesAlmacen.tokenAcceso);
    if (tokenAcceso == null || tokenAcceso.isEmpty) {
      return false;
    }

    desconectar();
    _socket = io.io(
      construirUrlNamespaceSesiones(Entorno.websocketUrl),
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .setAuth(construirAutenticacionHandshake(tokenAcceso))
          .setExtraHeaders(
              <String, dynamic>{'Authorization': 'Bearer $tokenAcceso'})
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit(EventosSocket.unirseSalaSesion, <String, dynamic>{
        'idSesion': idSesion,
        'rol': rol,
      });
    });
    _socket!.connect();
    return true;
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
    _socket?.emit(EventosSocket.progresoActualizado, <String, dynamic>{
      'idIntento': idIntento,
      'preguntasRespondidas': respondidas,
      'totalPreguntas': total,
    });
  }
}

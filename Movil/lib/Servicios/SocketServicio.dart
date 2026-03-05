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
  String? _idSesionActiva;
  String? _rolActivo;
  final List<Map<String, Object?>> _eventosPendientes = <Map<String, Object?>>[];

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
    return <String, dynamic>{
      'token': tokenAcceso,
      'tokenAcceso': tokenAcceso,
    };
  }

  /// Conecta al servidor websocket y une al usuario a la sala de sesion.
  Future<bool> conectar({
    required String idSesion,
    required String rol,
  }) async {
    final tokenAcceso =
        await _almacenSeguro.read(key: ClavesAlmacen.tokenAcceso);
    if (tokenAcceso == null || tokenAcceso.isEmpty) {
      return false;
    }

    _idSesionActiva = idSesion;
    _rolActivo = rol;

    if (_socket != null && _socket!.connected) {
      _actualizarCredencialesSocket(tokenAcceso);
      _unirseASalaActual();
      _drenarEventosPendientes();
      return true;
    }

    desconectar();
    _idSesionActiva = idSesion;
    _rolActivo = rol;
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
      _unirseASalaActual();
      _drenarEventosPendientes();
    });

    _socket!.on('connect_error', (_) async {
      final tokenActualizado =
          await _almacenSeguro.read(key: ClavesAlmacen.tokenAcceso);
      if (tokenActualizado != null && tokenActualizado.isNotEmpty) {
        _actualizarCredencialesSocket(tokenActualizado);
      }
    });

    _socket!.on('reconnect_attempt', (_) async {
      final tokenActualizado =
          await _almacenSeguro.read(key: ClavesAlmacen.tokenAcceso);
      if (tokenActualizado != null && tokenActualizado.isNotEmpty) {
        _actualizarCredencialesSocket(tokenActualizado);
      }
    });

    _socket!.connect();
    return true;
  }

  /// Desconecta la sesion websocket activa.
  void desconectar() {
    _eventosPendientes.clear();
    _idSesionActiva = null;
    _rolActivo = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Emite alerta de fraude al docente en tiempo real.
  void emitirAlertaFraude(
    TipoEventoTelemetria tipoEvento, {
    String? idIntento,
  }) {
    _emitirConCola(EventosSocket.alertaFraude, <String, dynamic>{
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
    _emitirConCola(EventosSocket.progresoActualizado, <String, dynamic>{
      'idIntento': idIntento,
      'preguntasRespondidas': respondidas,
      'totalPreguntas': total,
    });
  }

  void _emitirConCola(String evento, Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket != null && socket.connected) {
      socket.emit(evento, payload);
      return;
    }
    _eventosPendientes.add(<String, Object?>{
      'evento': evento,
      'payload': payload,
    });
  }

  void _drenarEventosPendientes() {
    final socket = _socket;
    if (socket == null || !socket.connected || _eventosPendientes.isEmpty) {
      return;
    }
    for (final eventoPendiente in _eventosPendientes) {
      final nombreEvento = eventoPendiente['evento'] as String?;
      final payload = eventoPendiente['payload'] as Map<String, dynamic>?;
      if (nombreEvento == null || payload == null) {
        continue;
      }
      socket.emit(nombreEvento, payload);
    }
    _eventosPendientes.clear();
  }

  void _unirseASalaActual() {
    final socket = _socket;
    final idSesion = _idSesionActiva;
    final rol = _rolActivo;
    if (socket == null || !socket.connected || idSesion == null || rol == null) {
      return;
    }

    socket.emit(EventosSocket.unirseSalaSesion, <String, dynamic>{
      'idSesion': idSesion,
      'rol': rol,
    });
  }

  void _actualizarCredencialesSocket(String tokenAcceso) {
    final socket = _socket;
    if (socket == null) {
      return;
    }

    socket.io.options?['auth'] = construirAutenticacionHandshake(tokenAcceso);
    socket.io.options?['extraHeaders'] = <String, dynamic>{
      'Authorization': 'Bearer $tokenAcceso',
    };
  }
}

/// @archivo   BackendE2eHelper.dart
/// @descripcion Prepara datos reales en backend para pruebas e2e moviles.
/// @modulo    integration_test/Soporte
/// @autor     EvalPro
/// @fecha     2026-03-05

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movil/Configuracion/Entorno.dart';

class CredencialesActorE2e {
  final String correo;
  final String contrasena;
  final String nombre;
  final String apellidos;

  const CredencialesActorE2e({
    required this.correo,
    required this.contrasena,
    required this.nombre,
    required this.apellidos,
  });
}

class EscenarioFlujoMovilE2e {
  final String sufijo;
  final CredencialesActorE2e docente;
  final CredencialesActorE2e estudiante;
  final String idSesion;
  final String tokenDocente;
  final int totalPreguntas;

  const EscenarioFlujoMovilE2e({
    required this.sufijo,
    required this.docente,
    required this.estudiante,
    required this.idSesion,
    required this.tokenDocente,
    required this.totalPreguntas,
  });
}

class _SesionAutenticadaE2e {
  final String tokenAcceso;
  final String tokenRefresh;
  final String idUsuario;
  final String? idInstitucion;

  const _SesionAutenticadaE2e({
    required this.tokenAcceso,
    required this.tokenRefresh,
    required this.idUsuario,
    required this.idInstitucion,
  });
}

class BackendE2eHelper {
  static const _correoAdminInicial = 'admin@evalpro.com';
  static const _contrasenaAdminInicial = 'Gaussiano1008*';
  static const _totalPreguntasPrueba = 3;

  final Dio _cliente;

  BackendE2eHelper({
    Dio? cliente,
    String? baseUrl,
  }) : _cliente = cliente ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? Entorno.apiUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                validateStatus: (_) => true,
                headers: const <String, dynamic>{
                  'Content-Type': 'application/json',
                  'X-E2E-Suite': 'movil-flujo-completo',
                },
              ),
            );

  void cerrar() {
    _cliente.close(force: true);
  }

  Future<void> esperarDisponible({
    Duration timeout = const Duration(seconds: 90),
  }) async {
    final limite = DateTime.now().add(timeout);
    Object? ultimoError;
    while (DateTime.now().isBefore(limite)) {
      try {
        final respuesta = await _cliente.get<Object?>('/salud');
        if (respuesta.statusCode == 200) {
          return;
        }
        ultimoError =
            'Backend devolvio estado ${respuesta.statusCode} en /salud.';
      } catch (error) {
        ultimoError = error;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    throw StateError(
      'El backend no estuvo disponible en ${timeout.inSeconds}s. '
      'Ultimo error: $ultimoError',
    );
  }

  Future<EscenarioFlujoMovilE2e> prepararEscenario() async {
    final sufijo = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final docente = CredencialesActorE2e(
      correo: 'docente.$sufijo@evalpro-e2e.local',
      contrasena: 'DocenteE2E1!',
      nombre: 'DocenteE2E',
      apellidos: sufijo,
    );
    final estudiante = CredencialesActorE2e(
      correo: 'estudiante.$sufijo@evalpro-e2e.local',
      contrasena: 'EstudianteE2E1!',
      nombre: 'EstudianteE2E',
      apellidos: sufijo,
    );

    final sesionAdmin = await _iniciarSesionConPrimerLogin(
      correo: _correoAdminInicial,
      contrasenaActual: _contrasenaAdminInicial,
      contrasenaFinal: _contrasenaAdminInicial,
    );

    final periodo = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/periodos',
        token: sesionAdmin.tokenAcceso,
        cuerpo: <String, dynamic>{
          'nombre': 'Periodo E2E $sufijo',
          'fechaInicio': _fechaIsoUtcDesdeAhora(const Duration(days: -1)),
          'fechaFin': _fechaIsoUtcDesdeAhora(const Duration(days: 120)),
          'activo': true,
        },
      ),
    );
    final idPeriodo = _leerCadenaObligatoria(periodo, 'id');

    final grupo = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/grupos',
        token: sesionAdmin.tokenAcceso,
        cuerpo: <String, dynamic>{
          'nombre': 'Grupo E2E $sufijo',
          'descripcion': 'Grupo automatizado para flujo movil e2e.',
          'idPeriodo': idPeriodo,
        },
      ),
    );
    final idGrupo = _leerCadenaObligatoria(grupo, 'id');

    final idDocente = await _crearUsuario(
      tokenAdmin: sesionAdmin.tokenAcceso,
      nombre: docente.nombre,
      apellidos: docente.apellidos,
      correo: docente.correo,
      contrasenaTemporal: 'TemporalDocente1!',
      rol: 'DOCENTE',
    );
    final idEstudiante = await _crearUsuario(
      tokenAdmin: sesionAdmin.tokenAcceso,
      nombre: estudiante.nombre,
      apellidos: estudiante.apellidos,
      correo: estudiante.correo,
      contrasenaTemporal: 'TemporalEstudiante1!',
      rol: 'ESTUDIANTE',
    );

    final sesionDocente = await _iniciarSesionConPrimerLogin(
      correo: docente.correo,
      contrasenaActual: 'TemporalDocente1!',
      contrasenaFinal: docente.contrasena,
    );
    await _iniciarSesionConPrimerLogin(
      correo: estudiante.correo,
      contrasenaActual: 'TemporalEstudiante1!',
      contrasenaFinal: estudiante.contrasena,
    );

    await _solicitarDatos(
      metodo: 'POST',
      ruta: '/grupos/$idGrupo/docentes',
      token: sesionAdmin.tokenAcceso,
      cuerpo: <String, dynamic>{'idDocente': idDocente},
    );
    await _solicitarDatos(
      metodo: 'POST',
      ruta: '/grupos/$idGrupo/estudiantes',
      token: sesionAdmin.tokenAcceso,
      cuerpo: <String, dynamic>{'idEstudiante': idEstudiante},
    );
    await _solicitarDatos(
      metodo: 'PATCH',
      ruta: '/grupos/$idGrupo/estado',
      token: sesionAdmin.tokenAcceso,
      cuerpo: const <String, dynamic>{'estado': 'ACTIVO'},
    );

    final examen = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/examenes',
        token: sesionDocente.tokenAcceso,
        cuerpo: <String, dynamic>{
          'titulo': 'Examen E2E $sufijo',
          'descripcion': 'Examen preparado por backend real para e2e movil.',
          'instrucciones': 'Selecciona una opcion por pregunta.',
          'modalidad': 'DIGITAL_COMPLETO',
          'duracionMinutos': 30,
          'permitirNavegacion': true,
          'mostrarPuntaje': true,
        },
      ),
    );
    final idExamen = _leerCadenaObligatoria(examen, 'id');

    for (var indice = 1; indice <= _totalPreguntasPrueba; indice++) {
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/examenes/$idExamen/preguntas',
        token: sesionDocente.tokenAcceso,
        cuerpo: <String, dynamic>{
          'enunciado': 'Pregunta E2E $indice $sufijo',
          'tipo': 'OPCION_MULTIPLE',
          'puntaje': 1,
          'opciones': <Map<String, dynamic>>[
            <String, dynamic>{
              'letra': 'A',
              'contenido': 'Respuesta correcta $indice',
              'esCorrecta': true,
              'orden': 1,
            },
            <String, dynamic>{
              'letra': 'B',
              'contenido': 'Distractor B $indice',
              'esCorrecta': false,
              'orden': 2,
            },
            <String, dynamic>{
              'letra': 'C',
              'contenido': 'Distractor C $indice',
              'esCorrecta': false,
              'orden': 3,
            },
          ],
        },
      );
    }

    await _solicitarDatos(
      metodo: 'POST',
      ruta: '/examenes/$idExamen/publicar',
      token: sesionDocente.tokenAcceso,
    );

    final fechaInicioAsignacionUtc =
        DateTime.now().toUtc().add(const Duration(seconds: 12));
    final fechaFinAsignacionUtc =
        fechaInicioAsignacionUtc.add(const Duration(minutes: 45));
    final fechaPublicacionResultadosUtc =
        fechaFinAsignacionUtc.add(const Duration(minutes: 5));

    final asignacion = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/asignaciones',
        token: sesionDocente.tokenAcceso,
        cuerpo: <String, dynamic>{
          'idExamen': idExamen,
          'idGrupo': idGrupo,
          'fechaInicio': _fechaIsoUtc(fechaInicioAsignacionUtc),
          'fechaFin': _fechaIsoUtc(fechaFinAsignacionUtc),
          'intentosMaximos': 1,
          'mostrarPuntajeInmediato': true,
          'mostrarRespuestasCorrectas': false,
          'publicarResultadosEn': _fechaIsoUtc(fechaPublicacionResultadosUtc),
        },
      ),
    );
    final idAsignacion = _leerCadenaObligatoria(asignacion, 'id');

    final sesion = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/sesiones',
        token: sesionDocente.tokenAcceso,
        cuerpo: <String, dynamic>{
          'idAsignacion': idAsignacion,
          'descripcion': 'Sesion movil e2e $sufijo',
        },
      ),
    );

    return EscenarioFlujoMovilE2e(
      sufijo: sufijo,
      docente: docente,
      estudiante: estudiante,
      idSesion: _leerCadenaObligatoria(sesion, 'id'),
      tokenDocente: sesionDocente.tokenAcceso,
      totalPreguntas: _totalPreguntasPrueba,
    );
  }

  Future<String> esperarCodigoSesionActivo(
    EscenarioFlujoMovilE2e escenario, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final sesion = _asMap(
        await _solicitarDatos(
          metodo: 'GET',
          ruta: '/sesiones/${escenario.idSesion}',
          token: escenario.tokenDocente,
        ),
      );
      final estado = _leerCadena(sesion, 'estado');
      final codigo = _leerCadena(sesion, 'codigoAcceso');
      if (estado == 'ACTIVA' && codigo.isNotEmpty) {
        return codigo;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'La sesion ${escenario.idSesion} no obtuvo codigo activo en '
      '${timeout.inSeconds}s.',
    );
  }

  Future<String> activarSesionComoDocente(
    EscenarioFlujoMovilE2e escenario, {
    Duration timeout = const Duration(seconds: 75),
  }) async {
    final limite = DateTime.now().add(timeout);
    Object? ultimoError;

    while (DateTime.now().isBefore(limite)) {
      final respuesta = await _cliente.request<Object?>(
        '/sesiones/${escenario.idSesion}/activar',
        options: Options(
          method: 'POST',
          headers: <String, dynamic>{
            'Authorization': 'Bearer ${escenario.tokenDocente}',
          },
        ),
      );

      final estado = respuesta.statusCode ?? 0;
      final cuerpoMapa = _asMapOpcional(respuesta.data);
      final codigoError = cuerpoMapa?['codigoError']?.toString() ?? '';
      final mensaje = cuerpoMapa?['mensaje']?.toString() ?? '';

      if ((estado == 200 || estado == 201) && cuerpoMapa != null) {
        final exito = cuerpoMapa['exito'];
        if (exito != false) {
          final sesion = _asMap(
            cuerpoMapa.containsKey('datos') ? cuerpoMapa['datos'] : cuerpoMapa,
          );
          final codigo = _leerCadenaObligatoria(sesion, 'codigoAcceso');
          if (codigo.trim().isNotEmpty) {
            return codigo;
          }
          ultimoError =
              'La activacion respondio sin codigo de acceso utilizable.';
        }
      } else if (estado == 403 && codigoError == 'SESION_NO_ACTIVA') {
        ultimoError = mensaje.isEmpty ? codigoError : '$codigoError $mensaje';
        await Future<void>.delayed(const Duration(seconds: 1));
        continue;
      } else {
        throw StateError(
          'HTTP inesperado $estado en POST /sesiones/${escenario.idSesion}/activar. '
          'Respuesta: ${cuerpoMapa ?? respuesta.data}',
        );
      }
    }

    throw StateError(
      'La sesion ${escenario.idSesion} no entro en ventana activa para '
      'activacion docente en ${timeout.inSeconds}s. '
      'Ultimo detalle: $ultimoError',
    );
  }

  Future<void> esperarReporteConEntrega(
    EscenarioFlujoMovilE2e escenario, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final reporte = _asMap(
        await _solicitarDatos(
          metodo: 'GET',
          ruta: '/reportes/sesion/${escenario.idSesion}',
          token: escenario.tokenDocente,
        ),
      );
      final entregados =
          (reporte['estudiantesQueEnviaron'] as num?)?.toInt() ?? 0;
      final total = (reporte['totalEstudiantes'] as num?)?.toInt() ?? 0;
      if (entregados >= 1 && total >= 1) {
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'El reporte de sesion ${escenario.idSesion} no reflejo la entrega en '
      '${timeout.inSeconds}s.',
    );
  }

  Future<int> obtenerTotalParticipantesSesion(
    EscenarioFlujoMovilE2e escenario,
  ) async {
    final reporte = _asMap(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/reportes/sesion/${escenario.idSesion}',
        token: escenario.tokenDocente,
      ),
    );
    return (reporte['totalEstudiantes'] as num?)?.toInt() ?? 0;
  }

  Future<void> esperarSesionFinalizada(
    EscenarioFlujoMovilE2e escenario, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final sesion = _asMap(
        await _solicitarDatos(
          metodo: 'GET',
          ruta: '/sesiones/${escenario.idSesion}',
          token: escenario.tokenDocente,
        ),
      );
      if (_leerCadena(sesion, 'estado') == 'FINALIZADA') {
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'La sesion ${escenario.idSesion} no paso a FINALIZADA en '
      '${timeout.inSeconds}s.',
    );
  }

  Future<String> _crearUsuario({
    required String tokenAdmin,
    required String nombre,
    required String apellidos,
    required String correo,
    required String contrasenaTemporal,
    required String rol,
  }) async {
    final usuario = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/usuarios',
        token: tokenAdmin,
        cuerpo: <String, dynamic>{
          'nombre': nombre,
          'apellidos': apellidos,
          'correo': correo,
          'contrasena': contrasenaTemporal,
          'rol': rol,
        },
      ),
    );
    return _leerCadenaObligatoria(usuario, 'id');
  }

  Future<_SesionAutenticadaE2e> _iniciarSesionConPrimerLogin({
    required String correo,
    required String contrasenaActual,
    required String contrasenaFinal,
  }) async {
    final inicio = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/autenticacion/iniciar-sesion',
        cuerpo: <String, dynamic>{
          'correo': correo,
          'contrasena': contrasenaActual,
        },
      ),
    );

    final requiereCambio =
        (inicio['requiereCambioContrasena'] as bool?) ?? false;
    if (!requiereCambio) {
      return _sesionDesdeMapa(inicio);
    }

    final tokenTemporal = _leerCadenaObligatoria(inicio, 'tokenTemporal');
    final cambio = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/autenticacion/cambiar-contrasena',
        token: tokenTemporal,
        cuerpo: <String, dynamic>{'nuevaContrasena': contrasenaFinal},
      ),
    );
    return _sesionDesdeMapa(cambio);
  }

  _SesionAutenticadaE2e _sesionDesdeMapa(Map<String, dynamic> sesion) {
    final usuario = _asMap(sesion['usuario']);
    return _SesionAutenticadaE2e(
      tokenAcceso: _leerCadenaObligatoria(sesion, 'tokenAcceso'),
      tokenRefresh: _leerCadenaObligatoria(sesion, 'tokenRefresh'),
      idUsuario: _leerCadenaObligatoria(usuario, 'id'),
      idInstitucion: _leerCadena(usuario, 'idInstitucion'),
    );
  }

  Future<Object?> _solicitarDatos({
    required String metodo,
    required String ruta,
    String? token,
    Object? cuerpo,
    Set<int> estadosEsperados = const <int>{200, 201},
  }) async {
    final respuesta = await _cliente.request<Object?>(
      ruta,
      data: cuerpo,
      options: Options(
        method: metodo,
        headers: <String, dynamic>{
          if (token != null && token.trim().isNotEmpty)
            'Authorization': 'Bearer ${token.trim()}',
        },
      ),
    );

    final estado = respuesta.statusCode ?? 0;
    final cuerpoMapa = _asMapOpcional(respuesta.data);
    if (!estadosEsperados.contains(estado)) {
      throw StateError(
        'HTTP inesperado $estado en $metodo $ruta. '
        'Respuesta: ${cuerpoMapa ?? respuesta.data}',
      );
    }

    if (cuerpoMapa == null) {
      return respuesta.data;
    }

    final exito = cuerpoMapa['exito'];
    if (exito == false) {
      throw StateError(
        'Error de backend en $metodo $ruta: '
                '${cuerpoMapa['codigoError'] ?? ''} ${cuerpoMapa['mensaje'] ?? ''}'
            .trim(),
      );
    }

    return cuerpoMapa.containsKey('datos') ? cuerpoMapa['datos'] : cuerpoMapa;
  }

  String _fechaIsoUtcDesdeAhora(Duration delta) =>
      DateTime.now().toUtc().add(delta).toIso8601String();

  String _fechaIsoUtc(DateTime fechaUtc) => fechaUtc.toUtc().toIso8601String();

  Map<String, dynamic> _asMap(Object? valor) {
    final mapa = _asMapOpcional(valor);
    if (mapa == null) {
      throw StateError('Se esperaba un mapa JSON y se recibio: $valor');
    }
    return mapa;
  }

  Map<String, dynamic>? _asMapOpcional(Object? valor) {
    if (valor is Map<String, dynamic>) {
      return valor;
    }
    if (valor is Map) {
      return valor.map(
        (clave, dato) => MapEntry(clave.toString(), dato),
      );
    }
    return null;
  }

  String _leerCadena(Map<String, dynamic> origen, String clave) {
    final valor = origen[clave];
    return valor is String ? valor.trim() : '';
  }

  String _leerCadenaObligatoria(Map<String, dynamic> origen, String clave) {
    final valor = _leerCadena(origen, clave);
    if (valor.isEmpty) {
      throw StateError('La clave $clave no estuvo presente en $origen');
    }
    return valor;
  }
}

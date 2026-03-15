/// @archivo   SuperadminBackendE2eHelper.dart
/// @descripcion Prepara y verifica escenarios e2e reales para la suite movil del superadmin.
/// @modulo    integration_test/Soporte
/// @autor     EvalPro
/// @fecha     2026-03-06

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movil/Configuracion/Entorno.dart';

class SesionApiE2e {
  final String tokenAcceso;
  final String tokenRefresh;
  final String idUsuario;
  final String? idInstitucion;

  const SesionApiE2e({
    required this.tokenAcceso,
    required this.tokenRefresh,
    required this.idUsuario,
    required this.idInstitucion,
  });
}

class ActorE2e {
  final String id;
  final String correo;
  final String contrasena;
  final String nombre;
  final String apellidos;

  const ActorE2e({
    required this.id,
    required this.correo,
    required this.contrasena,
    required this.nombre,
    required this.apellidos,
  });
}

class InstitucionE2e {
  final String id;
  final String nombre;
  final String estado;
  final String? dominio;

  const InstitucionE2e({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.dominio,
  });
}

class UsuarioE2e {
  final String id;
  final String correo;
  final String nombre;
  final String apellidos;
  final String rol;
  final bool activo;
  final String? idInstitucion;

  const UsuarioE2e({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellidos,
    required this.rol,
    required this.activo,
    required this.idInstitucion,
  });
}

class PeriodoE2e {
  final String id;
  final String nombre;
  final bool activo;
  final String idInstitucion;

  const PeriodoE2e({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.idInstitucion,
  });
}

class GrupoE2e {
  final String id;
  final String nombre;
  final String estado;
  final String idInstitucion;
  final int docentes;
  final int estudiantes;

  const GrupoE2e({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.idInstitucion,
    required this.docentes,
    required this.estudiantes,
  });
}

class ExamenE2e {
  final String id;
  final String titulo;
  final String estado;

  const ExamenE2e({
    required this.id,
    required this.titulo,
    required this.estado,
  });
}

class SesionE2e {
  final String id;
  final String estado;
  final String? codigoAcceso;
  final String? descripcion;

  const SesionE2e({
    required this.id,
    required this.estado,
    required this.codigoAcceso,
    required this.descripcion,
  });
}

class ReclamoE2e {
  final String id;
  final String estado;
  final String motivo;

  const ReclamoE2e({
    required this.id,
    required this.estado,
    required this.motivo,
  });
}

class EscenarioSuperadminE2e {
  final String sufijo;
  final InstitucionE2e institucionAcademica;
  final ActorE2e docente;
  final List<ActorE2e> estudiantes;
  final String idGrupo;
  final String idExamenArchivable;
  final String tituloExamenArchivable;
  final String idSesionActiva;
  final String idSesionPendiente;
  final String codigoSesionActiva;
  final String idReclamoAprobar;
  final String idReclamoRechazar;

  const EscenarioSuperadminE2e({
    required this.sufijo,
    required this.institucionAcademica,
    required this.docente,
    required this.estudiantes,
    required this.idGrupo,
    required this.idExamenArchivable,
    required this.tituloExamenArchivable,
    required this.idSesionActiva,
    required this.idSesionPendiente,
    required this.codigoSesionActiva,
    required this.idReclamoAprobar,
    required this.idReclamoRechazar,
  });
}

class SuperadminBackendE2eHelper {
  static const _totalPreguntasOperacion = 2;

  final Dio _cliente;

  SuperadminBackendE2eHelper({
    Dio? cliente,
    String? baseUrl,
  }) : _cliente = cliente ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? Entorno.apiUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 40),
                validateStatus: (_) => true,
                headers: const <String, dynamic>{
                  'Content-Type': 'application/json',
                  'X-E2E-Suite': 'movil-superadmin-completo',
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

  Future<SesionApiE2e> iniciarSesion({
    required String correo,
    required String contrasenaActual,
    String? contrasenaFinal,
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
        cuerpo: <String, dynamic>{
          'nuevaContrasena': contrasenaFinal ?? contrasenaActual,
        },
      ),
    );
    return _sesionDesdeMapa(cambio);
  }

  Future<EscenarioSuperadminE2e> prepararEscenarioAcademico({
    required String correoSuperadmin,
    required String contrasenaSuperadmin,
  }) async {
    final sesionSuperadmin = await iniciarSesion(
      correo: correoSuperadmin,
      contrasenaActual: contrasenaSuperadmin,
      contrasenaFinal: contrasenaSuperadmin,
    );
    final sufijo = DateTime.now().microsecondsSinceEpoch.toRadixString(36);

    final institucion = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/instituciones',
        token: sesionSuperadmin.tokenAcceso,
        cuerpo: <String, dynamic>{
          'nombre': 'Institucion academica superadmin $sufijo',
          'dominio': 'sa-academica-$sufijo.evalpro-e2e.local',
        },
      ),
    );
    final idInstitucion = _leerCadenaObligatoria(institucion, 'id');

    final docente = await _crearUsuario(
      tokenSuperadmin: sesionSuperadmin.tokenAcceso,
      nombre: 'DocenteSuperadmin',
      apellidos: sufijo,
      correo: 'docente.superadmin.$sufijo@evalpro-e2e.local',
      contrasena: 'DocenteSuperadmin1!',
      rol: 'DOCENTE',
      idInstitucion: idInstitucion,
    );
    final estudianteA = await _crearUsuario(
      tokenSuperadmin: sesionSuperadmin.tokenAcceso,
      nombre: 'EstudianteA',
      apellidos: sufijo,
      correo: 'estudiante.a.$sufijo@evalpro-e2e.local',
      contrasena: 'EstudianteSuperadmin1!',
      rol: 'ESTUDIANTE',
      idInstitucion: idInstitucion,
    );
    final estudianteB = await _crearUsuario(
      tokenSuperadmin: sesionSuperadmin.tokenAcceso,
      nombre: 'EstudianteB',
      apellidos: sufijo,
      correo: 'estudiante.b.$sufijo@evalpro-e2e.local',
      contrasena: 'EstudianteSuperadmin1!',
      rol: 'ESTUDIANTE',
      idInstitucion: idInstitucion,
    );

    final sesionDocente = await iniciarSesion(
      correo: docente.correo,
      contrasenaActual: docente.contrasena,
      contrasenaFinal: docente.contrasena,
    );
    final sesionEstudianteA = await iniciarSesion(
      correo: estudianteA.correo,
      contrasenaActual: estudianteA.contrasena,
      contrasenaFinal: estudianteA.contrasena,
    );
    final sesionEstudianteB = await iniciarSesion(
      correo: estudianteB.correo,
      contrasenaActual: estudianteB.contrasena,
      contrasenaFinal: estudianteB.contrasena,
    );

    final periodo = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/periodos',
        token: sesionSuperadmin.tokenAcceso,
        cuerpo: <String, dynamic>{
          'nombre': 'Periodo academico SA $sufijo',
          'fechaInicio': _fechaIsoUtcDesdeAhora(const Duration(days: -1)),
          'fechaFin': _fechaIsoUtcDesdeAhora(const Duration(days: 120)),
          'activo': true,
          'idInstitucion': idInstitucion,
        },
      ),
    );
    final idPeriodo = _leerCadenaObligatoria(periodo, 'id');

    final grupo = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/grupos',
        token: sesionSuperadmin.tokenAcceso,
        cuerpo: <String, dynamic>{
          'nombre': 'Grupo academico SA $sufijo',
          'descripcion': 'Grupo operativo para flujo superadmin.',
          'idPeriodo': idPeriodo,
          'idInstitucion': idInstitucion,
        },
      ),
    );
    final idGrupo = _leerCadenaObligatoria(grupo, 'id');

    await _solicitarDatos(
      metodo: 'POST',
      ruta: '/grupos/$idGrupo/docentes',
      token: sesionSuperadmin.tokenAcceso,
      cuerpo: <String, dynamic>{'idDocente': docente.id},
    );
    await _solicitarDatos(
      metodo: 'POST',
      ruta: '/grupos/$idGrupo/estudiantes',
      token: sesionSuperadmin.tokenAcceso,
      cuerpo: <String, dynamic>{'idEstudiante': estudianteA.id},
    );
    await _solicitarDatos(
      metodo: 'POST',
      ruta: '/grupos/$idGrupo/estudiantes',
      token: sesionSuperadmin.tokenAcceso,
      cuerpo: <String, dynamic>{'idEstudiante': estudianteB.id},
    );
    await _solicitarDatos(
      metodo: 'PATCH',
      ruta: '/grupos/$idGrupo/estado',
      token: sesionSuperadmin.tokenAcceso,
      cuerpo: const <String, dynamic>{
        'estado': 'ACTIVO',
        'razon': 'Habilitacion automatica para suite superadmin',
      },
    );

    final examenArchivable = await _crearExamenPublicado(
      tokenDocente: sesionDocente.tokenAcceso,
      titulo: 'Examen archivable SA $sufijo',
      sufijo: '$sufijo-archive',
    );
    final examenOperativo = await _crearExamenPublicado(
      tokenDocente: sesionDocente.tokenAcceso,
      titulo: 'Examen operativo SA $sufijo',
      sufijo: '$sufijo-live',
    );

    final fechaInicioAsignacionUtc =
        DateTime.now().toUtc().add(const Duration(seconds: 8));
    final fechaFinAsignacionUtc =
        fechaInicioAsignacionUtc.add(const Duration(minutes: 40));

    final asignacion = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/asignaciones',
        token: sesionDocente.tokenAcceso,
        cuerpo: <String, dynamic>{
          'idExamen': examenOperativo.id,
          'idGrupo': idGrupo,
          'fechaInicio': _fechaIsoUtc(fechaInicioAsignacionUtc),
          'fechaFin': _fechaIsoUtc(fechaFinAsignacionUtc),
          'intentosMaximos': 1,
          'mostrarPuntajeInmediato': true,
          'mostrarRespuestasCorrectas': false,
          'publicarResultadosEn': _fechaIsoUtc(
              fechaInicioAsignacionUtc.add(const Duration(minutes: 5))),
        },
      ),
    );
    final idAsignacion = _leerCadenaObligatoria(asignacion, 'id');

    final sesionActiva = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/sesiones',
        token: sesionDocente.tokenAcceso,
        cuerpo: <String, dynamic>{
          'idAsignacion': idAsignacion,
          'descripcion': 'Sesion activa superadmin $sufijo',
        },
      ),
    );
    final idSesionActiva = _leerCadenaObligatoria(sesionActiva, 'id');

    final sesionPendiente = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/sesiones',
        token: sesionDocente.tokenAcceso,
        cuerpo: <String, dynamic>{
          'idAsignacion': idAsignacion,
          'descripcion': 'Sesion pendiente superadmin $sufijo',
        },
      ),
    );
    final idSesionPendiente = _leerCadenaObligatoria(sesionPendiente, 'id');

    final codigoSesionActiva = await activarSesionComoDocente(
      tokenDocente: sesionDocente.tokenAcceso,
      idSesion: idSesionActiva,
    );

    final reclamoAprobable = await _crearEntregaYReclamo(
      sesionEstudiante: sesionEstudianteA,
      estudiante: estudianteA,
      idSesion: idSesionActiva,
      codigoAcceso: codigoSesionActiva,
      motivo: 'Solicitud de revision aprobable $sufijo',
      responderTodoCorrecto: false,
    );
    final reclamoRechazable = await _crearEntregaYReclamo(
      sesionEstudiante: sesionEstudianteB,
      estudiante: estudianteB,
      idSesion: idSesionActiva,
      codigoAcceso: codigoSesionActiva,
      motivo: 'Solicitud de revision rechazable $sufijo',
      responderTodoCorrecto: false,
    );

    return EscenarioSuperadminE2e(
      sufijo: sufijo,
      institucionAcademica: InstitucionE2e(
        id: idInstitucion,
        nombre: _leerCadenaObligatoria(institucion, 'nombre'),
        estado: _leerCadena(institucion, 'estado'),
        dominio: _leerCadena(institucion, 'dominio'),
      ),
      docente: docente,
      estudiantes: <ActorE2e>[estudianteA, estudianteB],
      idGrupo: idGrupo,
      idExamenArchivable: examenArchivable.id,
      tituloExamenArchivable: examenArchivable.titulo,
      idSesionActiva: idSesionActiva,
      idSesionPendiente: idSesionPendiente,
      codigoSesionActiva: codigoSesionActiva,
      idReclamoAprobar: reclamoAprobable.id,
      idReclamoRechazar: reclamoRechazable.id,
    );
  }

  Future<InstitucionE2e> esperarInstitucionPorNombre({
    required String token,
    required String nombre,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final instituciones = await listarInstituciones(token: token);
      final institucion = instituciones.where((item) => item.nombre == nombre);
      if (institucion.isNotEmpty) {
        return institucion.first;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'No se encontro la institucion "$nombre" en ${timeout.inSeconds}s.',
    );
  }

  Future<InstitucionE2e> esperarEstadoInstitucion({
    required String token,
    required String nombre,
    required String estado,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final instituciones = await listarInstituciones(token: token);
      for (final institucion in instituciones) {
        if (institucion.nombre == nombre && institucion.estado == estado) {
          return institucion;
        }
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'La institucion "$nombre" no llego a estado $estado en '
      '${timeout.inSeconds}s.',
    );
  }

  Future<UsuarioE2e> esperarUsuarioPorCorreo({
    required String token,
    required String correo,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final usuarios = await listarUsuarios(token: token);
      final usuario = usuarios.where((item) => item.correo == correo);
      if (usuario.isNotEmpty) {
        return usuario.first;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'No se encontro el usuario "$correo" en ${timeout.inSeconds}s.',
    );
  }

  Future<UsuarioE2e> esperarUsuario({
    required String token,
    required String correo,
    String? rol,
    bool? activo,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final usuarios = await listarUsuarios(token: token);
      for (final usuario in usuarios) {
        final coincideCorreo = usuario.correo == correo;
        final coincideRol = rol == null || usuario.rol == rol;
        final coincideActivo = activo == null || usuario.activo == activo;
        if (coincideCorreo && coincideRol && coincideActivo) {
          return usuario;
        }
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'El usuario "$correo" no alcanzo el estado esperado en '
      '${timeout.inSeconds}s.',
    );
  }

  Future<PeriodoE2e> esperarPeriodoPorNombre({
    required String token,
    required String nombre,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final periodos = await listarPeriodos(token: token);
      final periodo = periodos.where((item) => item.nombre == nombre);
      if (periodo.isNotEmpty) {
        return periodo.first;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'No se encontro el periodo "$nombre" en ${timeout.inSeconds}s.',
    );
  }

  Future<PeriodoE2e> esperarPeriodo({
    required String token,
    required String nombre,
    bool? activo,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final periodos = await listarPeriodos(token: token);
      for (final periodo in periodos) {
        final coincideNombre = periodo.nombre == nombre;
        final coincideActivo = activo == null || periodo.activo == activo;
        if (coincideNombre && coincideActivo) {
          return periodo;
        }
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'El periodo "$nombre" no alcanzo el estado esperado en '
      '${timeout.inSeconds}s.',
    );
  }

  Future<GrupoE2e> esperarGrupoPorNombre({
    required String token,
    required String nombre,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final grupos = await listarGrupos(token: token);
      final grupo = grupos.where((item) => item.nombre == nombre);
      if (grupo.isNotEmpty) {
        return grupo.first;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'No se encontro el grupo "$nombre" en ${timeout.inSeconds}s.',
    );
  }

  Future<GrupoE2e> esperarGrupo({
    required String token,
    required String nombre,
    String? estado,
    int? docentes,
    int? estudiantes,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final grupos = await listarGrupos(token: token);
      for (final grupo in grupos) {
        final coincideNombre = grupo.nombre == nombre;
        final coincideEstado = estado == null || grupo.estado == estado;
        final coincideDocentes = docentes == null || grupo.docentes == docentes;
        final coincideEstudiantes =
            estudiantes == null || grupo.estudiantes == estudiantes;
        if (coincideNombre &&
            coincideEstado &&
            coincideDocentes &&
            coincideEstudiantes) {
          return grupo;
        }
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'El grupo "$nombre" no alcanzo el estado esperado en '
      '${timeout.inSeconds}s.',
    );
  }

  Future<List<InstitucionE2e>> listarInstituciones({
    required String token,
  }) async {
    final lista = _asList(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/instituciones',
        token: token,
      ),
    );
    return lista.map(_institucionDesdeMapa).toList(growable: false);
  }

  Future<List<UsuarioE2e>> listarUsuarios({
    required String token,
  }) async {
    final lista = _asList(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/usuarios',
        token: token,
      ),
    );
    return lista.map(_usuarioDesdeMapa).toList(growable: false);
  }

  Future<List<PeriodoE2e>> listarPeriodos({
    required String token,
  }) async {
    final lista = _asList(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/periodos',
        token: token,
      ),
    );
    return lista.map(_periodoDesdeMapa).toList(growable: false);
  }

  Future<List<GrupoE2e>> listarGrupos({
    required String token,
  }) async {
    final lista = _asList(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/grupos',
        token: token,
      ),
    );
    return lista.map(_grupoDesdeMapa).toList(growable: false);
  }

  Future<SesionE2e> esperarEstadoSesion({
    required String token,
    required String idSesion,
    required String estado,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final sesion = await obtenerSesion(token: token, idSesion: idSesion);
      if (sesion.estado == estado) {
        return sesion;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'La sesion $idSesion no llego a estado $estado en ${timeout.inSeconds}s.',
    );
  }

  Future<ExamenE2e> esperarEstadoExamen({
    required String token,
    required String idExamen,
    required String estado,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final examen = await obtenerExamen(token: token, idExamen: idExamen);
      if (examen.estado == estado) {
        return examen;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'El examen $idExamen no llego a estado $estado en ${timeout.inSeconds}s.',
    );
  }

  Future<ReclamoE2e> esperarEstadoReclamo({
    required String token,
    required String idReclamo,
    required String estado,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final reclamo = await obtenerReclamo(token: token, idReclamo: idReclamo);
      if (reclamo.estado == estado) {
        return reclamo;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError(
      'El reclamo $idReclamo no llego a estado $estado en ${timeout.inSeconds}s.',
    );
  }

  Future<SesionE2e> obtenerSesion({
    required String token,
    required String idSesion,
  }) async {
    final mapa = _asMap(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/sesiones/$idSesion',
        token: token,
      ),
    );
    return _sesionDesdeMapaSimple(mapa);
  }

  Future<ExamenE2e> obtenerExamen({
    required String token,
    required String idExamen,
  }) async {
    final mapa = _asMap(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/examenes/$idExamen',
        token: token,
      ),
    );
    return ExamenE2e(
      id: _leerCadenaObligatoria(mapa, 'id'),
      titulo: _leerCadenaObligatoria(mapa, 'titulo'),
      estado: _leerCadena(mapa, 'estado'),
    );
  }

  Future<ReclamoE2e> obtenerReclamo({
    required String token,
    required String idReclamo,
  }) async {
    final lista = _asList(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/reclamos',
        token: token,
      ),
    );
    return lista
        .map(_reclamoDesdeMapa)
        .firstWhere((item) => item.id == idReclamo);
  }

  Future<String> activarSesionComoDocente({
    required String tokenDocente,
    required String idSesion,
    Duration timeout = const Duration(seconds: 75),
  }) async {
    final limite = DateTime.now().add(timeout);
    Object? ultimoError;

    while (DateTime.now().isBefore(limite)) {
      final respuesta = await _cliente.request<Object?>(
        '/sesiones/$idSesion/activar',
        options: Options(
          method: 'POST',
          headers: <String, dynamic>{
            'Authorization': 'Bearer $tokenDocente',
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
          'HTTP inesperado $estado en POST /sesiones/$idSesion/activar. '
          'Respuesta: ${cuerpoMapa ?? respuesta.data}',
        );
      }
    }

    throw StateError(
      'La sesion $idSesion no entro en ventana activa en '
      '${timeout.inSeconds}s. Ultimo detalle: $ultimoError',
    );
  }

  Future<ActorE2e> _crearUsuario({
    required String tokenSuperadmin,
    required String nombre,
    required String apellidos,
    required String correo,
    required String contrasena,
    required String rol,
    String? idInstitucion,
  }) async {
    final usuario = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/usuarios',
        token: tokenSuperadmin,
        cuerpo: <String, dynamic>{
          'nombre': nombre,
          'apellidos': apellidos,
          'correo': correo,
          'contrasena': contrasena,
          'rol': rol,
          if (idInstitucion != null && idInstitucion.trim().isNotEmpty)
            'idInstitucion': idInstitucion,
        },
      ),
    );

    return ActorE2e(
      id: _leerCadenaObligatoria(usuario, 'id'),
      correo: correo,
      contrasena: contrasena,
      nombre: nombre,
      apellidos: apellidos,
    );
  }

  Future<ExamenE2e> _crearExamenPublicado({
    required String tokenDocente,
    required String titulo,
    required String sufijo,
  }) async {
    final examen = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/examenes',
        token: tokenDocente,
        cuerpo: <String, dynamic>{
          'titulo': titulo,
          'descripcion': 'Examen de soporte para flujo del superadmin.',
          'instrucciones': 'Selecciona una opcion por pregunta.',
          'modalidad': 'CONTENIDO_COMPLETO',
          'duracionMinutos': 25,
          'permitirNavegacion': true,
          'mostrarPuntaje': true,
        },
      ),
    );
    final idExamen = _leerCadenaObligatoria(examen, 'id');

    for (var indice = 1; indice <= _totalPreguntasOperacion; indice++) {
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/examenes/$idExamen/preguntas',
        token: tokenDocente,
        cuerpo: <String, dynamic>{
          'enunciado': 'Pregunta SA $indice $sufijo',
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

    final publicado = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/examenes/$idExamen/publicar',
        token: tokenDocente,
      ),
    );

    return ExamenE2e(
      id: _leerCadenaObligatoria(publicado, 'id'),
      titulo: _leerCadenaObligatoria(publicado, 'titulo'),
      estado: _leerCadena(publicado, 'estado'),
    );
  }

  Future<ReclamoE2e> _crearEntregaYReclamo({
    required SesionApiE2e sesionEstudiante,
    required ActorE2e estudiante,
    required String idSesion,
    required String codigoAcceso,
    required String motivo,
    required bool responderTodoCorrecto,
  }) async {
    final intento = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/intentos',
        token: sesionEstudiante.tokenAcceso,
        cuerpo: <String, dynamic>{
          'idSesion': idSesion,
          'codigoAcceso': codigoAcceso,
          'versionApp': Entorno.versionApp,
          'sistemaOperativo': 'ANDROID',
        },
      ),
    );
    final idIntento = _leerCadenaObligatoria(intento, 'id');

    final payloadExamen = _asMap(
      await _solicitarDatos(
        metodo: 'GET',
        ruta: '/intentos/$idIntento/examen',
        token: sesionEstudiante.tokenAcceso,
      ),
    );
    final examen = _asMap(payloadExamen['examen']);
    final preguntas = _asList(examen['preguntas']);
    final respuestas = <Map<String, dynamic>>[];

    for (var indice = 0; indice < preguntas.length; indice++) {
      final pregunta = preguntas[indice];
      final idPregunta = _leerCadenaObligatoria(pregunta, 'id');
      final opciones = _asList(pregunta['opciones']);
      final indiceOpcion = responderTodoCorrecto || indice > 0 ? 0 : 1;
      final opcion = opciones[indiceOpcion];
      respuestas.add(
        <String, dynamic>{
          'idPregunta': idPregunta,
          'opcionesSeleccionadas': <String>[
            _leerCadenaObligatoria(opcion, 'id'),
          ],
          'tiempoRespuesta': 6,
          'esSincronizada': true,
        },
      );
    }

    await _solicitarDatos(
      metodo: 'POST',
      ruta: '/respuestas/sincronizar-lote',
      token: sesionEstudiante.tokenAcceso,
      cuerpo: <String, dynamic>{
        'idIntento': idIntento,
        'respuestas': respuestas,
      },
    );
    await _solicitarDatos(
      metodo: 'POST',
      ruta: '/intentos/$idIntento/finalizar',
      token: sesionEstudiante.tokenAcceso,
    );

    final idResultado = await _esperarResultadoIntento(
      tokenEstudiante: sesionEstudiante.tokenAcceso,
      idEstudiante: estudiante.id,
      idSesion: idSesion,
    );

    final reclamo = _asMap(
      await _solicitarDatos(
        metodo: 'POST',
        ruta: '/resultados/$idResultado/reclamos',
        token: sesionEstudiante.tokenAcceso,
        cuerpo: <String, dynamic>{
          'motivo': motivo,
        },
      ),
    );

    return ReclamoE2e(
      id: _leerCadenaObligatoria(reclamo, 'id'),
      estado: _leerCadena(reclamo, 'estado'),
      motivo: _leerCadenaObligatoria(reclamo, 'motivo'),
    );
  }

  Future<String> _esperarResultadoIntento({
    required String tokenEstudiante,
    required String idEstudiante,
    required String idSesion,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final limite = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(limite)) {
      final reporte = _asMap(
        await _solicitarDatos(
          metodo: 'GET',
          ruta: '/reportes/estudiante/$idEstudiante',
          token: tokenEstudiante,
        ),
      );
      final intentos = _asList(reporte['intentos']);
      for (final intento in intentos) {
        if (_leerCadena(intento, 'idSesion') != idSesion) {
          continue;
        }
        final idResultado = _leerCadena(intento, 'idResultado');
        if (idResultado.isNotEmpty) {
          return idResultado;
        }
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    throw StateError(
      'No se encontro resultado para el estudiante $idEstudiante en la sesion '
      '$idSesion dentro de ${timeout.inSeconds}s.',
    );
  }

  SesionApiE2e _sesionDesdeMapa(Map<String, dynamic> sesion) {
    final usuario = _asMap(sesion['usuario']);
    return SesionApiE2e(
      tokenAcceso: _leerCadenaObligatoria(sesion, 'tokenAcceso'),
      tokenRefresh: _leerCadenaObligatoria(sesion, 'tokenRefresh'),
      idUsuario: _leerCadenaObligatoria(usuario, 'id'),
      idInstitucion: _leerCadena(usuario, 'idInstitucion'),
    );
  }

  InstitucionE2e _institucionDesdeMapa(Map<String, dynamic> mapa) {
    return InstitucionE2e(
      id: _leerCadenaObligatoria(mapa, 'id'),
      nombre: _leerCadenaObligatoria(mapa, 'nombre'),
      estado: _leerCadena(mapa, 'estado'),
      dominio: _leerCadena(mapa, 'dominio'),
    );
  }

  UsuarioE2e _usuarioDesdeMapa(Map<String, dynamic> mapa) {
    return UsuarioE2e(
      id: _leerCadenaObligatoria(mapa, 'id'),
      correo: _leerCadenaObligatoria(mapa, 'correo'),
      nombre: _leerCadena(mapa, 'nombre'),
      apellidos: _leerCadena(mapa, 'apellidos'),
      rol: _leerCadena(mapa, 'rol'),
      activo: (mapa['activo'] as bool?) ?? false,
      idInstitucion: _leerCadena(mapa, 'idInstitucion'),
    );
  }

  PeriodoE2e _periodoDesdeMapa(Map<String, dynamic> mapa) {
    return PeriodoE2e(
      id: _leerCadenaObligatoria(mapa, 'id'),
      nombre: _leerCadenaObligatoria(mapa, 'nombre'),
      activo: (mapa['activo'] as bool?) ?? false,
      idInstitucion: _leerCadenaObligatoria(mapa, 'idInstitucion'),
    );
  }

  GrupoE2e _grupoDesdeMapa(Map<String, dynamic> mapa) {
    final docentes =
        _asListOpcional(mapa['docentes']) ?? <Map<String, dynamic>>[];
    final estudiantes =
        _asListOpcional(mapa['estudiantes']) ?? <Map<String, dynamic>>[];
    return GrupoE2e(
      id: _leerCadenaObligatoria(mapa, 'id'),
      nombre: _leerCadenaObligatoria(mapa, 'nombre'),
      estado: _leerCadena(mapa, 'estado'),
      idInstitucion: _leerCadenaObligatoria(mapa, 'idInstitucion'),
      docentes: docentes.length,
      estudiantes: estudiantes.length,
    );
  }

  ReclamoE2e _reclamoDesdeMapa(Map<String, dynamic> mapa) {
    return ReclamoE2e(
      id: _leerCadenaObligatoria(mapa, 'id'),
      estado: _leerCadena(mapa, 'estado'),
      motivo: _leerCadena(mapa, 'motivo'),
    );
  }

  SesionE2e _sesionDesdeMapaSimple(Map<String, dynamic> mapa) {
    return SesionE2e(
      id: _leerCadenaObligatoria(mapa, 'id'),
      estado: _leerCadena(mapa, 'estado'),
      codigoAcceso: _leerCadena(mapa, 'codigoAcceso'),
      descripcion: _leerCadena(mapa, 'descripcion'),
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

  List<Map<String, dynamic>> _asList(Object? valor) {
    final lista = _asListOpcional(valor);
    if (lista == null) {
      throw StateError('Se esperaba una lista JSON y se recibio: $valor');
    }
    return lista;
  }

  List<Map<String, dynamic>>? _asListOpcional(Object? valor) {
    if (valor is! List) {
      return null;
    }
    return valor.whereType<Object?>().map(_asMap).toList(growable: false);
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

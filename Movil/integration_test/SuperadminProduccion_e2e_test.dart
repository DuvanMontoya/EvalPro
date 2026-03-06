/// @archivo   SuperadminProduccion_e2e_test.dart
/// @descripcion Ejecuta una suite e2e real del superadmin sobre la app movil.
/// @modulo    integration_test
/// @autor     EvalPro
/// @fecha     2026-03-06

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movil/Configuracion/Entorno.dart';
import 'package:movil/Constantes/Rutas.dart';
import 'package:movil/main.dart' as app;

import 'Soporte/SuperadminBackendE2eHelper.dart';

const _correoSuperadmin = String.fromEnvironment(
  'E2E_SUPERADMIN_EMAIL',
  defaultValue: '',
);
const _contrasenaSuperadmin = String.fromEnvironment(
  'E2E_SUPERADMIN_PASSWORD',
  defaultValue: '',
);
const _permitirMutaciones = bool.fromEnvironment(
  'E2E_ALLOW_MUTATIONS',
  defaultValue: false,
);

bool _debeOmitirSuiteCompleta() {
  if (_correoSuperadmin.trim().isEmpty || _contrasenaSuperadmin.isEmpty) {
    return true;
  }
  if (!_permitirMutaciones) {
    return true;
  }
  return false;
}

class _BitacoraSuperadminE2e {
  _BitacoraSuperadminE2e(this.binding);

  final IntegrationTestWidgetsFlutterBinding binding;
  final DateTime _inicioUtc = DateTime.now().toUtc();
  final List<Map<String, Object?>> _eventos = <Map<String, Object?>>[];
  final Map<String, Object?> _contexto = <String, Object?>{};

  void contexto(String clave, Object? valor) {
    _contexto[clave] = valor;
  }

  void info(String mensaje, {Map<String, Object?>? datos}) {
    _agregar('INFO', mensaje, datos);
  }

  void ok(String mensaje, {Map<String, Object?>? datos}) {
    _agregar('OK', mensaje, datos);
  }

  void error(String mensaje, {Map<String, Object?>? datos}) {
    _agregar('ERROR', mensaje, datos);
  }

  void publicar({required bool exito}) {
    binding.reportData = <String, Object?>{
      'suite': 'superadmin_live_e2e',
      'passed': exito,
      'startedAtUtc': _inicioUtc.toIso8601String(),
      'finishedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'context': _contexto,
      'events': _eventos,
    };
  }

  void _agregar(
    String nivel,
    String mensaje,
    Map<String, Object?>? datos,
  ) {
    final evento = <String, Object?>{
      'level': nivel,
      'message': mensaje,
      'timestampUtc': DateTime.now().toUtc().toIso8601String(),
      if (datos != null && datos.isNotEmpty) 'data': datos,
    };
    _eventos.add(evento);
    final detalle = datos == null || datos.isEmpty ? '' : ' $datos';
    print('SUPERADMIN_E2E [$nivel] $mensaje$detalle');
  }
}

class _DatosUiSuperadmin {
  final String sufijo;
  final String institucionPrimaria;
  final String dominioInstitucionPrimaria;
  final String institucionSecundaria;
  final String dominioInstitucionSecundaria;
  final String nombrePeriodo;
  final String nombreGrupo;
  final String adminDirectoCorreo;
  final String adminDirectoNombre;
  final String docenteGrupoCorreo;
  final String docenteGrupoNombre;
  final String estudianteGrupoCorreo;
  final String estudianteGrupoNombre;
  final String usuarioMutableCorreoInicial;
  final String usuarioMutableCorreoEditado;
  final String usuarioMutableNombreInicial;
  final String usuarioMutableNombreEditado;
  final String contrasenaComun;

  const _DatosUiSuperadmin({
    required this.sufijo,
    required this.institucionPrimaria,
    required this.dominioInstitucionPrimaria,
    required this.institucionSecundaria,
    required this.dominioInstitucionSecundaria,
    required this.nombrePeriodo,
    required this.nombreGrupo,
    required this.adminDirectoCorreo,
    required this.adminDirectoNombre,
    required this.docenteGrupoCorreo,
    required this.docenteGrupoNombre,
    required this.estudianteGrupoCorreo,
    required this.estudianteGrupoNombre,
    required this.usuarioMutableCorreoInicial,
    required this.usuarioMutableCorreoEditado,
    required this.usuarioMutableNombreInicial,
    required this.usuarioMutableNombreEditado,
    required this.contrasenaComun,
  });

  factory _DatosUiSuperadmin.desdeSufijo(String sufijo) {
    return _DatosUiSuperadmin(
      sufijo: sufijo,
      institucionPrimaria: 'Institucion UI primaria $sufijo',
      dominioInstitucionPrimaria: 'ui-primaria-$sufijo.evalpro-e2e.local',
      institucionSecundaria: 'Institucion UI secundaria $sufijo',
      dominioInstitucionSecundaria: 'ui-secundaria-$sufijo.evalpro-e2e.local',
      nombrePeriodo: 'Periodo UI $sufijo',
      nombreGrupo: 'Grupo UI $sufijo',
      adminDirectoCorreo: 'admin.ui.$sufijo@evalpro-e2e.local',
      adminDirectoNombre: 'AdminUI$sufijo',
      docenteGrupoCorreo: 'docente.ui.$sufijo@evalpro-e2e.local',
      docenteGrupoNombre: 'DocenteUI$sufijo',
      estudianteGrupoCorreo: 'estudiante.ui.$sufijo@evalpro-e2e.local',
      estudianteGrupoNombre: 'EstudianteUI$sufijo',
      usuarioMutableCorreoInicial: 'mutable.ui.$sufijo@evalpro-e2e.local',
      usuarioMutableCorreoEditado:
          'mutable.ui.editado.$sufijo@evalpro-e2e.local',
      usuarioMutableNombreInicial: 'MutableUI$sufijo',
      usuarioMutableNombreEditado: 'MutableUIEditado$sufijo',
      contrasenaComun: 'ClaveUiE2E1!',
    );
  }
}

class _InstitucionesUiCreadas {
  final InstitucionE2e primaria;
  final InstitucionE2e secundaria;

  const _InstitucionesUiCreadas({
    required this.primaria,
    required this.secundaria,
  });
}

class _UsuariosUiCreados {
  final UsuarioE2e adminDirecto;
  final UsuarioE2e docenteGrupo;
  final UsuarioE2e estudianteGrupo;
  final UsuarioE2e usuarioMutable;

  const _UsuariosUiCreados({
    required this.adminDirecto,
    required this.docenteGrupo,
    required this.estudianteGrupo,
    required this.usuarioMutable,
  });
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'superadmin valida navegacion y acciones globales en vivo',
    (tester) async {
      final bitacora = _BitacoraSuperadminE2e(binding);
      final datosUi = _DatosUiSuperadmin.desdeSufijo(
        DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      );
      SuperadminBackendE2eHelper? backend;
      SesionApiE2e? sesionSuperadmin;
      EscenarioSuperadminE2e? escenarioAcademico;
      var exito = false;

      addTearDown(() => backend?.cerrar());

      try {
        await tester.runAsync(() async {
          await Entorno.inicializar();
          backend = SuperadminBackendE2eHelper(baseUrl: Entorno.apiUrl);
          await backend!.esperarDisponible();
          sesionSuperadmin = await backend!.iniciarSesion(
            correo: _correoSuperadmin,
            contrasenaActual: _contrasenaSuperadmin,
            contrasenaFinal: _contrasenaSuperadmin,
          );
          escenarioAcademico = await backend!.prepararEscenarioAcademico(
            correoSuperadmin: _correoSuperadmin,
            contrasenaSuperadmin: _contrasenaSuperadmin,
          );
          await const FlutterSecureStorage().deleteAll();
        });

        if (sesionSuperadmin == null || escenarioAcademico == null) {
          throw StateError(
            'No fue posible preparar el escenario backend del superadmin.',
          );
        }
        final sesionPreparada = sesionSuperadmin!;
        final escenarioPreparado = escenarioAcademico!;

        bitacora.contexto('apiUrl', Entorno.apiUrl);
        bitacora.contexto('uiSuffix', datosUi.sufijo);
        bitacora.contexto('academicSuffix', escenarioPreparado.sufijo);
        bitacora.contexto(
          'academicInstitution',
          escenarioPreparado.institucionAcademica.nombre,
        );
        bitacora.ok(
          'Escenario backend preparado',
          datos: <String, Object?>{
            'institucion': escenarioPreparado.institucionAcademica.nombre,
            'sesionActiva': escenarioPreparado.idSesionActiva,
            'sesionPendiente': escenarioPreparado.idSesionPendiente,
          },
        );

        await app.main();
        await _esperarVisible(
          tester,
          find.byKey(const Key('login_email_field')),
        );
        await _iniciarSesion(
          tester,
          correo: _correoSuperadmin,
          contrasena: _contrasenaSuperadmin,
        );
        bitacora.ok('Login superadmin completado');

        await _validarHomeSuperadmin(tester, bitacora);
        final instituciones = await _probarInstituciones(
          tester,
          backend: backend!,
          tokenSuperadmin: sesionPreparada.tokenAcceso,
          bitacora: bitacora,
          datosUi: datosUi,
        );
        final usuarios = await _probarUsuarios(
          tester,
          backend: backend!,
          tokenSuperadmin: sesionPreparada.tokenAcceso,
          bitacora: bitacora,
          datosUi: datosUi,
          instituciones: instituciones,
        );
        await _probarPeriodos(
          tester,
          backend: backend!,
          tokenSuperadmin: sesionPreparada.tokenAcceso,
          bitacora: bitacora,
          datosUi: datosUi,
        );
        await _probarGrupos(
          tester,
          backend: backend!,
          tokenSuperadmin: sesionPreparada.tokenAcceso,
          bitacora: bitacora,
          datosUi: datosUi,
          usuarios: usuarios,
        );
        await _probarExamenes(
          tester,
          backend: backend!,
          tokenSuperadmin: sesionPreparada.tokenAcceso,
          bitacora: bitacora,
          escenario: escenarioPreparado,
        );
        await _probarSesionesYReportes(
          tester,
          backend: backend!,
          tokenSuperadmin: sesionPreparada.tokenAcceso,
          bitacora: bitacora,
          escenario: escenarioPreparado,
        );
        await _probarReclamos(
          tester,
          backend: backend!,
          tokenSuperadmin: sesionPreparada.tokenAcceso,
          bitacora: bitacora,
          escenario: escenarioPreparado,
        );
        await _volverAInicio(tester);
        await _cerrarSesion(tester);
        bitacora.ok('Sesion cerrada correctamente');
        exito = true;
      } catch (error, stackTrace) {
        bitacora.error(
          'La suite del superadmin fallo',
          datos: <String, Object?>{
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
        rethrow;
      } finally {
        bitacora.publicar(exito: exito);
      }
    },
    skip: _debeOmitirSuiteCompleta(),
  );
}

Future<void> _validarHomeSuperadmin(
  WidgetTester tester,
  _BitacoraSuperadminE2e bitacora,
) async {
  await _esperarVisible(
    tester,
    find.byKey(const Key('inicio_manage_sessions_button')),
  );
  expect(find.byKey(const Key('inicio_manage_exams_button')), findsOneWidget);
  expect(find.byKey(const Key('inicio_manage_users_button')), findsOneWidget);
  expect(find.byKey(const Key('inicio_manage_groups_button')), findsOneWidget);
  expect(find.byKey(const Key('inicio_manage_periods_button')), findsOneWidget);
  expect(
    find.byKey(const Key('inicio_manage_institutions_button')),
    findsOneWidget,
  );
  expect(find.byKey(const Key('inicio_manage_claims_button')), findsOneWidget);
  bitacora.ok('Centro de control del superadmin visible');
}

Future<_InstitucionesUiCreadas> _probarInstituciones(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required _BitacoraSuperadminE2e bitacora,
  required _DatosUiSuperadmin datosUi,
}) async {
  await _volverAInicio(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_manage_institutions_button')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('institutions_create_fab')),
  );

  final primaria = await _crearInstitucionDesdeUi(
    tester,
    backend: backend,
    tokenSuperadmin: tokenSuperadmin,
    nombre: datosUi.institucionPrimaria,
    dominio: datosUi.dominioInstitucionPrimaria,
  );
  bitacora.ok(
    'Institucion primaria creada',
    datos: <String, Object?>{'id': primaria.id, 'nombre': primaria.nombre},
  );

  final secundaria = await _crearInstitucionDesdeUi(
    tester,
    backend: backend,
    tokenSuperadmin: tokenSuperadmin,
    nombre: datosUi.institucionSecundaria,
    dominio: datosUi.dominioInstitucionSecundaria,
  );
  bitacora.ok(
    'Institucion secundaria creada',
    datos: <String, Object?>{'id': secundaria.id, 'nombre': secundaria.nombre},
  );

  await _cambiarEstadoInstitucionDesdeUi(
    tester,
    idInstitucion: secundaria.id,
    estado: 'SUSPENDIDA',
    razon: 'Suspension automatica e2e',
  );
  await tester.runAsync(
    () => backend.esperarEstadoInstitucion(
      token: tokenSuperadmin,
      nombre: secundaria.nombre,
      estado: 'SUSPENDIDA',
    ),
  );
  bitacora.ok('Institucion secundaria suspendida');

  await _cambiarEstadoInstitucionDesdeUi(
    tester,
    idInstitucion: secundaria.id,
    estado: 'ACTIVA',
    razon: 'Reactivacion automatica e2e',
  );
  await tester.runAsync(
    () => backend.esperarEstadoInstitucion(
      token: tokenSuperadmin,
      nombre: secundaria.nombre,
      estado: 'ACTIVA',
    ),
  );
  bitacora.ok('Institucion secundaria reactivada');

  await _cambiarEstadoInstitucionDesdeUi(
    tester,
    idInstitucion: secundaria.id,
    estado: 'ARCHIVADA',
    razon: 'Archivado automatizado e2e',
  );
  await tester.runAsync(
    () => backend.esperarEstadoInstitucion(
      token: tokenSuperadmin,
      nombre: secundaria.nombre,
      estado: 'ARCHIVADA',
    ),
  );
  bitacora.ok('Institucion secundaria archivada');

  return _InstitucionesUiCreadas(
    primaria: primaria,
    secundaria: secundaria,
  );
}

Future<_UsuariosUiCreados> _probarUsuarios(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required _BitacoraSuperadminE2e bitacora,
  required _DatosUiSuperadmin datosUi,
  required _InstitucionesUiCreadas instituciones,
}) async {
  await _volverAInicio(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_manage_users_button')),
  );
  await _esperarVisible(tester, find.byKey(const Key('users_create_fab')));

  final adminDirecto = await _crearUsuarioDesdeUi(
    tester,
    backend: backend,
    tokenSuperadmin: tokenSuperadmin,
    nombre: datosUi.adminDirectoNombre,
    apellidos: 'Directo',
    correo: datosUi.adminDirectoCorreo,
    contrasena: datosUi.contrasenaComun,
    rol: 'ADMINISTRADOR',
    nombreInstitucion: instituciones.primaria.nombre,
  );
  bitacora.ok(
    'Administrador creado por UI',
    datos: <String, Object?>{'correo': adminDirecto.correo},
  );

  final docenteGrupo = await _crearUsuarioDesdeUi(
    tester,
    backend: backend,
    tokenSuperadmin: tokenSuperadmin,
    nombre: datosUi.docenteGrupoNombre,
    apellidos: 'Grupo',
    correo: datosUi.docenteGrupoCorreo,
    contrasena: datosUi.contrasenaComun,
    rol: 'DOCENTE',
    nombreInstitucion: instituciones.primaria.nombre,
  );
  bitacora.ok('Docente de grupo creado', datos: <String, Object?>{
    'correo': docenteGrupo.correo,
  });

  final estudianteGrupo = await _crearUsuarioDesdeUi(
    tester,
    backend: backend,
    tokenSuperadmin: tokenSuperadmin,
    nombre: datosUi.estudianteGrupoNombre,
    apellidos: 'Grupo',
    correo: datosUi.estudianteGrupoCorreo,
    contrasena: datosUi.contrasenaComun,
    rol: 'ESTUDIANTE',
    nombreInstitucion: instituciones.primaria.nombre,
  );
  bitacora.ok('Estudiante de grupo creado', datos: <String, Object?>{
    'correo': estudianteGrupo.correo,
  });

  final usuarioMutable = await _crearUsuarioDesdeUi(
    tester,
    backend: backend,
    tokenSuperadmin: tokenSuperadmin,
    nombre: datosUi.usuarioMutableNombreInicial,
    apellidos: 'Mutable',
    correo: datosUi.usuarioMutableCorreoInicial,
    contrasena: datosUi.contrasenaComun,
    rol: 'ESTUDIANTE',
    nombreInstitucion: instituciones.primaria.nombre,
  );
  bitacora.ok('Usuario mutable creado', datos: <String, Object?>{
    'correo': usuarioMutable.correo,
  });

  await _editarUsuarioDesdeUi(
    tester,
    idUsuario: usuarioMutable.id,
    nombre: datosUi.usuarioMutableNombreEditado,
    apellidos: 'Mutable Editado',
    correo: datosUi.usuarioMutableCorreoEditado,
    rol: 'ADMINISTRADOR',
    nuevaContrasena: 'MutableEditado1!',
  );
  final usuarioEditado = (await tester.runAsync(
    () => backend.esperarUsuario(
      token: tokenSuperadmin,
      correo: datosUi.usuarioMutableCorreoEditado,
      rol: 'ADMINISTRADOR',
      activo: true,
    ),
  ))!;
  bitacora.ok('Usuario mutable editado', datos: <String, Object?>{
    'correo': usuarioEditado.correo,
    'rol': usuarioEditado.rol,
  });

  await _desactivarUsuarioDesdeUi(
    tester,
    idUsuario: usuarioEditado.id,
  );
  final usuarioDesactivado = (await tester.runAsync(
    () => backend.esperarUsuario(
      token: tokenSuperadmin,
      correo: datosUi.usuarioMutableCorreoEditado,
      rol: 'ADMINISTRADOR',
      activo: false,
    ),
  ))!;
  bitacora.ok('Usuario mutable desactivado', datos: <String, Object?>{
    'correo': usuarioDesactivado.correo,
  });

  return _UsuariosUiCreados(
    adminDirecto: adminDirecto,
    docenteGrupo: docenteGrupo,
    estudianteGrupo: estudianteGrupo,
    usuarioMutable: usuarioDesactivado,
  );
}

Future<void> _probarPeriodos(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required _BitacoraSuperadminE2e bitacora,
  required _DatosUiSuperadmin datosUi,
}) async {
  await _volverAInicio(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_manage_periods_button')),
  );
  await _esperarVisible(tester, find.byKey(const Key('periods_create_fab')));

  final periodo = await _crearPeriodoDesdeUi(
    tester,
    backend: backend,
    tokenSuperadmin: tokenSuperadmin,
    nombre: datosUi.nombrePeriodo,
    nombreInstitucion: datosUi.institucionPrimaria,
  );
  bitacora.ok(
    'Periodo creado desde UI',
    datos: <String, Object?>{'id': periodo.id, 'nombre': periodo.nombre},
  );

  await _alternarPeriodoDesdeUi(tester, idPeriodo: periodo.id);
  await tester.runAsync(
    () => backend.esperarPeriodo(
      token: tokenSuperadmin,
      nombre: periodo.nombre,
      activo: false,
    ),
  );
  bitacora.ok('Periodo desactivado');

  await _alternarPeriodoDesdeUi(tester, idPeriodo: periodo.id);
  await tester.runAsync(
    () => backend.esperarPeriodo(
      token: tokenSuperadmin,
      nombre: periodo.nombre,
      activo: true,
    ),
  );
  bitacora.ok('Periodo reactivado');
}

Future<void> _probarGrupos(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required _BitacoraSuperadminE2e bitacora,
  required _DatosUiSuperadmin datosUi,
  required _UsuariosUiCreados usuarios,
}) async {
  await _volverAInicio(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_manage_groups_button')),
  );
  await _esperarVisible(tester, find.byKey(const Key('groups_create_fab')));

  final grupo = await _crearGrupoDesdeUi(
    tester,
    backend: backend,
    tokenSuperadmin: tokenSuperadmin,
    nombre: datosUi.nombreGrupo,
    descripcion: 'Grupo creado desde el flujo superadmin e2e.',
    nombrePeriodo: datosUi.nombrePeriodo,
  );
  bitacora.ok(
    'Grupo creado desde UI',
    datos: <String, Object?>{'id': grupo.id, 'nombre': grupo.nombre},
  );

  await _asignarDocenteAGrupoDesdeUi(
    tester,
    idGrupo: grupo.id,
    textoDocente:
        '${usuarios.docenteGrupo.nombre} ${usuarios.docenteGrupo.apellidos}',
  );
  await tester.runAsync(
    () => backend.esperarGrupo(
      token: tokenSuperadmin,
      nombre: grupo.nombre,
      docentes: 1,
    ),
  );
  bitacora.ok('Docente asignado al grupo');

  await _inscribirEstudianteEnGrupoDesdeUi(
    tester,
    idGrupo: grupo.id,
    textoEstudiante:
        '${usuarios.estudianteGrupo.nombre} ${usuarios.estudianteGrupo.apellidos}',
  );
  await tester.runAsync(
    () => backend.esperarGrupo(
      token: tokenSuperadmin,
      nombre: grupo.nombre,
      docentes: 1,
      estudiantes: 1,
    ),
  );
  bitacora.ok('Estudiante inscrito en el grupo');

  await _cambiarEstadoGrupoDesdeUi(
    tester,
    idGrupo: grupo.id,
    estado: 'ACTIVO',
    razon: 'Activacion del grupo para validacion UI',
  );
  await tester.runAsync(
    () => backend.esperarGrupo(
      token: tokenSuperadmin,
      nombre: grupo.nombre,
      estado: 'ACTIVO',
      docentes: 1,
      estudiantes: 1,
    ),
  );
  bitacora.ok('Grupo activado');
}

Future<void> _probarExamenes(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required _BitacoraSuperadminE2e bitacora,
  required EscenarioSuperadminE2e escenario,
}) async {
  await _volverAInicio(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_manage_exams_button')),
  );
  await _esperarVisible(tester, find.byKey(const Key('exams_refresh_button')));
  await _esperarVisible(
    tester,
    find.byKey(ValueKey<String>('exam_card_${escenario.idExamenArchivable}')),
    timeout: const Duration(seconds: 25),
  );

  await _tapVisible(
    tester,
    find.byKey(
      ValueKey<String>('exam_archive_button_${escenario.idExamenArchivable}'),
    ),
  );
  await tester.runAsync(
    () => backend.esperarEstadoExamen(
      token: tokenSuperadmin,
      idExamen: escenario.idExamenArchivable,
      estado: 'ARCHIVADO',
    ),
  );
  bitacora.ok('Examen archivado desde UI', datos: <String, Object?>{
    'idExamen': escenario.idExamenArchivable,
  });
}

Future<void> _probarSesionesYReportes(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required _BitacoraSuperadminE2e bitacora,
  required EscenarioSuperadminE2e escenario,
}) async {
  await _volverAInicio(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_manage_sessions_button')),
  );
  await _esperarVisible(
    tester,
    find.byKey(ValueKey<String>('session_card_${escenario.idSesionActiva}')),
    timeout: const Duration(seconds: 25),
  );

  await _tapVisible(
    tester,
    find.byKey(
      ValueKey<String>(
        'session_management_report_button_${escenario.idSesionActiva}',
      ),
    ),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('session_report_metric_total_students')),
    timeout: const Duration(seconds: 25),
  );
  expect(
    find.descendant(
      of: find.byKey(const Key('session_report_metric_total_students')),
      matching: find.text('2'),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: find.byKey(const Key('session_report_metric_submitted')),
      matching: find.text('2'),
    ),
    findsOneWidget,
  );
  expect(
    find.byKey(
      ValueKey<String>(
        'session_report_student_${escenario.estudiantes.first.nombre}_${escenario.estudiantes.first.apellidos}',
      ),
    ),
    findsOneWidget,
  );
  expect(
    find.byKey(
      ValueKey<String>(
        'session_report_student_${escenario.estudiantes.last.nombre}_${escenario.estudiantes.last.apellidos}',
      ),
    ),
    findsOneWidget,
  );
  bitacora.ok('Reporte de sesion validado');

  await _navegarARuta(tester, Rutas.gestionSesiones);
  await _esperarVisible(
    tester,
    find.byKey(
      ValueKey<String>(
        'session_management_finalize_button_${escenario.idSesionActiva}',
      ),
    ),
  );
  await _tapVisible(
    tester,
    find.byKey(
      ValueKey<String>(
        'session_management_finalize_button_${escenario.idSesionActiva}',
      ),
    ),
  );
  await tester.runAsync(
    () => backend.esperarEstadoSesion(
      token: tokenSuperadmin,
      idSesion: escenario.idSesionActiva,
      estado: 'FINALIZADA',
    ),
  );
  bitacora.ok('Sesion activa finalizada desde UI');

  await _tapVisible(
    tester,
    find.byKey(
      ValueKey<String>(
        'session_management_cancel_button_${escenario.idSesionPendiente}',
      ),
    ),
  );
  await tester.runAsync(
    () => backend.esperarEstadoSesion(
      token: tokenSuperadmin,
      idSesion: escenario.idSesionPendiente,
      estado: 'CANCELADA',
    ),
  );
  bitacora.ok('Sesion pendiente cancelada desde UI');
}

Future<void> _probarReclamos(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required _BitacoraSuperadminE2e bitacora,
  required EscenarioSuperadminE2e escenario,
}) async {
  await _volverAInicio(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_manage_claims_button')),
  );
  await _esperarVisible(
    tester,
    find.byKey(ValueKey<String>('claim_card_${escenario.idReclamoAprobar}')),
    timeout: const Duration(seconds: 25),
  );

  await _resolverReclamoDesdeUi(
    tester,
    idReclamo: escenario.idReclamoAprobar,
    aprobar: true,
    resolucion: 'Aprobado por validacion automatizada',
    puntajeNuevo: '2',
  );
  await tester.runAsync(
    () => backend.esperarEstadoReclamo(
      token: tokenSuperadmin,
      idReclamo: escenario.idReclamoAprobar,
      estado: 'RESUELTO',
    ),
  );
  bitacora.ok('Reclamo aprobable resuelto');

  await _resolverReclamoDesdeUi(
    tester,
    idReclamo: escenario.idReclamoRechazar,
    aprobar: false,
    resolucion: 'Rechazado por validacion automatizada',
  );
  await tester.runAsync(
    () => backend.esperarEstadoReclamo(
      token: tokenSuperadmin,
      idReclamo: escenario.idReclamoRechazar,
      estado: 'RECHAZADO',
    ),
  );
  bitacora.ok('Reclamo rechazable resuelto');
}

Future<InstitucionE2e> _crearInstitucionDesdeUi(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required String nombre,
  required String dominio,
}) async {
  await _tapVisible(
    tester,
    find.byKey(const Key('institutions_create_fab')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('institutions_create_name_field')),
  );
  await tester.enterText(
    find.byKey(const Key('institutions_create_name_field')),
    nombre,
  );
  await tester.enterText(
    find.byKey(const Key('institutions_create_domain_field')),
    dominio,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('institutions_create_submit_button')),
  );
  await _esperarVisible(tester, find.text(nombre));
  final institucion = await tester.runAsync(
    () => backend.esperarInstitucionPorNombre(
      token: tokenSuperadmin,
      nombre: nombre,
    ),
  );
  return institucion!;
}

Future<void> _cambiarEstadoInstitucionDesdeUi(
  WidgetTester tester, {
  required String idInstitucion,
  required String estado,
  required String razon,
}) async {
  await _tapVisible(
    tester,
    find.byKey(ValueKey<String>('institution_actions_button_$idInstitucion')),
  );
  await _tapVisible(
    tester,
    find.byKey(
      ValueKey<String>('institution_change_state_${idInstitucion}_$estado'),
    ),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('institution_state_reason_field')),
  );
  await tester.enterText(
    find.byKey(const Key('institution_state_reason_field')),
    razon,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('institution_state_save_button')),
  );
}

Future<UsuarioE2e> _crearUsuarioDesdeUi(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required String nombre,
  required String apellidos,
  required String correo,
  required String contrasena,
  required String rol,
  String? nombreInstitucion,
}) async {
  await _tapVisible(tester, find.byKey(const Key('users_create_fab')));
  await _esperarVisible(
    tester,
    find.byKey(const Key('users_create_name_field')),
  );
  await tester.enterText(
    find.byKey(const Key('users_create_name_field')),
    nombre,
  );
  await tester.enterText(
    find.byKey(const Key('users_create_last_name_field')),
    apellidos,
  );
  await tester.enterText(
    find.byKey(const Key('users_create_email_field')),
    correo,
  );
  await tester.enterText(
    find.byKey(const Key('users_create_password_field')),
    contrasena,
  );
  await _seleccionarOpcionDropdown(
    tester,
    find.byKey(const Key('users_create_role_field')),
    rol,
  );
  if (nombreInstitucion != null) {
    await _seleccionarOpcionDropdown(
      tester,
      find.byKey(const Key('users_create_institution_field')),
      nombreInstitucion,
    );
  }
  await _tapVisible(
    tester,
    find.byKey(const Key('users_create_submit_button')),
  );
  await _esperarVisible(tester, find.text(correo));
  final usuario = await tester.runAsync(
    () => backend.esperarUsuarioPorCorreo(
      token: tokenSuperadmin,
      correo: correo,
    ),
  );
  return usuario!;
}

Future<void> _editarUsuarioDesdeUi(
  WidgetTester tester, {
  required String idUsuario,
  required String nombre,
  required String apellidos,
  required String correo,
  required String rol,
  required String nuevaContrasena,
}) async {
  await _tapVisible(
    tester,
    find.byKey(ValueKey<String>('user_edit_button_$idUsuario')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('users_edit_name_field')),
  );
  await tester.enterText(find.byKey(const Key('users_edit_name_field')), '');
  await tester.enterText(
    find.byKey(const Key('users_edit_name_field')),
    nombre,
  );
  await tester.enterText(
    find.byKey(const Key('users_edit_last_name_field')),
    '',
  );
  await tester.enterText(
    find.byKey(const Key('users_edit_last_name_field')),
    apellidos,
  );
  await tester.enterText(find.byKey(const Key('users_edit_email_field')), '');
  await tester.enterText(
    find.byKey(const Key('users_edit_email_field')),
    correo,
  );
  await tester.enterText(
    find.byKey(const Key('users_edit_password_field')),
    nuevaContrasena,
  );
  await _seleccionarOpcionDropdown(
    tester,
    find.byKey(const Key('users_edit_role_field')),
    rol,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('users_edit_submit_button')),
  );
}

Future<void> _desactivarUsuarioDesdeUi(
  WidgetTester tester, {
  required String idUsuario,
}) async {
  await _tapVisible(
    tester,
    find.byKey(ValueKey<String>('user_deactivate_button_$idUsuario')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('users_deactivate_submit_button')),
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('users_deactivate_submit_button')),
  );
}

Future<PeriodoE2e> _crearPeriodoDesdeUi(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required String nombre,
  required String nombreInstitucion,
}) async {
  await _tapVisible(tester, find.byKey(const Key('periods_create_fab')));
  await _esperarVisible(
    tester,
    find.byKey(const Key('periods_create_name_field')),
  );
  await tester.enterText(
    find.byKey(const Key('periods_create_name_field')),
    nombre,
  );
  await _seleccionarOpcionDropdown(
    tester,
    find.byKey(const Key('periods_create_institution_field')),
    nombreInstitucion,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('periods_create_start_tile')),
  );
  await _confirmarFechaActual(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('periods_create_end_tile')),
  );
  await _confirmarFechaActual(tester);
  await _tapVisible(
    tester,
    find.byKey(const Key('periods_create_submit_button')),
  );
  await _esperarVisible(tester, find.text(nombre));
  final periodo = await tester.runAsync(
    () => backend.esperarPeriodoPorNombre(
      token: tokenSuperadmin,
      nombre: nombre,
    ),
  );
  return periodo!;
}

Future<void> _alternarPeriodoDesdeUi(
  WidgetTester tester, {
  required String idPeriodo,
}) async {
  await _tapVisible(
    tester,
    find.byKey(ValueKey<String>('period_toggle_$idPeriodo')),
  );
  await _bombearDurante(tester, const Duration(seconds: 2));
}

Future<GrupoE2e> _crearGrupoDesdeUi(
  WidgetTester tester, {
  required SuperadminBackendE2eHelper backend,
  required String tokenSuperadmin,
  required String nombre,
  required String descripcion,
  required String nombrePeriodo,
}) async {
  await _tapVisible(tester, find.byKey(const Key('groups_create_fab')));
  await _esperarVisible(
    tester,
    find.byKey(const Key('groups_create_name_field')),
  );
  await tester.enterText(
    find.byKey(const Key('groups_create_name_field')),
    nombre,
  );
  await tester.enterText(
    find.byKey(const Key('groups_create_description_field')),
    descripcion,
  );
  await _seleccionarOpcionDropdown(
    tester,
    find.byKey(const Key('groups_create_period_field')),
    nombrePeriodo,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('groups_create_submit_button')),
  );
  await _esperarVisible(tester, find.text(nombre));
  final grupo = await tester.runAsync(
    () => backend.esperarGrupoPorNombre(
      token: tokenSuperadmin,
      nombre: nombre,
    ),
  );
  return grupo!;
}

Future<void> _asignarDocenteAGrupoDesdeUi(
  WidgetTester tester, {
  required String idGrupo,
  required String textoDocente,
}) async {
  await _tapVisible(
    tester,
    find.byKey(ValueKey<String>('group_assign_teacher_button_$idGrupo')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('groups_assign_teacher_field')),
  );
  await _seleccionarOpcionDropdown(
    tester,
    find.byKey(const Key('groups_assign_teacher_field')),
    textoDocente,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('groups_assign_teacher_submit_button')),
  );
}

Future<void> _inscribirEstudianteEnGrupoDesdeUi(
  WidgetTester tester, {
  required String idGrupo,
  required String textoEstudiante,
}) async {
  await _tapVisible(
    tester,
    find.byKey(ValueKey<String>('group_enroll_student_button_$idGrupo')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('groups_enroll_student_field')),
  );
  await _seleccionarOpcionDropdown(
    tester,
    find.byKey(const Key('groups_enroll_student_field')),
    textoEstudiante,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('groups_enroll_student_submit_button')),
  );
}

Future<void> _cambiarEstadoGrupoDesdeUi(
  WidgetTester tester, {
  required String idGrupo,
  required String estado,
  required String razon,
}) async {
  await _tapVisible(
    tester,
    find.byKey(ValueKey<String>('group_change_state_button_$idGrupo')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('groups_state_field')),
  );
  await _seleccionarOpcionDropdown(
    tester,
    find.byKey(const Key('groups_state_field')),
    estado,
  );
  await tester.enterText(
    find.byKey(const Key('groups_state_reason_field')),
    razon,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('groups_state_submit_button')),
  );
}

Future<void> _resolverReclamoDesdeUi(
  WidgetTester tester, {
  required String idReclamo,
  required bool aprobar,
  required String resolucion,
  String? puntajeNuevo,
}) async {
  final boton = aprobar
      ? ValueKey<String>('claim_approve_button_$idReclamo')
      : ValueKey<String>('claim_reject_button_$idReclamo');
  await _tapVisible(tester, find.byKey(boton));
  await _esperarVisible(
    tester,
    find.byKey(const Key('claims_resolution_field')),
  );
  await tester.enterText(
    find.byKey(const Key('claims_resolution_field')),
    resolucion,
  );
  if (puntajeNuevo != null) {
    await tester.enterText(
      find.byKey(const Key('claims_score_field')),
      puntajeNuevo,
    );
  }
  await _tapVisible(
    tester,
    find.byKey(const Key('claims_resolution_submit_button')),
  );
}

Future<void> _iniciarSesion(
  WidgetTester tester, {
  required String correo,
  required String contrasena,
}) async {
  await _esperarVisible(
    tester,
    find.byKey(const Key('login_email_field')),
  );
  await tester.enterText(find.byKey(const Key('login_email_field')), correo);
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    contrasena,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('login_submit_button')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('inicio_logout_button')),
    timeout: const Duration(seconds: 25),
  );
}

Future<void> _cerrarSesion(WidgetTester tester) async {
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_logout_button')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('login_email_field')),
    timeout: const Duration(seconds: 25),
  );
}

Future<void> _volverAInicio(WidgetTester tester) async {
  await _navegarARuta(tester, Rutas.inicio);
  await _esperarVisible(
    tester,
    find.byKey(const Key('inicio_logout_button')),
    timeout: const Duration(seconds: 20),
  );
}

Future<void> _seleccionarOpcionDropdown(
  WidgetTester tester,
  Finder finder,
  String textoOpcion,
) async {
  await _tapVisible(tester, finder);
  await _esperarVisible(tester, find.text(textoOpcion).last);
  await _tapVisible(tester, find.text(textoOpcion).last);
}

Future<void> _confirmarFechaActual(WidgetTester tester) async {
  await _esperarVisible(tester, find.byType(Dialog));
  final contexto = tester.element(find.byType(Dialog).last);
  final etiquetaOk = MaterialLocalizations.of(contexto).okButtonLabel;
  await _tapVisible(tester, find.text(etiquetaOk).last);
}

Future<void> _navegarARuta(WidgetTester tester, String ruta) async {
  final contexto = tester.element(find.byType(Scaffold).first);
  GoRouter.of(contexto).go(ruta);
  await tester.pump(const Duration(milliseconds: 700));
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _esperarVisible(tester, finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _esperarVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final limite = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure(
    'No se encontro el elemento esperado en ${timeout.inSeconds}s.',
  );
}

Future<void> _bombearDurante(
  WidgetTester tester,
  Duration duracion,
) async {
  final limite = DateTime.now().add(duracion);
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

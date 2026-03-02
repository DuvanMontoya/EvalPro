/// @archivo   ExamenProvider.dart
/// @descripcion Gestiona examen activo, respuestas locales, telemetria y envio final.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../Modelos/Enums/ModalidadExamen.dart';
import '../Modelos/Enums/TipoPregunta.dart';
import '../Modelos/Enums/TipoEventoTelemetria.dart';
import '../Modelos/Pregunta.dart';
import '../Modelos/RespuestaLocal.dart';
import '../Modelos/ResultadoFinal.dart';
import '../Modelos/SesionExamen.dart';
import '../Utilidades/AleatorizadorLocal.dart';
import 'Modelos/ExamenActivoEstado.dart';
import 'AutenticacionProvider.dart';
import 'ConectividadProvider.dart';
import 'ModoExamenProvider.dart';

part 'ExamenProvider.g.dart';

@riverpod
class ExamenActivo extends _$ExamenActivo {
  @override
  ExamenActivoEstado? build() => null;

  /// Inicia examen: crea intento, descarga examen, aleatoriza, guarda y activa kiosco.
  Future<void> iniciarExamen(SesionExamen sesion) async {
    final idEstudiante = ref.read(autenticacionEstadoProvider).usuario?.id;
    if (idEstudiante == null) {
      throw StateError('No hay estudiante autenticado');
    }

    final intento = await ref.read(intentoServicioProvider).iniciar(sesion.id);
    final examenBase =
        await ref.read(examenServicioProvider).obtenerParaIntento(intento.id);
    final semillaPersonal =
        calcularSemillaPersonal(sesion.semillaGrupo, idEstudiante);
    final preguntasMezcladas = AleatorizadorLocal(semillaPersonal)
        .aleatorizar<Pregunta>(examenBase.preguntas)
        .asMap()
        .entries
        .map((entrada) {
      final orden = entrada.key + 1;
      final pregunta = entrada.value;
      final opcionesMezcladas = AleatorizadorLocal(semillaPersonal + orden)
          .aleatorizar(pregunta.opciones);
      return pregunta.copyWith(opciones: opcionesMezcladas);
    }).toList();

    final examenAleatorizado =
        examenBase.copyWith(preguntas: preguntasMezcladas);
    await ref.read(examenDaoProvider).guardarExamen(
          id: examenAleatorizado.id,
          contenidoJson: jsonEncode(examenAleatorizado.toJson()),
          idSesion: sesion.id,
          idIntento: intento.id,
          fechaDescarga: DateTime.now().millisecondsSinceEpoch,
        );

    final modo = ref.read(modoExamenServicioProvider);
    modo.iniciarMonitoreo(intento.id);
    await modo.activarModoKiosco();
    await ref.read(telemetriaServicioProvider).registrarEvento(
          idIntento: intento.id,
          tipo: TipoEventoTelemetria.INICIO_EXAMEN,
        );

    final ahora = DateTime.now();
    state = ExamenActivoEstado(
      examen: examenAleatorizado,
      preguntasAleatorizadas: preguntasMezcladas,
      indicePreguntaActual: 0,
      respuestasLocales: <String, RespuestaLocal>{},
      tiempoInicioExamen: ahora,
      tiempoInicioPreguntaActual: ahora,
      estaEnviando: false,
      errorEnvio: null,
      idIntento: intento.id,
    );
  }

  /// Guarda una respuesta local y sincroniza inmediato si hay internet.
  Future<void> registrarRespuesta(String idPregunta, Object valor) async {
    final actual = state;
    if (actual == null) return;
    final pregunta = actual.preguntasAleatorizadas
        .firstWhere((dato) => dato.id == idPregunta);
    final segundos =
        DateTime.now().difference(actual.tiempoInicioPreguntaActual).inSeconds;
    final esAbierta = pregunta.tipo == TipoPregunta.RESPUESTA_ABIERTA;
    final opciones = esAbierta
        ? <String>[]
        : valor is List<String>
            ? valor
            : valor is String
                ? <String>[valor]
                : <String>[];
    final texto = esAbierta && valor is String ? valor : null;
    final respuesta = RespuestaLocal(
      id: '${actual.idIntento}_$idPregunta',
      idIntento: actual.idIntento,
      idPregunta: idPregunta,
      valorTexto: texto,
      opcionesSeleccionadas: opciones,
      tiempoRespuesta: segundos,
      fechaRespuesta: DateTime.now(),
      esSincronizada: false,
      reintentosSincronizacion: 0,
    );

    await ref.read(respuestaDaoProvider).guardarRespuesta(respuesta);
    final nuevas = Map<String, RespuestaLocal>.from(actual.respuestasLocales)
      ..[idPregunta] = respuesta;
    state = actual.copyWith(respuestasLocales: nuevas);
    await ref.read(telemetriaServicioProvider).registrarEvento(
          idIntento: actual.idIntento,
          tipo: TipoEventoTelemetria.RESPUESTA_GUARDADA,
          numeroPregunta: actual.indicePreguntaActual + 1,
          tiempoTranscurrido: segundos,
        );
    if (ref.read(conectividadEstadoProvider)) {
      await ref
          .read(respuestaServicioProvider)
          .sincronizarLote(actual.idIntento, <RespuestaLocal>[respuesta]);
      await ref
          .read(respuestaDaoProvider)
          .marcarSincronizadas(<String>[respuesta.id]);
    }
  }

  /// Avanza a la siguiente pregunta y registra telemetria de cambio.
  Future<void> avanzarPregunta() async {
    final actual = state;
    if (actual == null ||
        actual.indicePreguntaActual >= actual.preguntasAleatorizadas.length - 1)
      return;
    state = actual.copyWith(
      indicePreguntaActual: actual.indicePreguntaActual + 1,
      tiempoInicioPreguntaActual: DateTime.now(),
    );
    await ref.read(telemetriaServicioProvider).registrarEvento(
          idIntento: actual.idIntento,
          tipo: TipoEventoTelemetria.CAMBIO_PREGUNTA,
          numeroPregunta: actual.indicePreguntaActual + 2,
        );
  }

  void retrocederPregunta() {
    final actual = state;
    if (actual == null || actual.indicePreguntaActual <= 0) return;
    state = actual.copyWith(
        indicePreguntaActual: actual.indicePreguntaActual - 1,
        tiempoInicioPreguntaActual: DateTime.now());
  }

  void irAPregunta(int indicePregunta) {
    final actual = state;
    if (actual == null) return;
    final permite = actual.examen.permitirNavegacion ||
        actual.examen.modalidad == ModalidadExamen.HOJA_RESPUESTAS;
    if (!permite ||
        indicePregunta < 0 ||
        indicePregunta >= actual.preguntasAleatorizadas.length) return;
    state = actual.copyWith(
        indicePreguntaActual: indicePregunta,
        tiempoInicioPreguntaActual: DateTime.now());
  }

  Future<ResultadoFinal?> finalizarYEnviar() async {
    final actual = state;
    if (actual == null) return null;
    state = actual.copyWith(estaEnviando: true, limpiarErrorEnvio: true);
    try {
      await ref
          .read(sincronizacionServicioProvider)
          .sincronizarPendientesAlRecuperarConexion();
      final resultado = await ref
          .read(respuestaServicioProvider)
          .finalizarIntento(actual.idIntento);
      await ref.read(modoExamenServicioProvider).desactivarModoKiosco();
      ref.read(modoExamenServicioProvider).detenerMonitoreo();
      await ref.read(examenDaoProvider).eliminarPorIntento(actual.idIntento);
      await ref.read(telemetriaServicioProvider).registrarEvento(
            idIntento: actual.idIntento,
            tipo: TipoEventoTelemetria.EXAMEN_ENVIADO,
          );
      state = null;
      return resultado.mostrarPuntaje ? resultado : null;
    } catch (error) {
      state = actual.copyWith(estaEnviando: false, errorEnvio: '$error');
      return null;
    }
  }
}

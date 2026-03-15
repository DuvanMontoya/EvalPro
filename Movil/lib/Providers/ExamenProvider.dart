/// @archivo   ExamenProvider.dart
/// @descripcion Gestiona examen activo, respuestas locales, telemetria y envio final.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02
import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../Constantes/Textos.dart';
import '../Modelos/Enums/RolUsuario.dart';
import '../Modelos/Enums/TipoPregunta.dart';
import '../Modelos/Enums/TipoEventoTelemetria.dart';
import '../Modelos/Pregunta.dart';
import '../Modelos/RespuestaLocal.dart';
import '../Modelos/ResultadoFinal.dart';
import '../Modelos/SesionExamen.dart';
import '../Utilidades/MapeadorErroresNegocio.dart';
import 'AutenticacionProvider.dart';
import 'ConectividadProvider.dart';
import 'Mixins/ExamenNavegacionMixin.dart';
import 'Modelos/ExamenActivoEstado.dart';
import 'ModoExamenProvider.dart';
part 'ExamenProvider.g.dart';

@Riverpod(keepAlive: true)
class ExamenActivo extends _$ExamenActivo with ExamenNavegacionMixin {
  Timer? _temporizadorPresencia;

  @override
  ExamenActivoEstado? build() {
    ref.onDispose(() {
      _detenerTemporizadorPresencia();
    });
    return null;
  }

  /// Inicia examen: crea intento, descarga examen, aleatoriza, guarda y activa kiosco.
  Future<void> iniciarExamen(SesionExamen sesion) async {
    final idEstudiante = ref.read(autenticacionEstadoProvider).usuario?.id;
    if (idEstudiante == null) {
      throw StateError('No hay estudiante autenticado');
    }
    final modo = ref.read(modoExamenServicioProvider);
    var kioscoActivado = false;
    var inicioCompleto = false;

    try {
      final bloqueoActivo = await modo.activarModoKiosco();
      if (!bloqueoActivo) {
        throw StateError(Textos.errorActivacionModoExamen);
      }
      kioscoActivado = true;

      final reporteIntegridad =
          await modo.obtenerReporteIntegridadDispositivo();
      final intento = await ref.read(intentoServicioProvider).iniciar(
            sesion.id,
            sesion.codigoAcceso,
            integridadDispositivo: reporteIntegridad.toJson(),
          );

      modo.iniciarMonitoreo(intento.id);
      final examenBase =
          await ref.read(examenServicioProvider).obtenerParaIntento(intento.id);
      final preguntasOrdenadas = List<Pregunta>.from(examenBase.preguntas);
      final examenAleatorizado =
          examenBase.copyWith(preguntas: preguntasOrdenadas);
      await ref.read(examenDaoProvider).guardarExamen(
            id: examenAleatorizado.id,
            contenidoJson: jsonEncode(examenAleatorizado.toJson()),
            idSesion: sesion.id,
            idIntento: intento.id,
            fechaDescarga: DateTime.now().millisecondsSinceEpoch,
          );

      final ahora = DateTime.now();
      state = ExamenActivoEstado(
        examen: examenAleatorizado,
        preguntasAleatorizadas: preguntasOrdenadas,
        indicePreguntaActual: 0,
        respuestasLocales: <String, RespuestaLocal>{},
        tiempoInicioExamen: ahora,
        tiempoInicioPreguntaActual: ahora,
        estaEnviando: false,
        errorEnvio: null,
        idIntento: intento.id,
      );
      await ref.read(socketServicioProvider).conectar(
            idSesion: sesion.id,
            rol: RolUsuario.ESTUDIANTE.name,
          );
      // Pulso inicial para que el monitor docente refleje presencia en tiempo real.
      ref.read(socketServicioProvider).emitirProgreso(
            idIntento: intento.id,
            idEstudiante: idEstudiante,
            respondidas: 0,
            total: preguntasOrdenadas.length,
            preguntasRespondidasIndices: const <int>[],
            indicePreguntaActual: 1,
          );
      _iniciarTemporizadorPresencia();
      await ref.read(telemetriaServicioProvider).registrarEvento(
            idIntento: intento.id,
            tipo: TipoEventoTelemetria.INICIO_EXAMEN,
          );

      inicioCompleto = true;
    } catch (_) {
      if (!inicioCompleto) {
        modo.detenerMonitoreo();
        if (kioscoActivado) {
          await modo.desactivarModoKiosco();
        }
      }
      rethrow;
    }
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
    final respuestaPrevia = actual.respuestasLocales[idPregunta];
    if (respuestaPrevia != null &&
        respuestaPrevia.valorTexto == texto &&
        _listasIguales(respuestaPrevia.opcionesSeleccionadas, opciones)) {
      return;
    }

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
    ref.read(socketServicioProvider).emitirProgreso(
          idIntento: actual.idIntento,
          idEstudiante: ref.read(autenticacionEstadoProvider).usuario?.id,
          respondidas: nuevas.length,
          total: actual.preguntasAleatorizadas.length,
          preguntasRespondidasIndices: _obtenerIndicesRespondidos(
            actual.copyWith(respuestasLocales: nuevas),
          ),
          indicePreguntaActual: actual.indicePreguntaActual + 1,
        );
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
      ref.read(socketServicioProvider).desconectar();
      _detenerTemporizadorPresencia();
      await ref.read(examenDaoProvider).eliminarPorIntento(actual.idIntento);
      await ref.read(telemetriaServicioProvider).registrarEvento(
            idIntento: actual.idIntento,
            tipo: TipoEventoTelemetria.EXAMEN_ENVIADO,
          );
      state = null;
      return resultado.mostrarPuntaje ? resultado : null;
    } catch (error) {
      state = actual.copyWith(
        estaEnviando: false,
        errorEnvio: MapeadorErroresNegocio.mapear(
          error,
          mensajePorDefecto: Textos.errorEnvioExamen,
        ),
      );
      return null;
    }
  }

  void _iniciarTemporizadorPresencia() {
    _detenerTemporizadorPresencia();
    _temporizadorPresencia = Timer.periodic(const Duration(seconds: 15), (_) {
      final actual = state;
      if (actual == null) {
        _detenerTemporizadorPresencia();
        return;
      }

      ref.read(socketServicioProvider).emitirProgreso(
            idIntento: actual.idIntento,
            idEstudiante: ref.read(autenticacionEstadoProvider).usuario?.id,
            respondidas: actual.respuestasLocales.length,
            total: actual.preguntasAleatorizadas.length,
            preguntasRespondidasIndices: _obtenerIndicesRespondidos(actual),
            indicePreguntaActual: actual.indicePreguntaActual + 1,
          );
    });
  }

  void _detenerTemporizadorPresencia() {
    _temporizadorPresencia?.cancel();
    _temporizadorPresencia = null;
  }

  List<int> _obtenerIndicesRespondidos(ExamenActivoEstado estado) {
    final idsRespondidas = estado.respuestasLocales.keys.toSet();
    final indices = <int>[];
    for (var indice = 0;
        indice < estado.preguntasAleatorizadas.length;
        indice++) {
      final idPregunta = estado.preguntasAleatorizadas[indice].id;
      if (idsRespondidas.contains(idPregunta)) {
        indices.add(indice + 1);
      }
    }
    return indices;
  }

  bool _listasIguales(List<String> izquierda, List<String> derecha) {
    if (izquierda.length != derecha.length) {
      return false;
    }
    for (var indice = 0; indice < izquierda.length; indice++) {
      if (izquierda[indice] != derecha[indice]) {
        return false;
      }
    }
    return true;
  }
}

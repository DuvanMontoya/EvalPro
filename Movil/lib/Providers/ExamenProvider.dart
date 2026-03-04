/// @archivo   ExamenProvider.dart
/// @descripcion Gestiona examen activo, respuestas locales, telemetria y envio final.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02
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
import '../Utilidades/AleatorizadorLocal.dart';
import '../Utilidades/MapeadorErroresNegocio.dart';
import 'AutenticacionProvider.dart';
import 'ConectividadProvider.dart';
import 'Mixins/ExamenNavegacionMixin.dart';
import 'Modelos/ExamenActivoEstado.dart';
import 'ModoExamenProvider.dart';
part 'ExamenProvider.g.dart';

@Riverpod(keepAlive: true)
class ExamenActivo extends _$ExamenActivo with ExamenNavegacionMixin {
  @override
  ExamenActivoEstado? build() => null;

  /// Inicia examen: crea intento, descarga examen, aleatoriza, guarda y activa kiosco.
  Future<void> iniciarExamen(SesionExamen sesion) async {
    final idEstudiante = ref.read(autenticacionEstadoProvider).usuario?.id;
    if (idEstudiante == null) {
      throw StateError('No hay estudiante autenticado');
    }
    final intento = await ref
        .read(intentoServicioProvider)
        .iniciar(sesion.id, sesion.codigoAcceso);
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
    await ref.read(socketServicioProvider).conectar(
          idSesion: sesion.id,
          rol: RolUsuario.ESTUDIANTE.name,
        );
    // Pulso inicial para que el monitor docente refleje presencia en tiempo real.
    ref.read(socketServicioProvider).emitirProgreso(
          idIntento: intento.id,
          respondidas: 0,
          total: preguntasMezcladas.length,
        );
    await ref.read(telemetriaServicioProvider).registrarEvento(
          idIntento: intento.id,
          tipo: TipoEventoTelemetria.INICIO_EXAMEN,
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
    ref.read(socketServicioProvider).emitirProgreso(
          idIntento: actual.idIntento,
          respondidas: nuevas.length,
          total: actual.preguntasAleatorizadas.length,
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
}

/// @archivo   ExamenNavegacionMixin.dart
/// @descripcion Encapsula navegacion entre preguntas y telemetria asociada del examen activo.
/// @modulo    Providers/Mixins
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:riverpod/riverpod.dart';

import '../../Modelos/Enums/ModalidadExamen.dart';
import '../../Modelos/Enums/TipoEventoTelemetria.dart';
import '../AutenticacionProvider.dart';
import '../Modelos/ExamenActivoEstado.dart';

mixin ExamenNavegacionMixin on Notifier<ExamenActivoEstado?> {
  /// Avanza a la siguiente pregunta y registra telemetria de cambio.
  Future<void> avanzarPregunta() async {
    final actual = state;
    if (actual == null ||
        actual.indicePreguntaActual >=
            actual.preguntasAleatorizadas.length - 1) {
      return;
    }
    state = actual.copyWith(
      indicePreguntaActual: actual.indicePreguntaActual + 1,
      tiempoInicioPreguntaActual: DateTime.now(),
    );
    _emitirPulsoNavegacion(state);
    await ref.read(telemetriaServicioProvider).registrarEvento(
          idIntento: actual.idIntento,
          tipo: TipoEventoTelemetria.EVALUACION_ABIERTA,
          numeroPregunta: actual.indicePreguntaActual + 2,
        );
  }

  /// Retrocede una pregunta cuando existe una anterior.
  void retrocederPregunta() {
    final actual = state;
    if (actual == null || actual.indicePreguntaActual <= 0) return;
    state = actual.copyWith(
      indicePreguntaActual: actual.indicePreguntaActual - 1,
      tiempoInicioPreguntaActual: DateTime.now(),
    );
    _emitirPulsoNavegacion(state);
  }

  /// Permite ir a una pregunta especifica si la navegacion esta habilitada.
  void irAPregunta(int indicePregunta) {
    final actual = state;
    if (actual == null) return;
    final permite = actual.examen.permitirNavegacion ||
        actual.examen.modalidad == ModalidadExamen.SOLO_RESPUESTAS;
    if (!permite ||
        indicePregunta < 0 ||
        indicePregunta >= actual.preguntasAleatorizadas.length) return;
    state = actual.copyWith(
      indicePreguntaActual: indicePregunta,
      tiempoInicioPreguntaActual: DateTime.now(),
    );
    _emitirPulsoNavegacion(state);
  }

  void _emitirPulsoNavegacion(ExamenActivoEstado? estadoActualizado) {
    final estado = estadoActualizado;
    if (estado == null) {
      return;
    }

    final idsRespondidas = estado.respuestasLocales.keys.toSet();
    final indicesRespondidos = <int>[];
    for (var indice = 0; indice < estado.preguntasAleatorizadas.length; indice++) {
      final idPregunta = estado.preguntasAleatorizadas[indice].id;
      if (idsRespondidas.contains(idPregunta)) {
        indicesRespondidos.add(indice + 1);
      }
    }

    ref.read(socketServicioProvider).emitirProgreso(
          idIntento: estado.idIntento,
          idEstudiante: ref.read(autenticacionEstadoProvider).usuario?.id,
          respondidas: indicesRespondidos.length,
          total: estado.preguntasAleatorizadas.length,
          preguntasRespondidasIndices: indicesRespondidos,
          indicePreguntaActual: estado.indicePreguntaActual + 1,
        );
  }
}

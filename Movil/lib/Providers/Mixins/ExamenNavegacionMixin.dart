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

mixin ExamenNavegacionMixin on AutoDisposeNotifier<ExamenActivoEstado?> {
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
    await ref.read(telemetriaServicioProvider).registrarEvento(
          idIntento: actual.idIntento,
          tipo: TipoEventoTelemetria.CAMBIO_PREGUNTA,
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
  }

  /// Permite ir a una pregunta especifica si la navegacion esta habilitada.
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
      tiempoInicioPreguntaActual: DateTime.now(),
    );
  }
}

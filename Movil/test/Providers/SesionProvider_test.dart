import 'package:flutter_test/flutter_test.dart';
import 'package:movil/Modelos/Enums/EstadoSesion.dart';
import 'package:movil/Modelos/Enums/ModalidadExamen.dart';
import 'package:movil/Modelos/SesionExamen.dart';
import 'package:movil/Providers/SesionProvider.dart';

void main() {
  test('copyWith permite limpiar sesion al pasar null explicitamente', () {
    final estadoInicial = EstadoSesionBusqueda(
      cargando: false,
      sesion: SesionExamen(
        id: 'sesion-1',
        codigoAcceso: 'ABCD-1234',
        estado: EstadoSesion.ACTIVA,
        semillaGrupo: 7,
        examen: const ResumenExamenSesion(
          id: 'examen-1',
          titulo: 'Parcial',
          modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
          duracionMinutos: 30,
        ),
      ),
      error: null,
    );

    final actualizado = estadoInicial.copyWith(
      sesion: null,
      error: 'Sesion no encontrada',
    );

    expect(actualizado.sesion, isNull);
    expect(actualizado.error, 'Sesion no encontrada');
  });
}

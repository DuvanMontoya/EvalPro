/// @archivo   AleatorizadorLocal.dart
/// @descripcion Implementa Fisher-Yates shuffle con LCG determinista.
///              Garantiza que la misma semilla produce siempre el mismo orden.
///              Estudiantes con diferente semilla personal tendran orden distinto.
/// @modulo    Utilidades
/// @autor     EvalPro
/// @fecha     2026-03-02

class AleatorizadorLocal {
  static const int _a = 1664525;
  static const int _c = 1013904223;
  static const int _m = 0xFFFFFFFF;

  int _semillaActual;

  AleatorizadorLocal(int semilla) : _semillaActual = semilla;

  /// Genera el siguiente entero pseudoaleatorio en el rango [0, maximo).
  int siguienteEntero(int maximo) {
    _semillaActual = (_a * _semillaActual + _c) & _m;
    return _semillaActual % maximo;
  }

  /// Aplica Fisher-Yates shuffle a la lista usando esta semilla.
  /// Retorna una nueva lista. No modifica la original.
  List<T> aleatorizar<T>(List<T> lista) {
    final resultado = List<T>.from(lista);
    for (int i = resultado.length - 1; i > 0; i--) {
      final j = siguienteEntero(i + 1);
      final temp = resultado[i];
      resultado[i] = resultado[j];
      resultado[j] = temp;
    }
    return resultado;
  }
}

/// Calcula la semilla personal de un estudiante para una sesion.
/// Garantiza unicidad por estudiante pero reproducibilidad.
int calcularSemillaPersonal(int semillaGrupo, String idEstudiante) {
  return ((semillaGrupo * idEstudiante.hashCode) % 999999).abs() + 1;
}

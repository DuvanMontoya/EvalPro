/// @archivo   BotonRespuestaOMR.dart
/// @descripcion Dibuja una opcion OMR tactil con tamano minimo de 44x44 pixeles.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import '../../../Constantes/Colores.dart';
import '../../../Constantes/Dimensiones.dart';

class BotonRespuestaOMR extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final bool seleccionada;
  final VoidCallback alPresionar;

  const BotonRespuestaOMR({
    super.key,
    required this.valor,
    required this.etiqueta,
    required this.seleccionada,
    required this.alPresionar,
  });

  /// Construye boton OMR cumpliendo tamano minimo de accesibilidad.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: etiqueta.length > 1 ? 108 : Dimensiones.tamanoMinimoBotonOmar,
      height: Dimensiones.tamanoMinimoBotonOmar,
      child: OutlinedButton(
        onPressed: alPresionar,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              seleccionada ? Colores.azulPrimario : Colors.transparent,
          foregroundColor: seleccionada ? Colors.white : Colores.textoPrincipal,
          side: BorderSide(
              color: seleccionada ? Colores.azulPrimario : Colores.grisBorde),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          etiqueta,
          semanticsLabel: valor == 'E' ? 'No lo sé' : etiqueta,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: etiqueta.length > 1 ? 12 : 14,
          ),
        ),
      ),
    );
  }
}

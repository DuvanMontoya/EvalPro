/// @archivo   TarjetaSesionDisponible.dart
/// @descripcion Presenta resumen de sesion encontrada y accion para unirse al examen.
/// @modulo    Pantallas/Inicio/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import '../../../Constantes/Colores.dart';
import '../../../Constantes/Dimensiones.dart';
import '../../../Modelos/SesionExamen.dart';

class TarjetaSesionDisponible extends StatelessWidget {
  final SesionExamen sesion;
  final VoidCallback alUnirse;

  const TarjetaSesionDisponible({
    super.key,
    required this.sesion,
    required this.alUnirse,
  });

  /// Construye tarjeta compacta con datos de la sesion activa.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              sesion.examen.titulo,
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Dimensiones.espaciadoSm),
            Text(
              'Modalidad: ${sesion.examen.modalidad.name}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Duracion: ${sesion.examen.duracionMinutos} min',
              style: textTheme.bodyMedium,
            ),
            if (sesion.examen.docente != null)
              Text(
                'Docente: ${sesion.examen.docente}',
                style: textTheme.bodyMedium,
              ),
            const SizedBox(height: Dimensiones.espaciadoLg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: alUnirse,
                icon: const Icon(Icons.login_rounded),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.azulPrimario,
                ),
                label: const Text('Unirse'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

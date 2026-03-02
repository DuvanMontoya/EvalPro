/// @archivo   TarjetaSesionDisponible.dart
/// @descripcion Presenta resumen de sesion encontrada y accion para unirse al examen.
/// @modulo    Pantallas/Inicio/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(sesion.examen.titulo,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Modalidad: ${sesion.examen.modalidad.name}'),
            Text('Duracion: ${sesion.examen.duracionMinutos} min'),
            if (sesion.examen.docente != null)
              Text('Docente: ${sesion.examen.docente}'),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: alUnirse, child: const Text('Unirse')),
          ],
        ),
      ),
    );
  }
}

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
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensiones.espaciadoSm,
                    vertical: Dimensiones.espaciadoXs,
                  ),
                  decoration: BoxDecoration(
                    color: Colores.verdeExito.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Dimensiones.radioSm),
                  ),
                  child: Text(
                    'SESION ACTIVA',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colores.verdeExito,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colores.azulPrimario.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: Dimensiones.espaciadoMd),
            Text(
              sesion.examen.titulo,
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: Dimensiones.espaciadoMd),
            _DatoSesion(
              icono: Icons.grid_view_rounded,
              etiqueta: 'Modalidad',
              valor: sesion.examen.modalidad.name,
            ),
            _DatoSesion(
              icono: Icons.timer_outlined,
              etiqueta: 'Duracion',
              valor: '${sesion.examen.duracionMinutos} min',
            ),
            if (sesion.examen.docente != null)
              _DatoSesion(
                icono: Icons.person_outline_rounded,
                etiqueta: 'Docente',
                valor: sesion.examen.docente!,
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

class _DatoSesion extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _DatoSesion({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciadoSm),
      child: Row(
        children: <Widget>[
          Icon(icono, size: 18, color: Colores.textoSecundario),
          const SizedBox(width: Dimensiones.espaciadoSm),
          Text(
            '$etiqueta: ',
            style: textTheme.bodyMedium?.copyWith(
              color: Colores.textoSecundario,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: textTheme.bodyMedium?.copyWith(
                color: Colores.textoPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

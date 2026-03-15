/// @archivo   TarjetaSesionDisponible.dart
/// @descripcion Presenta resumen de sesion encontrada y accion para unirse al examen.
/// @modulo    Pantallas/Inicio/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import '../../../Constantes/Dimensiones.dart';
import '../../../Modelos/Enums/ModalidadExamen.dart';
import '../../../Modelos/SesionExamen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common/eval_badge.dart';
import '../../../core/widgets/common/eval_surface.dart';

class TarjetaSesionDisponible extends StatelessWidget {
  const TarjetaSesionDisponible({
    super.key,
    required this.sesion,
    required this.alUnirse,
    this.cargando = false,
  });

  final SesionExamen sesion;
  final VoidCallback alUnirse;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    return EvalSectionCard(
      key: ValueKey<String>('session_result_card_${sesion.id}'),
      title: sesion.examen.titulo,
      subtitle: 'Sesión validada y lista para iniciar.',
      trailing: const EvalBadge(
        'Sesión activa',
        variant: EvalBadgeVariant.success,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: Dimensiones.espaciadoSm,
            runSpacing: Dimensiones.espaciadoSm,
            children: <Widget>[
              _TagDato(
                icono: Icons.grid_view_rounded,
                texto: _resolverEtiquetaModalidad(sesion.examen.modalidad),
              ),
              _TagDato(
                icono: Icons.timer_outlined,
                texto: '${sesion.examen.duracionMinutos} min',
              ),
              if (sesion.examen.identificadorCuadernillo != null)
                _TagDato(
                  icono: Icons.badge_outlined,
                  texto: sesion.examen.identificadorCuadernillo!,
                ),
              if (sesion.examen.docente != null)
                _TagDato(
                  icono: Icons.person_outline_rounded,
                  texto: sesion.examen.docente!,
                ),
            ],
          ),
          const SizedBox(height: Dimensiones.espaciadoLg),
          EvalHeroCard(
            eyebrow: 'Código confirmado',
            title: sesion.codigoAcceso,
            subtitle:
                'Todo está preparado para iniciar el intento en esta sesión.',
            icon: const Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: Dimensiones.espaciadoLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: ValueKey<String>('session_join_button_${sesion.id}'),
              onPressed: cargando ? null : alUnirse,
              icon: cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(cargando ? 'Preparando...' : 'Unirse'),
            ),
          ),
        ],
      ),
    );
  }

  String _resolverEtiquetaModalidad(ModalidadExamen modalidad) {
    if (modalidad == ModalidadExamen.HOJA_RESPUESTAS) {
      return 'Solo respuestas';
    }
    return 'Contenido completo';
  }
}

class _TagDato extends StatelessWidget {
  const _TagDato({
    required this.icono,
    required this.texto,
  });

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensiones.espaciadoMd,
        vertical: Dimensiones.espaciadoSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(Dimensiones.radioLg),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icono, size: 16, color: AppColors.slate600),
          const SizedBox(width: Dimensiones.espaciadoSm),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.slate700,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

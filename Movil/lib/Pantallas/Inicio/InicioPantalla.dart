/// @archivo   InicioPantalla.dart
/// @descripcion Muestra accesos principales para unirse a sesiones y cerrar sesion.
/// @modulo    Pantallas/Inicio
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/eval_avatar.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_card.dart';
import '../../core/widgets/common/eval_surface.dart';

class InicioPantalla extends ConsumerWidget {
  const InicioPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(autenticacionEstadoProvider).usuario;
    final rol = usuario?.rol;
    final esEstudiante = rol == RolUsuario.ESTUDIANTE;
    final esSuperadmin = rol == RolUsuario.SUPERADMINISTRADOR;
    final puedeGestionarInstituciones =
        rol == RolUsuario.SUPERADMINISTRADOR || rol == RolUsuario.ADMINISTRADOR;
    final puedeGestionarUsuarios =
        rol == RolUsuario.ADMINISTRADOR || rol == RolUsuario.SUPERADMINISTRADOR;
    final puedeGestionarGrupos = rol == RolUsuario.ADMINISTRADOR ||
        rol == RolUsuario.SUPERADMINISTRADOR ||
        rol == RolUsuario.DOCENTE;
    final puedeGestionarPeriodos =
        rol == RolUsuario.ADMINISTRADOR || rol == RolUsuario.SUPERADMINISTRADOR;
    final puedeGestionarReclamos = rol == RolUsuario.DOCENTE ||
        rol == RolUsuario.ADMINISTRADOR ||
        rol == RolUsuario.SUPERADMINISTRADOR;
    final puedeCalificarManual =
        rol == RolUsuario.DOCENTE || rol == RolUsuario.ADMINISTRADOR;

    final accionesAcademicas = <_AccionInicio>[
      _AccionInicio(
        etiqueta: Textos.gestionarSesiones,
        descripcion: 'Activa, supervisa y cierra sesiones con control total.',
        icono: Icons.event_note_outlined,
        onPressed: () => context.go(Rutas.gestionSesiones),
        esPrimaria: true,
        clavePrueba: const Key('inicio_manage_sessions_button'),
      ),
      _AccionInicio(
        etiqueta: Textos.gestionarExamenes,
        descripcion: 'Organiza bancos, estados y publicación.',
        icono: Icons.menu_book_outlined,
        onPressed: () => context.go(Rutas.gestionExamenes),
      ),
      if (puedeGestionarUsuarios)
        _AccionInicio(
          etiqueta: 'Usuarios',
          descripcion: 'Administra perfiles y permisos institucionales.',
          icono: Icons.manage_accounts_outlined,
          onPressed: () => context.go(Rutas.gestionUsuarios),
        ),
      if (puedeGestionarGrupos)
        _AccionInicio(
          etiqueta: Textos.gestionarGrupos,
          descripcion: 'Mantén grupos, docentes y matrículas alineados.',
          icono: Icons.groups_2_outlined,
          onPressed: () => context.go(Rutas.gestionGrupos),
        ),
      if (puedeGestionarPeriodos)
        _AccionInicio(
          etiqueta: Textos.gestionarPeriodos,
          descripcion: 'Controla ciclos y disponibilidad académica.',
          icono: Icons.calendar_month_outlined,
          onPressed: () => context.go(Rutas.gestionPeriodos),
        ),
      if (puedeGestionarInstituciones)
        _AccionInicio(
          etiqueta: Textos.gestionarInstituciones,
          descripcion: 'Monitorea operación multi-tenant y estado global.',
          icono: Icons.apartment_outlined,
          onPressed: () => context.go(Rutas.gestionInstituciones),
        ),
      if (puedeGestionarReclamos)
        _AccionInicio(
          etiqueta: Textos.gestionarReclamos,
          descripcion: 'Resuelve revisiones con trazabilidad completa.',
          icono: Icons.support_agent_outlined,
          onPressed: () => context.go(Rutas.gestionReclamos),
        ),
      if (puedeCalificarManual)
        _AccionInicio(
          etiqueta: Textos.calificacionManual,
          descripcion: 'Evalúa abiertas y cierra pendientes manuales.',
          icono: Icons.rate_review_outlined,
          onPressed: () => context.go(Rutas.gestionCalificacionManual),
        ),
    ];

    return Scaffold(
      body: EvalPageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Dimensiones.espaciadoLg,
              Dimensiones.espaciadoLg,
              Dimensiones.espaciadoLg,
              Dimensiones.espaciado2xl,
            ),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        EvalAvatar(
                          name:
                              '${usuario?.nombre ?? 'Eval'} ${usuario?.apellidos ?? 'Pro'}',
                          size: EvalAvatarSize.lg,
                          isOnline: true,
                        ),
                        const SizedBox(width: Dimensiones.espaciadoMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'EvalPro',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _descripcionRol(rol),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.slate500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    key: const Key('inicio_logout_button'),
                    tooltip: Textos.cerrarSesion,
                    onPressed: () async {
                      await ref
                          .read(autenticacionEstadoProvider.notifier)
                          .cerrarSesion();
                      if (context.mounted) {
                        context.go(Rutas.iniciarSesion);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
              const SizedBox(height: Dimensiones.espaciadoXl),
              EvalPageHeader(
                eyebrow: _eyebrowRol(rol),
                title: 'Hola, ${usuario?.nombre ?? 'Usuario'}',
                subtitle: esEstudiante
                    ? 'Encuentra tus evaluaciones activas, resultados y accesos rápidos en un espacio limpio y enfocado.'
                    : 'Controla la operación académica con accesos claros a las áreas críticas de la institución.',
                trailing: EvalBadge(
                  _etiquetaRol(rol),
                  variant: esEstudiante
                      ? EvalBadgeVariant.success
                      : EvalBadgeVariant.primary,
                ),
              ),
              const SizedBox(height: Dimensiones.espaciadoXl),
              EvalHeroCard(
                eyebrow: esEstudiante ? 'Tu jornada' : 'Centro de control',
                title: esEstudiante
                    ? 'Panel del estudiante'
                    : esSuperadmin
                        ? 'Operacion global'
                        : 'Gestion academica',
                subtitle: esEstudiante
                    ? 'Ingresa a sesiones activas, revisa resultados publicados y mantén tu progreso al alcance.'
                    : 'Supervisa sesiones, exámenes, usuarios y operación institucional desde un panel priorizado.',
                icon: Icon(
                  esEstudiante
                      ? Icons.school_rounded
                      : Icons.dashboard_customize_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                footer: Wrap(
                  spacing: Dimensiones.espaciadoSm,
                  runSpacing: Dimensiones.espaciadoSm,
                  children: <Widget>[
                    _ResumenHero(
                      icono: Icons.verified_user_outlined,
                      texto: 'Acceso protegido',
                    ),
                    _ResumenHero(
                      icono: Icons.auto_graph_rounded,
                      texto: esEstudiante
                          ? 'Seguimiento de resultados'
                          : 'Gestión priorizada',
                    ),
                    _ResumenHero(
                      icono: Icons.bolt_rounded,
                      texto: 'Acciones rápidas',
                    ),
                  ],
                ),
              ),
              if (!esEstudiante &&
                  (puedeGestionarUsuarios || puedeGestionarInstituciones)) ...<Widget>[
                const SizedBox(height: Dimensiones.espaciadoLg),
                Wrap(
                  spacing: Dimensiones.espaciadoSm,
                  runSpacing: Dimensiones.espaciadoSm,
                  children: <Widget>[
                    if (puedeGestionarUsuarios)
                      OutlinedButton.icon(
                        onPressed: () => context.go(Rutas.gestionUsuarios),
                        icon: const Icon(Icons.manage_accounts_outlined),
                        label: const Text(Textos.gestionarUsuarios),
                      ),
                    if (puedeGestionarInstituciones)
                      OutlinedButton.icon(
                        onPressed: () => context.go(Rutas.gestionInstituciones),
                        icon: const Icon(Icons.apartment_outlined),
                        label: const Text('Instituciones'),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: Dimensiones.espaciadoXl),
              if (esEstudiante)
                _BloqueAcciones(
                  titulo: 'Tu espacio de evaluacion',
                  descripcion:
                      'Entra a una sesión activa o revisa tus resultados publicados.',
                  acciones: <_AccionInicio>[
                    _AccionInicio(
                      etiqueta: 'Unirse a una sesion',
                      descripcion: 'Ingresa con código y continúa tu examen.',
                      icono: Icons.how_to_reg_rounded,
                      onPressed: () => context.go(Rutas.unirseExamen),
                      esPrimaria: true,
                      clavePrueba: const Key('inicio_join_session_button'),
                    ),
                    _AccionInicio(
                      etiqueta: Textos.misResultados,
                      descripcion: 'Consulta puntajes, estados y reclamos.',
                      icono: Icons.grading_rounded,
                      onPressed: () => context.go(Rutas.resultadosEstudiante),
                    ),
                  ],
                ),
              if (accionesAcademicas.isNotEmpty)
                _BloqueAcciones(
                  titulo: esSuperadmin
                      ? 'Operacion global'
                      : 'Gestion academica',
                  descripcion: esSuperadmin
                      ? 'Supervisa instituciones, usuarios, periodos y toda la operación multi-tenant.'
                      : 'Administra sesiones, exámenes y el funcionamiento académico desde una sola vista.',
                  acciones: accionesAcademicas,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _descripcionRol(RolUsuario? rol) {
    return switch (rol) {
      RolUsuario.ESTUDIANTE => 'Espacio personal de evaluación',
      RolUsuario.DOCENTE => 'Herramientas docentes y monitoreo',
      RolUsuario.ADMINISTRADOR => 'Operación institucional',
      RolUsuario.SUPERADMINISTRADOR => 'Supervisión multi-tenant',
      null => 'Panel móvil',
    };
  }

  static String _eyebrowRol(RolUsuario? rol) {
    return switch (rol) {
      RolUsuario.ESTUDIANTE => 'Experiencia enfocada',
      RolUsuario.DOCENTE => 'Flujo docente',
      RolUsuario.ADMINISTRADOR => 'Control institucional',
      RolUsuario.SUPERADMINISTRADOR => 'Visión estratégica',
      null => 'Panel principal',
    };
  }

  static String _etiquetaRol(RolUsuario? rol) {
    return switch (rol) {
      RolUsuario.ESTUDIANTE => 'Estudiante',
      RolUsuario.DOCENTE => 'Docente',
      RolUsuario.ADMINISTRADOR => 'Administrador',
      RolUsuario.SUPERADMINISTRADOR => 'Superadmin',
      null => 'Usuario',
    };
  }
}

class _BloqueAcciones extends StatelessWidget {
  const _BloqueAcciones({
    required this.titulo,
    required this.descripcion,
    required this.acciones,
  });

  final String titulo;
  final String descripcion;
  final List<_AccionInicio> acciones;

  @override
  Widget build(BuildContext context) {
    return EvalSectionCard(
      title: titulo,
      subtitle: descripcion,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnas = constraints.maxWidth > 700
              ? 3
              : constraints.maxWidth > 480
                  ? 2
                  : 1;
          final totalSpacing =
              (columnas - 1) * Dimensiones.espaciadoMd;
          final ancho = (constraints.maxWidth - totalSpacing) / columnas;
          return Wrap(
            spacing: Dimensiones.espaciadoMd,
            runSpacing: Dimensiones.espaciadoMd,
            children: acciones
                .map(
                  (accion) => SizedBox(
                    width: ancho,
                    height: 176,
                    child: _TarjetaAccion(accion: accion),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _TarjetaAccion extends StatelessWidget {
  const _TarjetaAccion({
    required this.accion,
  });

  final _AccionInicio accion;

  @override
  Widget build(BuildContext context) {
    final highlight = accion.esPrimaria ? AppColors.primary : AppColors.info;
    return EvalCard(
      key: accion.clavePrueba,
      onTap: accion.onPressed,
      padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
      semanticLabel: accion.etiqueta,
      backgroundColor:
          accion.esPrimaria ? AppColors.primarySurface : Colors.white,
      borderColor:
          accion.esPrimaria ? AppColors.primaryBorder : AppColors.slate200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: highlight.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Dimensiones.radioLg),
            ),
            child: Icon(accion.icono, color: highlight, size: 24),
          ),
          const SizedBox(height: Dimensiones.espaciadoMd),
          Text(
            accion.etiqueta,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: Dimensiones.espaciadoXs),
          Expanded(
            child: Text(
              accion.descripcion,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: Dimensiones.espaciadoSm),
          Row(
            children: <Widget>[
              Text(
                'Abrir',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: highlight,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: Dimensiones.espaciadoXs),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: highlight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumenHero extends StatelessWidget {
  const _ResumenHero({
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
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Dimensiones.radioLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icono, size: 16, color: Colors.white),
          const SizedBox(width: Dimensiones.espaciadoSm),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _AccionInicio {
  const _AccionInicio({
    required this.etiqueta,
    required this.descripcion,
    required this.icono,
    required this.onPressed,
    this.esPrimaria = false,
    this.clavePrueba,
  });

  final String etiqueta;
  final String descripcion;
  final IconData icono;
  final VoidCallback onPressed;
  final bool esPrimaria;
  final Key? clavePrueba;
}

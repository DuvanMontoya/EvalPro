/// @archivo   InicioPantalla.dart
/// @descripcion Muestra accesos principales para unirse a sesiones y cerrar sesion.
/// @modulo    Pantallas/Inicio
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Colores.dart';
import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Providers/AutenticacionProvider.dart';

class InicioPantalla extends ConsumerWidget {
  const InicioPantalla({super.key});

  /// Construye panel de inicio para estudiante autenticado.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(autenticacionEstadoProvider).usuario;
    final rol = usuario?.rol;
    final esEstudiante = rol == RolUsuario.ESTUDIANTE;
    final puedeGestionarAcademico = rol == RolUsuario.DOCENTE ||
        rol == RolUsuario.ADMINISTRADOR ||
        rol == RolUsuario.SUPERADMINISTRADOR;
    final puedeGestionarInstituciones = rol == RolUsuario.SUPERADMINISTRADOR ||
        rol == RolUsuario.ADMINISTRADOR ||
        rol == RolUsuario.DOCENTE;
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

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF0F4FB), Color(0xFFF9FAFD)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columnaAmplia = constraints.maxWidth >= 960;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _EncabezadoInicio(
                          nombre: usuario?.nombre ?? 'Usuario',
                          rol: rol?.name ?? '-',
                          alCerrarSesion: () async {
                            await ref
                                .read(autenticacionEstadoProvider.notifier)
                                .cerrarSesion();
                            if (context.mounted) {
                              context.go(Rutas.iniciarSesion);
                            }
                          },
                        ),
                        const SizedBox(height: Dimensiones.espaciadoXl),
                        if (esEstudiante)
                          _SeccionAcciones(
                            titulo: 'Tu espacio de evaluacion',
                            descripcion:
                                'Ingresa a sesiones activas o revisa resultados publicados.',
                            acciones: <_AccionInicio>[
                              _AccionInicio(
                                etiqueta: 'Unirse a una sesion',
                                icono: Icons.how_to_reg_rounded,
                                onPressed: () => context.go(Rutas.unirseExamen),
                                esPrimaria: true,
                              ),
                              _AccionInicio(
                                etiqueta: Textos.misResultados,
                                icono: Icons.grading_rounded,
                                onPressed: () =>
                                    context.go(Rutas.resultadosEstudiante),
                              ),
                            ],
                            columnaAmplia: columnaAmplia,
                          ),
                        if (puedeGestionarAcademico) ...<Widget>[
                          _SeccionAcciones(
                            titulo: 'Gestion academica',
                            descripcion:
                                'Administra sesiones, examenes y operacion docente.',
                            acciones: <_AccionInicio>[
                              _AccionInicio(
                                etiqueta: Textos.gestionarSesiones,
                                icono: Icons.event_note_outlined,
                                onPressed: () =>
                                    context.go(Rutas.gestionSesiones),
                                esPrimaria: true,
                              ),
                              _AccionInicio(
                                etiqueta: Textos.gestionarExamenes,
                                icono: Icons.menu_book_outlined,
                                onPressed: () =>
                                    context.go(Rutas.gestionExamenes),
                              ),
                              if (puedeGestionarGrupos)
                                _AccionInicio(
                                  etiqueta: Textos.gestionarGrupos,
                                  icono: Icons.groups_2_outlined,
                                  onPressed: () =>
                                      context.go(Rutas.gestionGrupos),
                                ),
                              if (puedeGestionarPeriodos)
                                _AccionInicio(
                                  etiqueta: Textos.gestionarPeriodos,
                                  icono: Icons.calendar_month_outlined,
                                  onPressed: () =>
                                      context.go(Rutas.gestionPeriodos),
                                ),
                              if (puedeGestionarUsuarios)
                                _AccionInicio(
                                  etiqueta: Textos.gestionarUsuarios,
                                  icono: Icons.manage_accounts_outlined,
                                  onPressed: () =>
                                      context.go(Rutas.gestionUsuarios),
                                ),
                              if (puedeGestionarInstituciones)
                                _AccionInicio(
                                  etiqueta: Textos.gestionarInstituciones,
                                  icono: Icons.apartment_outlined,
                                  onPressed: () =>
                                      context.go(Rutas.gestionInstituciones),
                                ),
                              if (puedeGestionarReclamos)
                                _AccionInicio(
                                  etiqueta: Textos.gestionarReclamos,
                                  icono: Icons.support_agent_outlined,
                                  onPressed: () =>
                                      context.go(Rutas.gestionReclamos),
                                ),
                              if (puedeCalificarManual)
                                _AccionInicio(
                                  etiqueta: Textos.calificacionManual,
                                  icono: Icons.rate_review_outlined,
                                  onPressed: () => context
                                      .go(Rutas.gestionCalificacionManual),
                                ),
                            ],
                            columnaAmplia: columnaAmplia,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EncabezadoInicio extends StatelessWidget {
  final String nombre;
  final String rol;
  final Future<void> Function() alCerrarSesion;

  const _EncabezadoInicio({
    required this.nombre,
    required this.rol,
    required this.alCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensiones.radio2xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Colores.azulProfundo, Colores.azulPrimario],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colores.sombra,
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciadoXl),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colores.blanco.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(Dimensiones.radioLg),
              ),
              child: const Icon(
                Icons.account_circle_rounded,
                color: Colores.blanco,
                size: 34,
              ),
            ),
            const SizedBox(width: Dimensiones.espaciadoLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hola, $nombre',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colores.blanco,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoXs),
                  Text(
                    '${Textos.rolActual}: $rol',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colores.blanco.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              key: const Key('inicio_logout_button'),
              onPressed: alCerrarSesion,
              icon: const Icon(Icons.logout_rounded),
              label: const Text(Textos.cerrarSesion),
              style: FilledButton.styleFrom(
                foregroundColor: Colores.blanco,
                backgroundColor: Colores.blanco.withValues(alpha: 0.14),
                disabledBackgroundColor: Colores.blanco.withValues(alpha: 0.08),
                disabledForegroundColor: Colores.blanco.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensiones.espaciadoLg,
                  vertical: Dimensiones.espaciadoMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionAcciones extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final List<_AccionInicio> acciones;
  final bool columnaAmplia;

  const _SeccionAcciones({
    required this.titulo,
    required this.descripcion,
    required this.acciones,
    required this.columnaAmplia,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = columnaAmplia ? 3 : 1;
    final aspectRatio = columnaAmplia ? 2.4 : 2.9;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciadoXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              titulo,
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Dimensiones.espaciadoSm),
            Text(descripcion, style: textTheme.bodyMedium),
            const SizedBox(height: Dimensiones.espaciadoLg),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: acciones.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: Dimensiones.espaciadoMd,
                mainAxisSpacing: Dimensiones.espaciadoMd,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (_, index) =>
                  _TarjetaAccion(accion: acciones[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAccion extends StatelessWidget {
  final _AccionInicio accion;

  const _TarjetaAccion({required this.accion});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorTexto =
        accion.esPrimaria ? Colores.azulProfundo : Colores.textoPrincipal;

    return InkWell(
      borderRadius: BorderRadius.circular(Dimensiones.radioLg),
      onTap: accion.onPressed,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          gradient: accion.esPrimaria
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFE6EEFF), Color(0xFFE9F6FF)],
                )
              : null,
          color: accion.esPrimaria ? null : Colores.blanco,
          border: Border.all(
            color:
                accion.esPrimaria ? const Color(0xFFC4D7FF) : Colores.grisBorde,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensiones.espaciadoLg,
            vertical: Dimensiones.espaciadoMd,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensiones.radioMd),
                  color: accion.esPrimaria
                      ? Colores.azulPrimario.withValues(alpha: 0.16)
                      : Colores.grisFondoSecundario,
                ),
                child: Icon(
                  accion.icono,
                  color: accion.esPrimaria
                      ? Colores.azulPrimario
                      : Colores.textoSecundario,
                  size: 20,
                ),
              ),
              const SizedBox(width: Dimensiones.espaciadoMd),
              Expanded(
                child: Text(
                  accion.etiqueta,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorTexto,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: colorTexto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccionInicio {
  final String etiqueta;
  final IconData icono;
  final VoidCallback onPressed;
  final bool esPrimaria;

  const _AccionInicio({
    required this.etiqueta,
    required this.icono,
    required this.onPressed,
    this.esPrimaria = false,
  });
}

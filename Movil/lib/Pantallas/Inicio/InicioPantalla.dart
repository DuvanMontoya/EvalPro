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

  /// Construye panel de inicio segun permisos del rol autenticado.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(autenticacionEstadoProvider).usuario;
    final rol = usuario?.rol;
    final esEstudiante = rol == RolUsuario.ESTUDIANTE;
    final esSuperadmin = rol == RolUsuario.SUPERADMINISTRADOR;
    final puedeGestionarAcademico =
        rol == RolUsuario.DOCENTE || rol == RolUsuario.ADMINISTRADOR;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('EvalPro'),
        actions: <Widget>[
          IconButton(
            key: const Key('inicio_logout_button'),
            tooltip: Textos.cerrarSesion,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref
                  .read(autenticacionEstadoProvider.notifier)
                  .cerrarSesion();
              if (context.mounted) {
                context.go(Rutas.iniciarSesion);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Dimensiones.espaciadoLg,
            Dimensiones.espaciadoSm,
            Dimensiones.espaciadoLg,
            Dimensiones.espaciado2xl,
          ),
          children: <Widget>[
            _TarjetaUsuario(
              nombre: usuario?.nombre ?? 'Usuario',
              rol: rol?.name ?? '-',
            ),
            const SizedBox(height: Dimensiones.espaciadoLg),
            if (esEstudiante)
              _BloqueAcciones(
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
                    onPressed: () => context.go(Rutas.resultadosEstudiante),
                  ),
                ],
              ),
            if (puedeGestionarAcademico)
              _BloqueAcciones(
                titulo: 'Gestion academica',
                descripcion:
                    'Administra sesiones, examenes y operacion docente.',
                acciones: <_AccionInicio>[
                  _AccionInicio(
                    etiqueta: Textos.gestionarSesiones,
                    icono: Icons.event_note_outlined,
                    onPressed: () => context.go(Rutas.gestionSesiones),
                    esPrimaria: true,
                  ),
                  _AccionInicio(
                    etiqueta: Textos.gestionarExamenes,
                    icono: Icons.menu_book_outlined,
                    onPressed: () => context.go(Rutas.gestionExamenes),
                  ),
                  if (puedeGestionarGrupos)
                    _AccionInicio(
                      etiqueta: Textos.gestionarGrupos,
                      icono: Icons.groups_2_outlined,
                      onPressed: () => context.go(Rutas.gestionGrupos),
                    ),
                  if (puedeGestionarPeriodos)
                    _AccionInicio(
                      etiqueta: Textos.gestionarPeriodos,
                      icono: Icons.calendar_month_outlined,
                      onPressed: () => context.go(Rutas.gestionPeriodos),
                    ),
                  if (puedeGestionarUsuarios)
                    _AccionInicio(
                      etiqueta: Textos.gestionarUsuarios,
                      icono: Icons.manage_accounts_outlined,
                      onPressed: () => context.go(Rutas.gestionUsuarios),
                    ),
                  if (puedeGestionarInstituciones)
                    _AccionInicio(
                      etiqueta: Textos.gestionarInstituciones,
                      icono: Icons.apartment_outlined,
                      onPressed: () => context.go(Rutas.gestionInstituciones),
                    ),
                  if (puedeGestionarReclamos)
                    _AccionInicio(
                      etiqueta: Textos.gestionarReclamos,
                      icono: Icons.support_agent_outlined,
                      onPressed: () => context.go(Rutas.gestionReclamos),
                    ),
                  if (puedeCalificarManual)
                    _AccionInicio(
                      etiqueta: Textos.calificacionManual,
                      icono: Icons.rate_review_outlined,
                      onPressed: () =>
                          context.go(Rutas.gestionCalificacionManual),
                    ),
                ],
              ),
            if (esSuperadmin)
              _BloqueAcciones(
                titulo: 'Operacion global',
                descripcion:
                    'Gestiona instituciones y estructura base multi-tenant.',
                acciones: <_AccionInicio>[
                  _AccionInicio(
                    etiqueta: Textos.gestionarInstituciones,
                    icono: Icons.apartment_outlined,
                    onPressed: () => context.go(Rutas.gestionInstituciones),
                    esPrimaria: true,
                  ),
                  _AccionInicio(
                    etiqueta: Textos.gestionarUsuarios,
                    icono: Icons.manage_accounts_outlined,
                    onPressed: () => context.go(Rutas.gestionUsuarios),
                  ),
                  _AccionInicio(
                    etiqueta: Textos.gestionarPeriodos,
                    icono: Icons.calendar_month_outlined,
                    onPressed: () => context.go(Rutas.gestionPeriodos),
                  ),
                  _AccionInicio(
                    etiqueta: Textos.gestionarGrupos,
                    icono: Icons.groups_2_outlined,
                    onPressed: () => context.go(Rutas.gestionGrupos),
                  ),
                  _AccionInicio(
                    etiqueta: Textos.gestionarReclamos,
                    icono: Icons.support_agent_outlined,
                    onPressed: () => context.go(Rutas.gestionReclamos),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaUsuario extends StatelessWidget {
  final String nombre;
  final String rol;

  const _TarjetaUsuario({
    required this.nombre,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
        child: Container(
          padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Colores.azulPrimario, Colores.azulSecundario],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colores.blanco.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(Dimensiones.radioMd),
                ),
                child: const Icon(
                  Icons.account_circle_rounded,
                  color: Colores.blanco,
                  size: 34,
                ),
              ),
              const SizedBox(width: Dimensiones.espaciadoMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Hola, $nombre',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colores.blanco,
                      ),
                    ),
                    const SizedBox(height: Dimensiones.espaciadoXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensiones.espaciadoSm,
                        vertical: Dimensiones.espaciadoXs,
                      ),
                      decoration: BoxDecoration(
                        color: Colores.blanco.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(
                          Dimensiones.radioSm,
                        ),
                      ),
                      child: Text(
                        '${Textos.rolActual}: $rol',
                        style: textTheme.labelMedium?.copyWith(
                          color: Colores.blanco,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BloqueAcciones extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final List<_AccionInicio> acciones;

  const _BloqueAcciones({
    required this.titulo,
    required this.descripcion,
    required this.acciones,
  });

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
              titulo,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: Dimensiones.espaciadoSm),
            Text(descripcion, style: textTheme.bodyMedium),
            const SizedBox(height: Dimensiones.espaciadoLg),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnas = constraints.maxWidth > 520 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: acciones.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    mainAxisExtent: 68,
                    crossAxisSpacing: Dimensiones.espaciadoMd,
                    mainAxisSpacing: Dimensiones.espaciadoMd,
                  ),
                  itemBuilder: (context, indice) {
                    return _BotonAccion(accion: acciones[indice]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final _AccionInicio accion;

  const _BotonAccion({required this.accion});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor:
            accion.esPrimaria ? Colores.azulPrimario : Colores.grisFondo,
        foregroundColor:
            accion.esPrimaria ? Colores.blanco : Colores.textoPrincipal,
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioMd),
        ),
      ),
      onPressed: accion.onPressed,
      icon: Icon(accion.icono, size: 20),
      label: Text(
        accion.etiqueta,
        overflow: TextOverflow.ellipsis,
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

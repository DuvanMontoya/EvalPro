/// @archivo   InicioPantalla.dart
/// @descripcion Muestra accesos principales para unirse a sesiones y cerrar sesion.
/// @modulo    Pantallas/Inicio
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final nombreRol = rol?.name ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.inicio),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await ref
                  .read(autenticacionEstadoProvider.notifier)
                  .cerrarSesion();
              if (context.mounted) context.go(Rutas.iniciarSesion);
            },
            icon: const Icon(Icons.logout),
            tooltip: Textos.cerrarSesion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Hola, ${usuario?.nombre ?? ''}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${Textos.rolActual}: $nombreRol',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 18),
              if (esEstudiante)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () => context.go(Rutas.unirseExamen),
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Unirse a una sesion'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go(Rutas.resultadosEstudiante),
                      icon: const Icon(Icons.grading_outlined),
                      label: const Text(Textos.misResultados),
                    ),
                  ],
                ),
              if (puedeGestionarAcademico) ...<Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () => context.go(Rutas.gestionSesiones),
                      icon: const Icon(Icons.event_note_outlined),
                      label: const Text(Textos.gestionarSesiones),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go(Rutas.gestionExamenes),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text(Textos.gestionarExamenes),
                    ),
                    if (puedeGestionarGrupos)
                      ElevatedButton.icon(
                        onPressed: () => context.go(Rutas.gestionGrupos),
                        icon: const Icon(Icons.groups_2_outlined),
                        label: const Text(Textos.gestionarGrupos),
                      ),
                    if (puedeGestionarPeriodos)
                      ElevatedButton.icon(
                        onPressed: () => context.go(Rutas.gestionPeriodos),
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text(Textos.gestionarPeriodos),
                      ),
                    if (puedeGestionarUsuarios)
                      ElevatedButton.icon(
                        onPressed: () => context.go(Rutas.gestionUsuarios),
                        icon: const Icon(Icons.manage_accounts_outlined),
                        label: const Text(Textos.gestionarUsuarios),
                      ),
                    if (puedeGestionarInstituciones)
                      ElevatedButton.icon(
                        onPressed: () => context.go(Rutas.gestionInstituciones),
                        icon: const Icon(Icons.apartment_outlined),
                        label: const Text(Textos.gestionarInstituciones),
                      ),
                    if (puedeGestionarReclamos)
                      ElevatedButton.icon(
                        onPressed: () => context.go(Rutas.gestionReclamos),
                        icon: const Icon(Icons.support_agent_outlined),
                        label: const Text(Textos.gestionarReclamos),
                      ),
                    if (puedeCalificarManual)
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.go(Rutas.gestionCalificacionManual),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text(Textos.calificacionManual),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

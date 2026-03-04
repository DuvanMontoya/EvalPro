/// @archivo   IniciarSesionPantalla.dart
/// @descripcion Renderiza la pantalla de autenticacion para cualquier rol habilitado.
/// @modulo    Pantallas/Autenticacion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Colores.dart';
import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Providers/AutenticacionProvider.dart';
import 'Widgets/FormularioLogin.dart';

class IniciarSesionPantalla extends ConsumerWidget {
  const IniciarSesionPantalla({super.key});

  /// Construye la pantalla de login y escucha cambios de autenticacion.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(autenticacionEstadoProvider);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(autenticacionEstadoProvider, (anterior, actual) {
      if (actual.estaAutenticado) {
        context.go(Rutas.inicio);
      }
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFDDEBFF), Colores.grisFondo],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Dimensiones.espaciadoXl,
              Dimensiones.espaciadoXl,
              Dimensiones.espaciadoXl,
              Dimensiones.espaciado2xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Colores.azulPrimario,
                                Colores.azulSecundario,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(Dimensiones.radioLg),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colores.blanco,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: Dimensiones.espaciadoMd),
                        Expanded(
                          child: Text(
                            'EvalPro Movil',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colores.azulProfundo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensiones.espaciadoLg),
                    Text(
                      'Accede a evaluaciones y gestion institucional desde una sola app.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colores.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: Dimensiones.espaciadoXl),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensiones.espaciadoXl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Iniciar sesion',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            Text(
                              'Usa tu correo institucional y contrasena.',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: Dimensiones.espaciadoLg),
                            const FormularioLogin(),
                            if (estado.error != null) ...<Widget>[
                              const SizedBox(height: Dimensiones.espaciadoLg),
                              Container(
                                key: const Key('login_error_banner'),
                                padding: const EdgeInsets.all(
                                  Dimensiones.espaciadoMd,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEECEC),
                                  borderRadius: BorderRadius.circular(
                                    Dimensiones.radioMd,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Colores.rojoError,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                        width: Dimensiones.espaciadoSm),
                                    Expanded(
                                      child: Text(
                                        estado.error!,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colores.rojoError,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensiones.espaciadoLg),
                    Row(
                      children: <Widget>[
                        _PuntoLogin(
                          icono: Icons.lock_outline_rounded,
                          texto: 'Sesion segura con JWT',
                        ),
                        const SizedBox(width: Dimensiones.espaciadoSm),
                        _PuntoLogin(
                          icono: Icons.cloud_done_outlined,
                          texto: 'Sincronizacion con backend',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PuntoLogin extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _PuntoLogin({
    required this.icono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensiones.espaciadoMd,
          vertical: Dimensiones.espaciadoSm,
        ),
        decoration: BoxDecoration(
          color: Colores.blanco.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(Dimensiones.radioMd),
        ),
        child: Row(
          children: <Widget>[
            Icon(icono, size: 18, color: Colores.azulPrimario),
            const SizedBox(width: Dimensiones.espaciadoSm),
            Expanded(
              child: Text(
                texto,
                style: textTheme.labelMedium?.copyWith(
                  color: Colores.textoSecundario,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensiones.espaciadoXl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colores.azulPrimario,
                        borderRadius:
                            BorderRadius.circular(Dimensiones.radio2xl),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colores.blanco,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  Text(
                    'Bienvenido a EvalPro',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colores.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoXl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensiones.espaciadoXl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
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
                                border: Border.all(
                                  color: const Color(0xFFF4B3B3),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

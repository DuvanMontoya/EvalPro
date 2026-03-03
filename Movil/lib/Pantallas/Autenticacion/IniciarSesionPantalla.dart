/// @archivo   IniciarSesionPantalla.dart
/// @descripcion Renderiza la pantalla de autenticacion para cualquier rol habilitado.
/// @modulo    Pantallas/Autenticacion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Configuracion/Entorno.dart';
import '../../Constantes/Colores.dart';
import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Providers/AutenticacionProvider.dart';
import 'Widgets/FormularioLogin.dart';

class IniciarSesionPantalla extends ConsumerWidget {
  const IniciarSesionPantalla({super.key});

  /// Construye la pantalla de login y escucha cambios de autenticacion.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(autenticacionEstadoProvider);

    ref.listen(autenticacionEstadoProvider, (anterior, actual) {
      if (actual.estaAutenticado) {
        context.go(Rutas.inicio);
      }
    });

    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEAF2FF), Color(0xFFF7FAFF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Dimensiones.espaciadoXl,
                          Dimensiones.espaciado2xl,
                          Dimensiones.espaciadoXl,
                          Dimensiones.espaciadoLg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colores.azulPrimario,
                                borderRadius:
                                    BorderRadius.circular(Dimensiones.radioLg),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Colores.sombra,
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colores.blanco,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: Dimensiones.espaciadoLg),
                            Text(
                              'Bienvenido a EvalPro',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colores.textoPrincipal,
                              ),
                            ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            Text(
                              'Accede con tu cuenta institucional para continuar.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colores.textoSecundario,
                              ),
                            ),
                            const SizedBox(height: Dimensiones.espaciadoXl),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(Dimensiones.espaciadoMd),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FA),
                                borderRadius:
                                    BorderRadius.circular(Dimensiones.radioMd),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Icon(
                                    Icons.router_outlined,
                                    size: 18,
                                    color: Colores.textoTerciario,
                                  ),
                                  const SizedBox(
                                      width: Dimensiones.espaciadoSm),
                                  Expanded(
                                    child: Text(
                                      'Entorno API: ${Entorno.apiUrl}',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colores.textoTerciario,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (Entorno.apiUrl
                                .contains('10.0.2.2')) ...<Widget>[
                              const SizedBox(height: Dimensiones.espaciadoSm),
                              Text(
                                '10.0.2.2 funciona solo en emulador Android; en telefono fisico usa la IP local del backend.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colores.rojoError,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          Dimensiones.espaciadoXl,
                          Dimensiones.espaciadoXl,
                          Dimensiones.espaciadoXl,
                          Dimensiones.espaciadoXl,
                        ),
                        decoration: const BoxDecoration(
                          color: Colores.blanco,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Dimensiones.radio2xl),
                            topRight: Radius.circular(Dimensiones.radio2xl),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colores.sombra,
                              blurRadius: 22,
                              offset: Offset(0, -8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Text(
                              Textos.iniciarSesion,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
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
                                      Dimensiones.radioMd),
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
                    ],
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

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

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEFF4FC), Color(0xFFF8FAFF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pantallaAmplia = constraints.maxWidth >= 920;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensiones.espaciadoLg,
                  vertical: Dimensiones.espaciadoXl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: pantallaAmplia
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const Expanded(child: _PanelMarca()),
                              const SizedBox(width: Dimensiones.espaciado2xl),
                              Expanded(
                                child: _TarjetaLogin(error: estado.error),
                              ),
                            ],
                          )
                        : Column(
                            children: <Widget>[
                              const _PanelMarca(modoCompacto: true),
                              const SizedBox(height: Dimensiones.espaciadoLg),
                              _TarjetaLogin(error: estado.error),
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

class _PanelMarca extends StatelessWidget {
  final bool modoCompacto;

  const _PanelMarca({this.modoCompacto = false});

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
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciado2xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensiones.espaciadoMd,
                vertical: Dimensiones.espaciadoSm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensiones.radioLg),
                color: Colores.blanco.withValues(alpha: 0.14),
                border: Border.all(
                  color: Colores.blanco.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Text(
                'EvalPro Suite',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colores.blanco,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: Dimensiones.espaciadoXl),
            Text(
              'Evaluaciones digitales con estandar institucional.',
              style: textTheme.headlineMedium?.copyWith(
                color: Colores.blanco,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: Dimensiones.espaciadoLg),
            Text(
              'Control de sesiones, seguridad multi-tenant y trazabilidad completa en una experiencia limpia y moderna.',
              style: textTheme.bodyLarge?.copyWith(
                color: Colores.blanco.withValues(alpha: 0.86),
              ),
            ),
            if (!modoCompacto) ...<Widget>[
              const SizedBox(height: Dimensiones.espaciado2xl),
              _ItemValor(
                icono: Icons.security_rounded,
                titulo: 'Autenticacion robusta',
                descripcion: 'Tokens seguros y control de estado de cuenta.',
              ),
              const SizedBox(height: Dimensiones.espaciadoMd),
              _ItemValor(
                icono: Icons.analytics_outlined,
                titulo: 'Observabilidad en tiempo real',
                descripcion:
                    'Monitoreo y auditoria para decisiones confiables.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemValor extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const _ItemValor({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icono, color: Colores.blanco, size: 22),
        const SizedBox(width: Dimensiones.espaciadoMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                titulo,
                style: textTheme.titleSmall?.copyWith(
                  color: Colores.blanco,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Dimensiones.espaciadoXs),
              Text(
                descripcion,
                style: textTheme.bodySmall?.copyWith(
                  color: Colores.blanco.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TarjetaLogin extends StatelessWidget {
  final String? error;

  const _TarjetaLogin({required this.error});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensiones.radio2xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciado2xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              Textos.iniciarSesion,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
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
            const FormularioLogin(),
            if (error != null) ...<Widget>[
              const SizedBox(height: Dimensiones.espaciadoLg),
              Container(
                key: const Key('login_error_banner'),
                padding: const EdgeInsets.all(Dimensiones.espaciadoMd),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEECEC),
                  borderRadius: BorderRadius.circular(Dimensiones.radioMd),
                  border: Border.all(color: const Color(0xFFF4B3B3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colores.rojoError,
                      size: 18,
                    ),
                    const SizedBox(width: Dimensiones.espaciadoSm),
                    Expanded(
                      child: Text(
                        error!,
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
    );
  }
}

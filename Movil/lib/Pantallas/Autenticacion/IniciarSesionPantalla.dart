/// @archivo   IniciarSesionPantalla.dart
/// @descripcion Renderiza la pantalla de autenticacion para cualquier rol habilitado.
/// @modulo    Pantallas/Autenticacion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_surface.dart';
import 'Widgets/FormularioLogin.dart';

class IniciarSesionPantalla extends ConsumerWidget {
  const IniciarSesionPantalla({super.key});

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
      body: EvalPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Dimensiones.espaciadoLg,
              Dimensiones.espaciadoLg,
              Dimensiones.espaciadoLg,
              Dimensiones.espaciado2xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
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
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimensiones.radioLg,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.24),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const Spacer(),
                        const EvalBadge(
                          'Acceso seguro',
                          variant: EvalBadgeVariant.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensiones.espaciadoXl),
                    const EvalPageHeader(
                      eyebrow: 'Experiencia móvil premium',
                      title: 'EvalPro',
                      subtitle:
                          'Accede a exámenes, resultados y gestión académica con una interfaz nativa, clara y confiable.',
                    ),
                    const SizedBox(height: Dimensiones.espaciadoXl),
                    EvalHeroCard(
                      eyebrow: 'Operación lista',
                      title: 'Todo tu flujo académico en un solo lugar',
                      subtitle:
                          'Inicia sesión con tu cuenta institucional y continúa exactamente donde lo dejaste.',
                      icon: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      footer: Wrap(
                        spacing: Dimensiones.espaciadoSm,
                        runSpacing: Dimensiones.espaciadoSm,
                        children: const <Widget>[
                          _PuntoLogin(
                            icono: Icons.lock_outline_rounded,
                            texto: 'JWT seguro',
                          ),
                          _PuntoLogin(
                            icono: Icons.sync_rounded,
                            texto: 'Sincronización en tiempo real',
                          ),
                          _PuntoLogin(
                            icono: Icons.phone_iphone_rounded,
                            texto: 'Experiencia móvil nativa',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensiones.espaciadoXl),
                    EvalSectionCard(
                      title: 'Iniciar sesión',
                      subtitle:
                          'Usa tu correo institucional y contraseña para entrar.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const FormularioLogin(),
                          if (estado.error != null) ...<Widget>[
                            const SizedBox(height: Dimensiones.espaciadoLg),
                            Container(
                              key: const Key('login_error_banner'),
                              child: EvalNotice(
                                title: 'No pudimos iniciar la sesión',
                                message: estado.error!,
                                variant: EvalNoticeVariant.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensiones.espaciadoLg),
                    Text(
                      'EvalPro mantiene el acceso de estudiantes, docentes y administradores en una sola experiencia unificada.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w500,
                      ),
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
  const _PuntoLogin({
    required this.icono,
    required this.texto,
  });

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensiones.espaciadoMd,
        vertical: Dimensiones.espaciadoSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Dimensiones.radioLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icono, size: 16, color: Colors.white),
          const SizedBox(width: Dimensiones.espaciadoSm),
          Text(
            texto,
            style: textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/animated/count_up_text.dart';
import '../../../widgets/common/eval_avatar.dart';
import '../../../widgets/common/eval_badge.dart';
import '../../../widgets/common/eval_button.dart';
import '../../../widgets/common/eval_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const EvalAvatar(
                        name: 'Juan Pérez',
                        customSize: 80,
                        size: EvalAvatarSize.xl,
                        isOnline: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Juan Pérez',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Estudiante · Institución Central',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.surface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const EvalBadge('Activo',
                          variant: EvalBadgeVariant.success),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                children: [
                  EvalCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _ProfileStat(label: 'Exámenes', value: '12'),
                        _ProfileStat(label: 'Promedio', value: '78%'),
                        _ProfileStat(label: 'Mejor nota', value: '95%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  _SectionCard(
                    title: 'Mi cuenta',
                    items: [
                      _SectionItem(label: 'Editar perfil', onTap: () {}),
                      _SectionItem(label: 'Cambiar contraseña', onTap: () {}),
                      _SectionItem(label: 'Notificaciones', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  _SectionCard(
                    title: 'Mi institución',
                    items: [
                      _SectionItem(label: 'Institución Central', onTap: null),
                      _SectionItem(label: 'Grupos inscritos (3)', onTap: () {}),
                      _SectionItem(
                          label: 'Período académico actual', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  _SectionCard(
                    title: 'Privacidad',
                    items: [
                      _SectionItem(
                          label: 'Políticas de evaluación', onTap: () {}),
                      _SectionItem(label: 'Mis datos', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  const Divider(),
                  ListTile(
                    onTap: () => _showLogoutBottomSheet(context),
                    leading: const Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    title: Text(
                      'Cerrar sesión',
                      style: textTheme.titleMedium
                          ?.copyWith(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Cerrar sesión?',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tendrás que iniciar sesión nuevamente para continuar.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                EvalButton(
                  label: 'Cerrar sesión',
                  variant: EvalButtonVariant.destructive,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: AppSpacing.sm),
                EvalButton(
                  label: 'Cancelar',
                  variant: EvalButtonVariant.outlined,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final numeric = value.replaceAll('%', '');
    final parsed = double.tryParse(numeric) ?? 0;
    return Column(
      children: [
        CountUpText(
          value: parsed,
          suffix: value.contains('%') ? '%' : '',
          style: textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.items});

  final String title;
  final List<_SectionItem> items;

  @override
  Widget build(BuildContext context) {
    return EvalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...items.map((item) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: item.onTap,
              title: Text(item.label,
                  style: Theme.of(context).textTheme.bodyMedium),
              trailing: item.onTap == null
                  ? null
                  : const Icon(Icons.chevron_right_rounded,
                      color: AppColors.slate400),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionItem {
  const _SectionItem({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;
}

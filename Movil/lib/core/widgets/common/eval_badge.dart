import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

enum EvalBadgeVariant { primary, success, warning, error, neutral }

class EvalBadge extends StatelessWidget {
  const EvalBadge(
    this.label, {
    this.variant = EvalBadgeVariant.neutral,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    super.key,
  });

  final String label;
  final EvalBadgeVariant variant;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = switch (variant) {
      EvalBadgeVariant.primary => (
          background: AppColors.primarySurface,
          text: AppColors.primary,
          border: AppColors.primaryBorder,
        ),
      EvalBadgeVariant.success => (
          background: AppColors.successSurface,
          text: AppColors.success,
          border: AppColors.successBorder,
        ),
      EvalBadgeVariant.warning => (
          background: AppColors.warningSurface,
          text: AppColors.warning,
          border: AppColors.warningBorder,
        ),
      EvalBadgeVariant.error => (
          background: AppColors.errorSurface,
          text: AppColors.error,
          border: AppColors.errorBorder,
        ),
      EvalBadgeVariant.neutral => (
          background: AppColors.slate100,
          text: AppColors.slate600,
          border: AppColors.slate200,
        ),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: palette.text,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

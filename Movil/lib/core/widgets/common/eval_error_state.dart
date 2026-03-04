import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'eval_button.dart';

class EvalErrorState extends StatelessWidget {
  const EvalErrorState({
    required this.message,
    this.title = 'Algo salió mal',
    this.onRetry,
    this.icon = Icons.wifi_tethering_error_rounded,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.errorSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.slate500),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              EvalButton(
                label: 'Reintentar',
                variant: EvalButtonVariant.outlined,
                fullWidth: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

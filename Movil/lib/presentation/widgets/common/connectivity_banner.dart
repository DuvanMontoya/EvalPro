import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    required this.isConnected,
    this.message = 'Sin conexión · Reconectando...',
    super.key,
  });

  final bool isConnected;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = isConnected
        ? const Duration(milliseconds: 250)
        : const Duration(milliseconds: 300);

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      height: isConnected ? 0 : 36,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: isConnected ? 0 : 1,
          child: Container(
            height: 36,
            color: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 14, color: AppColors.surface),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  message,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

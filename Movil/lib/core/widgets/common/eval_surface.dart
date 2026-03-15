import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'eval_card.dart';

enum EvalNoticeVariant { info, success, warning, error }

class EvalPageBackground extends StatelessWidget {
  const EvalPageBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFF9FBFF),
            AppColors.background,
            Color(0xFFF2F6FC),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: -140,
            right: -56,
            child: _EvalGlowOrb(
              size: 280,
              color: AppColors.primary,
              opacity: 0.16,
            ),
          ),
          const Positioned(
            top: 160,
            left: -92,
            child: _EvalGlowOrb(
              size: 220,
              color: AppColors.info,
              opacity: 0.10,
            ),
          ),
          const Positioned(
            bottom: -132,
            right: -72,
            child: _EvalGlowOrb(
              size: 240,
              color: AppColors.warning,
              opacity: 0.08,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class EvalPageHeader extends StatelessWidget {
  const EvalPageHeader({
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if ((eyebrow ?? '').trim().isNotEmpty) ...<Widget>[
                Text(
                  eyebrow!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(
                title,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.slate600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: AppSpacing.base),
          trailing!,
        ],
      ],
    );
  }
}

class EvalHeroCard extends StatelessWidget {
  const EvalHeroCard({
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.icon,
    this.trailing,
    this.footer,
    this.gradient,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final Widget? icon;
  final Widget? trailing;
  final Widget? footer;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient:
            gradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF1A4FFF), Color(0xFF39A7FF)],
            ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppSpacing.shadowLg,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: icon,
                ),
                const SizedBox(width: AppSpacing.base),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if ((eyebrow ?? '').trim().isNotEmpty) ...<Widget>[
                      Text(
                        eyebrow!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (footer != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            footer!,
          ],
        ],
      ),
    );
  }
}

class EvalSectionCard extends StatelessWidget {
  const EvalSectionCard({
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    super.key,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHeading =
        (title ?? '').trim().isNotEmpty || (subtitle ?? '').trim().isNotEmpty;

    return EvalCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hasHeading) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if ((title ?? '').trim().isNotEmpty)
                        Text(
                          title!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      if ((subtitle ?? '').trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.base),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          child,
        ],
      ),
    );
  }
}

class EvalMetricTile extends StatelessWidget {
  const EvalMetricTile({
    required this.label,
    required this.value,
    this.icon,
    this.highlightColor = AppColors.primary,
    this.caption,
    super.key,
  });

  final String label;
  final String value;
  final Widget? icon;
  final Color highlightColor;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            icon!,
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlightColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate700,
              fontWeight: FontWeight.w600,
            ),
          ),
          if ((caption ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              caption!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.slate500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EvalInfoRow extends StatelessWidget {
  const EvalInfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.compact = false,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.sm : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: AppColors.slate500),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleMedium?.copyWith(
                color: valueColor ?? AppColors.slate900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EvalNotice extends StatelessWidget {
  const EvalNotice({
    required this.message,
    this.title,
    this.icon,
    this.variant = EvalNoticeVariant.info,
    super.key,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final EvalNoticeVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = switch (variant) {
      EvalNoticeVariant.info => (
          background: AppColors.infoSurface,
          border: AppColors.info.withValues(alpha: 0.22),
          foreground: AppColors.info,
          icon: Icons.info_outline_rounded,
        ),
      EvalNoticeVariant.success => (
          background: AppColors.successSurface,
          border: AppColors.successBorder,
          foreground: AppColors.success,
          icon: Icons.check_circle_outline_rounded,
        ),
      EvalNoticeVariant.warning => (
          background: AppColors.warningSurface,
          border: AppColors.warningBorder,
          foreground: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        ),
      EvalNoticeVariant.error => (
          background: AppColors.errorSurface,
          border: AppColors.errorBorder,
          foreground: AppColors.error,
          icon: Icons.error_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon ?? palette.icon, color: palette.foreground, size: 20),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if ((title ?? '').trim().isNotEmpty) ...<Widget>[
                  Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EvalGlowOrb extends StatelessWidget {
  const _EvalGlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

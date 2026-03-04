import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

enum EvalButtonVariant { filled, outlined, ghost, destructive }

enum EvalButtonSize { normal, small }

class EvalButton extends StatefulWidget {
  const EvalButton({
    required this.label,
    this.onPressed,
    this.variant = EvalButtonVariant.filled,
    this.size = EvalButtonSize.normal,
    this.isLoading = false,
    this.fullWidth = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final EvalButtonVariant variant;
  final EvalButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final String? semanticLabel;

  @override
  State<EvalButton> createState() => _EvalButtonState();
}

class _EvalButtonState extends State<EvalButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  Duration get _pressDuration {
    return switch (widget.variant) {
      EvalButtonVariant.filled => const Duration(milliseconds: 100),
      EvalButtonVariant.outlined => const Duration(milliseconds: 80),
      EvalButtonVariant.ghost => const Duration(milliseconds: 80),
      EvalButtonVariant.destructive => const Duration(milliseconds: 150),
    };
  }

  double get _height => widget.size == EvalButtonSize.small ? 36 : 52;

  double get _radius => widget.size == EvalButtonSize.small
      ? AppSpacing.radiusSm - 2
      : AppSpacing.radiusSm;

  EdgeInsets get _padding {
    return widget.size == EvalButtonSize.small
        ? const EdgeInsets.symmetric(horizontal: 16)
        : const EdgeInsets.symmetric(horizontal: 24);
  }

  TextStyle? _labelStyle(ThemeData theme, Color color) {
    final base = widget.size == EvalButtonSize.small
        ? theme.textTheme.labelMedium
        : theme.textTheme.labelLarge;
    return base?.copyWith(color: color);
  }

  _EvalButtonPalette _palette() {
    final isDisabled = !_isEnabled;
    final isPressed = _isPressed && _isEnabled;

    final base = switch (widget.variant) {
      EvalButtonVariant.filled => _EvalButtonPalette(
          background: AppColors.primary,
          foreground: AppColors.surface,
          border: Colors.transparent,
          pressedBackground: AppColors.primaryDark,
        ),
      EvalButtonVariant.outlined => _EvalButtonPalette(
          background: Colors.transparent,
          foreground: AppColors.primary,
          border: AppColors.slate200,
          pressedBackground: AppColors.slate50,
        ),
      EvalButtonVariant.ghost => _EvalButtonPalette(
          background: Colors.transparent,
          foreground: AppColors.primary,
          border: Colors.transparent,
          pressedBackground: AppColors.primarySurface,
        ),
      EvalButtonVariant.destructive => _EvalButtonPalette(
          background: AppColors.errorSurface,
          foreground: AppColors.error,
          border: AppColors.errorBorder,
          pressedBackground: AppColors.error,
          pressedForeground: AppColors.surface,
        ),
    };

    if (isDisabled) {
      return base.copyWith(boxShadow: const [], opacity: 0.45);
    }

    final effectiveShadow = widget.variant == EvalButtonVariant.filled
        ? (isPressed ? AppSpacing.shadowSm : AppSpacing.shadowPrimary)
        : const <BoxShadow>[];

    return base.copyWith(
      boxShadow: effectiveShadow,
      background: isPressed ? base.pressedBackground : base.background,
      foreground: isPressed
          ? base.pressedForeground ?? base.foreground
          : base.foreground,
    );
  }

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() {
      _isPressed = value;
    });
  }

  void _handleTap() {
    if (!_isEnabled) {
      return;
    }
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette();
    final theme = Theme.of(context);

    final button = AnimatedScale(
      scale: _isPressed && _isEnabled ? 0.97 : 1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        width: widget.fullWidth ? double.infinity : null,
        height: _height,
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(_radius),
          border: palette.border == Colors.transparent
              ? null
              : Border.all(color: palette.border, width: 1.5),
          boxShadow: palette.boxShadow,
        ),
        padding: _padding,
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: palette.foreground,
                  ),
                )
              : Text(
                  widget.label,
                  style: _labelStyle(theme, palette.foreground),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );

    return Opacity(
      opacity: palette.opacity,
      child: Semantics(
        button: true,
        enabled: _isEnabled,
        label: widget.semanticLabel ?? widget.label,
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _handleTap,
          child: button,
        ),
      ),
    );
  }
}

class _EvalButtonPalette {
  const _EvalButtonPalette({
    required this.background,
    required this.foreground,
    required this.border,
    required this.pressedBackground,
    this.pressedForeground,
    this.boxShadow = const <BoxShadow>[],
    this.opacity = 1,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color pressedBackground;
  final Color? pressedForeground;
  final List<BoxShadow> boxShadow;
  final double opacity;

  _EvalButtonPalette copyWith({
    Color? background,
    Color? foreground,
    Color? border,
    Color? pressedBackground,
    Color? pressedForeground,
    List<BoxShadow>? boxShadow,
    double? opacity,
  }) {
    return _EvalButtonPalette(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
      pressedBackground: pressedBackground ?? this.pressedBackground,
      pressedForeground: pressedForeground ?? this.pressedForeground,
      boxShadow: boxShadow ?? this.boxShadow,
      opacity: opacity ?? this.opacity,
    );
  }
}

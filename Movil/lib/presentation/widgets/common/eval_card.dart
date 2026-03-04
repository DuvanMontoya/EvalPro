import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class EvalCard extends StatefulWidget {
  const EvalCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.backgroundColor,
    this.borderColor,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? semanticLabel;

  @override
  State<EvalCard> createState() => _EvalCardState();
}

class _EvalCardState extends State<EvalCard> {
  bool _isPressed = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedScale(
      duration: const Duration(milliseconds: 100),
      scale: _isPressed ? 0.99 : 1,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _isHovering
                ? AppColors.primaryBorder
                : (widget.borderColor ?? AppColors.slate200),
            width: 1,
          ),
          boxShadow: AppSpacing.shadowSm,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
            onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
            onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            splashColor: AppColors.primarySurface,
            highlightColor: AppColors.primarySurface.withValues(alpha: 0.35),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );

    final wrapped = MouseRegion(
      onEnter: (_) => _setHovering(true),
      onExit: (_) => _setHovering(false),
      child: card,
    );

    if (widget.onTap == null) {
      return wrapped;
    }

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: wrapped,
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

  void _setHovering(bool value) {
    if (_isHovering == value) {
      return;
    }
    setState(() {
      _isHovering = value;
    });
  }
}

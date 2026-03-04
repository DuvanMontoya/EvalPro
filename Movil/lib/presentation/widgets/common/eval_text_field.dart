import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class EvalTextField extends StatefulWidget {
  const EvalTextField({
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.autofillHints,
    this.isPassword = false,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final Iterable<String>? autofillHints;
  final bool isPassword;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<EvalTextField> createState() => _EvalTextFieldState();
}

class _EvalTextFieldState extends State<EvalTextField> {
  late FocusNode _focusNode;
  late bool _obscure;
  bool _ownsFocusNode = false;

  bool get _hasError => (widget.errorText ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_onFocusChanged);
    _obscure = widget.isPassword;
  }

  @override
  void didUpdateWidget(covariant EvalTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_onFocusChanged);
    }
    if (oldWidget.isPassword != widget.isPassword && widget.isPassword) {
      _obscure = true;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
        onPressed: widget.enabled
            ? () => setState(() {
                  _obscure = !_obscure;
                })
            : null,
        icon: AnimatedCrossFade(
          firstChild: const Icon(Icons.visibility_rounded),
          secondChild: const Icon(Icons.visibility_off_rounded),
          crossFadeState:
              _obscure ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 150),
        ),
      );
    }
    if (_hasError) {
      return const Padding(
        padding: EdgeInsets.only(right: 12),
        child: Icon(Icons.warning_amber_rounded, color: AppColors.error),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _hasError
        ? AppColors.error
        : (_focusNode.hasFocus ? AppColors.primary : AppColors.slate200);
    final borderWidth = _focusNode.hasFocus ? 2.0 : 1.5;
    final fillColor = widget.enabled ? AppColors.surface : AppColors.slate50;
    final textColor = widget.enabled ? AppColors.slate900 : AppColors.slate300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          textField: true,
          label: widget.labelText,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              maxLines: widget.maxLines,
              autofillHints: widget.autofillHints,
              obscureText: widget.isPassword ? _obscure : false,
              textAlign: widget.textAlign,
              inputFormatters: widget.inputFormatters,
              style: theme.textTheme.titleMedium?.copyWith(color: textColor),
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: _hasError
                      ? AppColors.error
                      : (_focusNode.hasFocus
                          ? AppColors.primary
                          : AppColors.slate500),
                ),
                hintStyle: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.slate400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: _buildSuffixIcon() == null
                    ? null
                    : SizedBox(width: 48, child: _buildSuffixIcon()),
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: _hasError
              ? Padding(
                  key: const ValueKey('eval_text_field_error'),
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    widget.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('eval_text_field_ok')),
        ),
      ],
    );
  }
}
